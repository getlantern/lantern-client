package app

import (
	"encoding/json"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/pro"
	"github.com/getlantern/flashlight/v7/pro/client"
	"github.com/getlantern/lantern-client/desktop/deviceid"
	"github.com/getlantern/lantern-client/desktop/ws"
)

// isProUser blocks itself to check if current user is Pro, or !ok if error
// happens getting user status from pro-server. The result is not cached
// because the user can become Pro or free at any time. It waits until
// the user ID becomes non-zero.
func (app *App) IsProUser() (isPro bool, ok bool) {
	_, err := app.settings.GetInt64Eventually(SNUserID)
	if err != nil {
		return false, false
	}
	return pro.IsProUser(app.settings)
}

// isProUserFast checks a cached value for the pro status and doesn't wait for
// an answer. It works because servePro below fetches user data / create new
// user when starts up. The pro proxy also updates user data implicitly for
// '/userData' calls initiated from desktop UI.
func (app *App) isProUserFast() (isPro bool, statusKnown bool) {
	return pro.IsProUserFast(app.settings)
}

// servePro fetches user data or creates new user when the application starts up
// It loops forever in 10 seconds interval until the user is fetched or
// created, as it's fundamental for the UI to work.
func (app *App) servePro(channel ws.UIChannel) error {
	chFetch := make(chan bool)
	go func() {
		fetchOrCreate := func() error {
			userID := app.settings.GetUserID()
			if userID == 0 {
				user, err := pro.NewUser(app.settings)
				if err != nil {
					return errors.New("Could not create new Pro user: %v", err)
				}
				app.settings.SetUserIDAndToken(user.Auth.ID, user.Auth.Token)
			} else {
				isPro, _ := pro.IsProUserFast(app.settings)
				if isPro && userID != app.settings.GetMigratedDeviceIDForUserID() {
					// If we've gotten here, that means this client may have previously used an old-style device ID. We don't know for sure,
					// because it's possible that the user never used an old version of Lantern on this device. In either case, it's safe
					// to request to migrate the device ID, as the server will know whether or not the old-style device ID was already associated
					// with the current pro user.
					oldStyleDeviceID := deviceid.OldStyleDeviceID()
					if oldStyleDeviceID != app.settings.GetDeviceID() {
						log.Debugf("Attempting to migrate device ID from %v to %v", oldStyleDeviceID, app.settings.GetDeviceID())
						err := pro.MigrateDeviceID(app.settings, oldStyleDeviceID)
						if err != nil {
							errString := err.Error()
							if errString == "old-device-id-not-found" {
								log.Debugf("Could not migrate device id, not fatal: %v", err)
							} else {
								return log.Errorf("Could not migrate device id: %v", err)
							}
						} else {
							log.Debug("Successfully migrated device ID")
						}
						app.settings.SetMigratedDeviceIDForUserID(userID)
					}
				}
				_, err := pro.FetchUserData(app.settings)
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
		if user, known := pro.GetUserDataFast(app.settings.GetUserID()); known {
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
	pro.OnUserData(func(current *client.User, new *client.User) {
		b, _ := json.Marshal(new)
		log.Debugf("Sending updated user data to all clients: %s", string(b))
		service.Out <- new
	})
	return err
}
