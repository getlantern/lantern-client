package internalsdk

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/getlantern/autoupdate"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/lantern-client/internalsdk/common"
)

var (
	// XXX mobile does not respect the autoupdate global config
	updateClient = &http.Client{Transport: proxied.ChainedThenFrontedWith("")}
)

// DeviceInfo provides information about a device for sending with ops when
// downloading and installing auto-updates
type DeviceInfo interface {
	DeviceID() string
	Model() string
	Hardware() string
	SdkVersion() int
	UserID() string
}

// CheckForUpdates checks to see if a new version of Lantern is available
func CheckForUpdates(deviceInfo DeviceInfo) (string, error) {
	return checkForUpdates(buildUpdateCfg(), deviceInfo)
}

func checkForUpdates(cfg *autoupdate.Config, deviceInfo DeviceInfo) (string, error) {
	op := ops.Begin("check_update").
		Set("user_id", deviceInfo.UserID()).
		Set("device_id", deviceInfo.DeviceID()).
		Set("current_version", cfg.CurrentVersion)
	defer op.End()
	updateURL, err := autoupdate.CheckMobileUpdate(cfg)
	if err != nil {
		return "", op.FailIf(log.Errorf("Error checking for update: %v", err))
	}
	return updateURL, nil
}

func deviceOps(name string, deviceInfo DeviceInfo) *ops.Op {
	return ops.Begin(name).
		Set("user_id", deviceInfo.UserID()).
		Set("device_id", deviceInfo.DeviceID()).
		Set("model", deviceInfo.Model()).
		Set("hardware", deviceInfo.Hardware()).
		Set("sdk_version", deviceInfo.SdkVersion())
}

// DownloadUpdate downloads the latest APK from the given url to the apkPath
// file destination.
func DownloadUpdate(deviceInfo DeviceInfo, url, apkPath string, updater Updater) bool {
	op := deviceOps("autoupdate_download", deviceInfo)
	defer op.End()
	err := autoupdate.UpdateMobile(url, apkPath, updater, updateClient)
	if err != nil {
		op.FailIf(log.Errorf("Error downloading update: %v", err))
		return false
	}
	return true
}

// InstallFinished is called after an update successfully installs or fails to
// and records ops related to it
func InstallFinished(deviceInfo DeviceInfo, success bool) {
	op := deviceOps("autoupdate_install", deviceInfo).
		Set("success", success)
	op.End()
}

func buildUpdateCfg() *autoupdate.Config {
	return &autoupdate.Config{
		CurrentVersion: common.ApplicationVersion,
		URL:            fmt.Sprintf("%s/update/%s", common.UpdateServerURL, strings.ToLower(common.DefaultAppName)),
		HTTPClient:     updateClient,
		PublicKey:      []byte(autoupdate.PackagePublicKey),
	}
}

// Get the version number of the Go library.
func SDKVersion() string {
	return common.LibraryVersion
}
