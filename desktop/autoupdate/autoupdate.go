package autoupdate

import (
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/getlantern/autoupdate"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/golog"
	"github.com/getlantern/i18n"
	notify "github.com/getlantern/notifier"

	"github.com/getlantern/lantern-client/desktop/notifier"
)

var (
	log                = golog.LoggerFor("lantern-desktop.autoupdate")
	updateServerURL    = common.UpdateServerURL
	PublicKey          = []byte(autoupdate.PackagePublicKey)
	Version            string
	translationAppName = strings.ToUpper(common.DefaultAppName)

	cfgMutex           sync.RWMutex
	watchForUpdateOnce sync.Once
	fnIconURL          func() string
)

// Configure sets the CA certificate to pin for the TLS auto-update connection.
func Configure(updateURL, updateCA string, iconURL func() string) {
	setUpdateURL(updateURL)
	fnIconURL = iconURL
	enableAutoupdate()
}

func setUpdateURL(url string) {
	if url == "" {
		return
	}
	cfgMutex.Lock()
	defer cfgMutex.Unlock()
	updateServerURL = url
}

func getUpdateURL() string {
	cfgMutex.RLock()
	defer cfgMutex.RUnlock()
	return fmt.Sprintf("%s/%s/%s", strings.TrimRight(updateServerURL, "/"), "update", strings.ToLower(common.DefaultAppName))
}

func enableAutoupdate() {
	watchForUpdateOnce.Do(func() {
		go watchForUpdate()
	})
}

func CheckUpdates() (string, error) {
	return autoupdate.CheckMobileUpdate(&autoupdate.Config{
		CurrentVersion: Version,
		URL:            getUpdateURL(),
		HTTPClient:     common.GetHTTPClient(),
		PublicKey:      PublicKey,
	})
}

func watchForUpdate() {
	log.Debugf("Software version: %s", Version)
	for {
		newVersion, err := autoupdate.ApplyNext(&autoupdate.Config{
			CurrentVersion: Version,
			CheckInterval:  4 * time.Hour,
			URL:            getUpdateURL(),
			PublicKey:      PublicKey,
			HTTPClient:     common.GetHTTPClient(),
		})
		if err == nil {
			notifyUser(newVersion)
			log.Debugf("Got update for version %s", newVersion)
		} else {
			// unrecoverable error which tends to happen again
			log.Error(err)
		}
		// At this point we either updated the binary or failed to recover from a
		// update error, let's wait a bit longer before looking for another update.
		time.Sleep(24 * time.Hour)
	}
}

func notifyUser(newVersion string) {
	note := &notify.Notification{
		Title:      i18n.T("BACKEND_AUTOUPDATED_TITLE", i18n.T(translationAppName), newVersion),
		Message:    i18n.T("BACKEND_AUTOUPDATED_MESSAGE", i18n.T(translationAppName), newVersion, i18n.T(translationAppName)),
		IconURL:    fnIconURL(),
		ClickLabel: i18n.T("BACKEND_CLICK_LABEL_GOT_IT"),
	}
	if !notifier.ShowNotification(note, "autoupdate-notification") {
		log.Debug("Unable to show autoupdate notification")
	}
}
