package app

import (
	"context"
	"reflect"

	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

func (app *App) UserConfig() common.UserConfig {
	return userConfigFromSettings(app.Settings())()
}

func (app *App) userID() int64 {
	uc := app.UserConfig()
	return uc.GetUserID()
}

// userConfigFromSettings returns the user configuration based on the latest settings.
func userConfigFromSettings(settings *Settings) func() common.UserConfig {
	return func() common.UserConfig {
		var deviceID, token, lang string
		var userID int64
		if settings != nil {
			userID, deviceID, token, lang = settings.GetUserID(), settings.GetDeviceID(), settings.GetToken(), settings.GetLanguage()
		}
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

func (app *App) SetUserData(ctx context.Context, userID int64, u *protos.User) {
	current, found := app.UserData()
	if found && reflect.DeepEqual(current, u) {
		return
	}
	app.cachedUserData.Store(u.UserId, u)
}

func (app *App) SetUserDevices(userID int64, devices []*protos.Device) {
	user, found := app.UserData(userID)
	if !found {
		return
	}
	user.Devices = devices
	app.cachedUserData.Store(userID, user)
}

func (app *App) UserData(args ...int64) (*protos.User, bool) {
	uc := app.UserConfig()
	userID := uc.GetUserID()
	if len(args) > 0 {
		userID = args[0]
	}
	return app.userData(userID)
}

func (app *App) userData(userID int64) (*protos.User, bool) {
	res, ok := app.cachedUserData.Load(userID)
	if !ok {
		return nil, false
	}
	return res.(*protos.User), true
}

func (app *App) RefreshUserData() (*protos.User, error) {
	user, found := app.UserData()
	if !found {
		userID := app.userID()
		res, err := app.fetchUserData(context.Background(), &common.UserConfigData{
			UserID: userID,
		})
		if err != nil {
			return nil, err
		}
		app.cachedUserData.Store(userID, user)
		return res.User, nil
	}
	return user, nil
}

func (app *App) IsProUser(ctx context.Context, uc common.UserConfig) (isPro bool, ok bool) {
	user, found := app.UserData(uc.GetUserID())
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
	resp, err := app.proClient.UserData(ctx)
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
func (app *App) IsProUserFast() (isPro bool, statusKnown bool) {
	user, found := app.UserData()
	if !found {
		return false, false
	}
	return isProUser(user), found
}
