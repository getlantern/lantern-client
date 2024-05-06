package app

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/eventual/v2"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

type userMap struct {
	sync.RWMutex
	data       map[int64]eventual.Value
	onUserData []func(current *protos.User, new *protos.User)
}

var userData = userMap{
	data:       make(map[int64]eventual.Value),
	onUserData: make([]func(current *protos.User, new *protos.User), 0),
}

// onUserData allows registering an event handler to learn when the
// user data has been fetched.
func onUserData(cb func(current *protos.User, new *protos.User)) {
	userData.Lock()
	userData.onUserData = append(userData.onUserData, cb)
	userData.Unlock()
}

// onProStatusChange allows registering an event handler to learn when the
// user's pro status or "yinbi enabled" status has changed.
func onProStatusChange(cb func(isPro bool)) {
	onUserData(func(current *protos.User, new *protos.User) {
		if current == nil || isActive(current.UserStatus) != isActive(new.UserStatus) {
			cb(isActive(new.UserStatus))
		}
	})
}

func (m *userMap) save(ctx context.Context, userID int64, u *protos.User) {
	m.Lock()
	v := m.data[userID]
	var current *protos.User
	if v == nil {
		v = eventual.NewValue()
	} else {
		cur, _ := v.Get(ctx)
		current, _ = cur.(*protos.User)
	}
	v.Set(u)
	m.data[userID] = v
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
	u, err := v.Get(ctx)
	if err != nil {
		return nil, false
	}
	return u.(*protos.User), true
}

// IsProUser blocks itself to check if current user is Pro, or !ok if error
// happens getting user status from pro-server. The result is not cached
// because the user can become Pro or free at any time. It waits until
// the user ID becomes non-zero.
func (app *App) IsProUser(ctx context.Context) (isPro bool, ok bool) {
	_, err := app.settings.GetInt64Eventually(settings.SNUserID)
	if err != nil {
		return false, false
	}
	return IsProUser(ctx, app.proClient, app.settings)
}

func IsProUser(ctx context.Context, proClient pro.ProClient, uc common.UserConfig) (isPro bool, ok bool) {
	isActive := func(user *protos.User) bool {
		return user != nil && user.UserStatus == "active"
	}
	user, found := GetUserDataFast(ctx, uc.GetUserID())
	if !found {
		ctx := context.Background()
		resp, err := fetchUserDataWithClient(ctx, proClient, uc)
		if err != nil {
			return false, false
		}
		user = resp.User
	}
	return isActive(user), true
}

func fetchUserDataWithClient(ctx context.Context, proClient pro.ProClient, uc common.UserConfig) (*pro.UserDataResponse, error) {
	userID := uc.GetUserID()
	log.Debugf("Fetching user status with device ID '%v', user ID '%v' and proToken %v",
		uc.GetDeviceID(), userID, uc.GetToken())
	resp, err := proClient.UserData(ctx)
	if err != nil {
		return nil, err
	}
	setUserData(ctx, userID, resp.User)
	log.Debugf("User %d is '%v'", userID, resp.User.UserStatus)
	return resp, nil
}

func setUserData(ctx context.Context, userID int64, user *protos.User) {
	log.Debugf("Storing user data for user %v", userID)
	userData.save(ctx, userID, user)
}

// isActive determines whether the given status is an active status
func isActive(status string) bool {
	return status == "active"
}

// GetUserDataFast gets the user data for the given userID if found.
func GetUserDataFast(ctx context.Context, userID int64) (*protos.User, bool) {
	return userData.get(ctx, userID)
}

// IsProUserFast indicates whether or not the user is pro and whether or not the
// user's status is know, never calling the Pro API to determine the status.
func IsProUserFast(ctx context.Context, uc common.UserConfig) (isPro bool, statusKnown bool) {
	user, found := GetUserDataFast(ctx, uc.GetUserID())
	if !found {
		return false, false
	}
	return isActive(user.UserStatus), found
}

// isProUserFast checks a cached value for the pro status and doesn't wait for
// an answer. It works because servePro below fetches user data / create new
// user when starts up. The pro proxy also updates user data implicitly for
// '/userData' calls initiated from desktop UI.
func (app *App) isProUserFast(ctx context.Context) (isPro bool, statusKnown bool) {
	return IsProUserFast(ctx, app.settings)
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
		if user, known := GetUserDataFast(ctx, app.settings.GetUserID()); known {
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
	onUserData(func(current *protos.User, new *protos.User) {
		b, _ := json.Marshal(new)
		log.Debugf("Sending updated user data to all clients: %s", string(b))
		service.Out <- new
	})
	return err
}
