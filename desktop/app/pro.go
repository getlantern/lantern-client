package app

import (
	"context"
	"encoding/json"
	"reflect"

	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// onProStatusChange allows registering an event handler to learn when the
// user's pro status changes
func (app *App) onProStatusChange(cb func(isPro bool)) {
	app.setOnUserData(func(current *protos.User, new *protos.User) {
		if current == nil || isActive(current) != isActive(new) {
			cb(isProUser(new))
		}
	})
}

func (app *App) setOnUserData(onUserData func(*protos.User, *protos.User)) {
	app.mu.Lock()
	defer app.mu.Unlock()
	app.onUserData = append(app.onUserData, onUserData)
}

func (app *App) SetUserData(ctx context.Context, userID int64, u *protos.User) {
	current, found := app.GetUserData(userID)
	if found && reflect.DeepEqual(current, u) {
		return
	}
	app.cachedUserData.Store(u.UserId, u)
	app.mu.Lock()
	onUserData := app.onUserData
	app.mu.Unlock()
	for _, cb := range onUserData {
		cb(current, u)
	}
}

func (app *App) SetUserDevices(userID int64, devices []*protos.Device) {
	user, found := app.GetUserData(userID)
	if !found {
		return
	}
	user.Devices = devices
	app.cachedUserData.Store(userID, user)
}

func (app *App) GetUserData(userID int64) (*protos.User, bool) {
	res, ok := app.cachedUserData.Load(userID)
	if !ok {
		return nil, false
	}
	return res.(*protos.User), true
}

func (app *App) IsProUser(ctx context.Context, uc common.UserConfig) (isPro bool, ok bool) {
	user, found := app.GetUserData(uc.GetUserID())
	if !found {
		ctx := context.Background()
		resp, err := fetchUserDataWithClient(ctx, app.proClient, uc)
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

	return resp, nil
}

// isActive determines whether the given status is an active status
func isActive(user *protos.User) bool {
	return user != nil && user.UserStatus == "active"
}

// isProUser determines whether the given status is an active status
func isProUser(user *protos.User) bool {
	return user != nil && (user.UserStatus == "active" || user.UserLevel == "pro")
}

// IsProUserFast indicates whether or not the user is pro and whether or not the
// user's status is know, never calling the Pro API to determine the status.
func (app *App) IsProUserFast(uc common.UserConfig) (isPro bool, statusKnown bool) {
	user, found := app.GetUserData(uc.GetUserID())
	if !found {
		return false, false
	}
	return isProUser(user), found
}

// servePro fetches user data or creates new user when the application starts up
// It loops forever in 10 seconds interval until the user is fetched or
// created, as it's fundamental for the UI to work.
func (app *App) servePro(channel ws.UIChannel) error {
	service, err := channel.Register("pro", nil)
	if err != nil {
		return err
	}
	app.setOnUserData(func(current *protos.User, new *protos.User) {
		if new != nil {
			b, _ := json.Marshal(new)
			log.Debugf("Sending updated user data to all clients: %s", string(b))
			service.Out <- new
		}
	})
	return err
}
