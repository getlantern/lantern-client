package internalsdk

import (
	"fmt"
	"time"

	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
)

// createProClient creates a new instance of ProClient with the given client session information
func createProClient(session ClientSession, platform string) pro.ProClient {
	deviceID, _ := session.GetDeviceID()
	userID, _ := session.GetUserID()
	token, _ := session.GetToken()
	lang, _ := session.Locale()
	dialTimeout := 30 * time.Second
	if platform == "ios" {
		dialTimeout = 20 * time.Second
	}
	webclientOpts := &webclient.Opts{
		Timeout: dialTimeout,
		UserConfig: func() common.UserConfig {
			internalHeaders := map[string]string{
				common.PlatformHeader:   platform,
				common.AppVersionHeader: common.ApplicationVersion,
			}
			return common.NewUserConfig(
				common.DefaultAppName,
				deviceID,
				userID,
				token,
				internalHeaders,
				lang,
			)
		},
	}
	return pro.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), webclientOpts)
}
