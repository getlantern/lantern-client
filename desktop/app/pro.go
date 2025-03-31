package app

import (
	"context"
	"reflect"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// UserConfig returns the current user configuration after applying settings.
func (app *App) UserConfig() common.UserConfig {
	settings := app.Settings()
	return userConfig(settings)()
}

// userConfig returns the user configuration based on the latest settings.
func userConfig(settings *Settings) func() common.UserConfig {
	return func() common.UserConfig {
		userID, deviceID := settings.GetUserID(), settings.GetDeviceID()
		token, lang := settings.GetToken(), settings.GetLanguage()
		return common.NewUserConfig(
			common.DefaultAppName,
			deviceID,
			userID,
			token,
			nil,
			lang,
		)
	}
}

// SetUserData stores the user data in the cache
func (app *App) SetUserData(ctx context.Context, userID int64, u *protos.User) {
	current, found := app.UserData(userID)
	if found && reflect.DeepEqual(current, u) {
		return
	}
	app.userCache.Store(userID, u)
}

// SetUserDevices updates the list of devices associated with a user in the cache.
func (app *App) SetUserDevices(userID int64, devices []*protos.Device) {
	user, found := app.UserData(userID)
	if !found {
		return
	}
	user.Devices = devices
	app.userCache.Store(userID, user)
}

// UserData retrieves the user data from the cache.
func (app *App) UserData(args ...int64) (*protos.User, bool) {
	userID := app.Settings().GetUserID()
	if len(args) > 0 {
		userID = args[0]
	}
	if userID == 0 {
		return nil, false
	}
	res, ok := app.userCache.Load(userID)
	if !ok {
		return nil, false
	}
	return res.(*protos.User), true
}

func (app *App) RefreshUserData() (*protos.User, error) {
	user, found := app.UserData()
	if found {
		return user, nil
	}
	userID := app.Settings().GetUserID()
	if userID == 0 {
		return nil, errors.New("no user ID found")
	}
	res, err := app.fetchUserData(context.Background(), &common.UserConfigData{
		UserID: userID,
	})
	if err != nil {
		return nil, err
	}
	app.userCache.Store(userID, res.User)
	return res.User, nil
}

func (app *App) IsProUser(ctx context.Context, uc common.UserConfig) (isPro bool, ok bool) {
	user, found := app.UserData()
	if !found {
		resp, err := app.fetchUserData(ctx, uc)
		if err != nil {
			return false, false
		}
		user = resp.User
	}
	return isActive(user), true
}

func (app *App) fetchUserData(ctx context.Context, uc common.UserConfig) (*pro.UserDataResponse, error) {
	userID := uc.GetUserID()
	log.Debugf("Fetching user status with device ID '%v', user ID '%v' and proToken %v",
		uc.GetDeviceID(), userID, uc.GetToken())
	return app.ProClient().UserData(ctx)
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
func (app *App) IsProUserFast() (isPro bool, statusKnown bool) {
	user, found := app.UserData()
	if !found {
		return false, false
	}
	return isProUser(user), found
}

// servePro fetches user data or creates new user when the application starts up
// It loops forever in 10 seconds interval until the user is fetched or
// created, as it's fundamental for the UI to work.
func (app *App) servePro(channel ws.UIChannel) error {
	_, err := channel.Register("pro", nil)
	return err
}
