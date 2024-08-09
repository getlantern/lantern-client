package app

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

type userMap struct {
	sync.RWMutex
	data       map[int64]*protos.User
	onUserData []func(current *protos.User, new *protos.User)
}

// onUserData allows registering an event handler to learn when the
// user data has been fetched.
func (app *App) onUserData(cb func(current *protos.User, new *protos.User)) {
	userData := app.userData
	userData.Lock()
	userData.onUserData = append(userData.onUserData, cb)
	userData.Unlock()
}

// onProStatusChange allows registering an event handler to learn when the
// user's pro status or "yinbi enabled" status has changed.
func (app *App) onProStatusChange(cb func(isPro bool)) {
	app.onUserData(func(current *protos.User, new *protos.User) {
		if current == nil || isActive(current) != isActive(new) {
			cb(isActive(new))
		}
	})
}

func (m *userMap) save(ctx context.Context, userID int64, u *protos.User) {
	m.Lock()
	current := m.data[userID]
	m.data[userID] = u
	onUserData := m.onUserData
	m.Unlock()
	for _, cb := range onUserData {
		cb(current, u)
	}
}

func (m *userMap) get(ctx context.Context, userID int64) (*protos.User, bool) {
	m.RLock()
	v := m.data[userID]
	m.RUnlock()
	if v == nil {
		return nil, false
	}
	return v, true
}

// IsProUser blocks itself to check if current user is Pro, or !ok if error
// happens getting user status from pro-server. The result is not cached
// because the user can become Pro or free at any time. It waits until
// the user ID becomes non-zero.
func (app *App) IsProUser(ctx context.Context) (bool, bool) {
	_, err := app.settings.GetInt64Eventually(settings.SNUserID)
	if err != nil || app.settings == nil {
		return false, false
	}
	uc := app.settings
	user, found := app.userData.get(ctx, uc.GetUserID())
	if !found {
		ctx := context.Background()
		resp, err := fetchUserDataWithClient(ctx, app.proClient, uc)
		if err != nil {
			return false, false
		}
		app.SetUserData(ctx, resp.UserId, resp.User)
		log.Debugf("User %d is '%v'", resp.UserId, resp.User.UserStatus)
		user = resp.User
	}
	return isActive(user), true
}

func fetchUserDataWithClient(ctx context.Context, proClient pro.ProClient, uc common.UserConfig) (*pro.UserDataResponse, error) {
	userID := uc.GetUserID()
	log.Debugf("Fetching user status with device ID '%v', user ID '%v' and proToken %v",
		uc.GetDeviceID(), userID, uc.GetToken())
	return proClient.UserData(ctx)
}

func (app *App) SetUserData(ctx context.Context, userID int64, user *protos.User) {
	log.Debugf("Storing user data for user %v", userID)
	app.userData.save(ctx, userID, user)
}

func (app *App) SetUserDevices(ctx context.Context, userID int64, devices []*protos.Device) {
	user, found := app.userData.get(ctx, userID)
	if !found {
		return
	}
	user.Devices = devices
	app.userData.save(ctx, userID, user)
}

// isActive determines whether the given status is an active status
func isActive(user *protos.User) bool {
	return user != nil && (user.UserStatus == "active" || user.UserLevel == "pro")
}

func (app *App) UserData(ctx context.Context) (*protos.User, bool) {
	settings := app.Settings()
	if settings == nil {
		return nil, false
	}
	return app.userData.get(ctx, settings.GetUserID())
}

// isProUserFast checks a cached value for the pro status and doesn't wait for
// an answer. It works because servePro below fetches user data / create new
// user when starts up. The pro proxy also updates user data implicitly for
// '/userData' calls initiated from desktop UI.
func (app *App) IsProUserFast(ctx context.Context) (isPro bool, statusKnown bool) {
	user, found := app.UserData(ctx)
	if !found {
		return false, false
	}
	return isActive(user), found
}

// servePro fetches user data or creates new user when the application starts up
// It loops forever in 10 seconds interval until the user is fetched or
// created, as it's fundamental for the UI to work.
func (app *App) servePro(channel ws.UIChannel) error {
	chFetch := make(chan bool)
	ctx := context.Background()
	go func() {
		fetchOrCreate := func() error {
			userID := app.settings.GetUserID()
			if userID == 0 {
				resp, err := app.proClient.UserCreate(ctx)
				if err != nil {
					return errors.New("Could not create new Pro user: %v", err)
				}
				app.settings.SetUserIDAndToken(resp.User.UserId, resp.User.Token)
			} else {
				_, err := app.proClient.UserData(ctx)
				if err != nil {
					return errors.New("Could not get user data for %v: %v", userID, err)
				}
			}
			return nil
		}

		retry := time.NewTimer(0)
		retryOnFail := func(drainChannel bool) {
			if err := fetchOrCreate(); err != nil {
				if drainChannel && !retry.Stop() {
					<-retry.C
				}
				retry.Reset(10 * time.Second)
			}
		}
		for {
			select {
			case <-chFetch:
				retryOnFail(true)
			case <-retry.C:
				retryOnFail(false)
			}
		}
	}()
	helloFn := func(write func(interface{})) {
		if user, known := app.IsProUserFast(ctx); known {
			log.Debugf("Sending current user data to new client: %v", user)
			write(user)
		}
		log.Debugf("Fetching user data again to see if any changes")
		select {
		case chFetch <- true:
		default: // fetching in progress, skipping
		}
	}
	service, err := channel.Register("pro", helloFn)
	if err != nil {
		return err
	}
	app.onUserData(func(current *protos.User, new *protos.User) {
		b, _ := json.Marshal(new)
		log.Debugf("Sending updated user data to all clients: %s", string(b))
		service.Out <- new
	})
	return err
}
