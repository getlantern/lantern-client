package internalsdk

import (
	"fmt"
	"net"
	"strconv"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/lantern-client/internalsdk/common"
)

func runOniOS(configDir, locale string, settings Settings, session panickingSession) {
	// Set home directory prior to starting Lantern
	appdir.SetHomeDir(configDir)

	grabber, err := initDnsGrab(configDir, session)
	if err != nil {
		return
	}
	log.Debugf("Starting lantern: configDir %s locale %s sticky config %t",
		configDir, locale, settings.StickyConfig())
	httpProxyAddr := fmt.Sprintf("%s:%d",
		settings.GetHttpProxyHost(),
		settings.GetHttpProxyPort())
	userConfig := newUserConfig(session)
	var runner *flashlight.Flashlight
	runner, err = flashlight.New(
		common.DefaultAppName,
		common.ApplicationVersion,
		common.RevisionDate,
		configDir,                    // place to store lantern configuration
		false,                        // don't enable vpn mode for Android (VPN is handled in Java layer)
		func() bool { return false }, // always connected
		func() bool { return true },
		func() bool { return false }, // do not proxy private hosts on Android
		// TODO: allow configuring whether or not to enable reporting (just like we
		// already have in desktop)
		func() bool { return true }, // auto report
		map[string]interface{}{},
		func(cfg *config.Global, src config.Source) {
			session.UpdateAdSettings(&adSettings{cfg.AdSettings})
		}, // onConfigUpdate
		nil, // onProxiesUpdate
		userConfig,
		NewStatsTracker(session),
		session.IsProUser,
		func() string { return "" }, // only used for desktop
		reverseDns(grabber),
		func(category, action, label string) {},
	)
	if err != nil {
		log.Fatalf("failed to start flashlight: %v", err)
	}

	runner.Run(
		httpProxyAddr, // listen for HTTP on provided address
		"127.0.0.1:0", // listen for SOCKS on random address
		func(c *client.Client) {
			clEventual.Set(c)
		},
		nil, // onError
	)
}

// StartService is starts the Lantern service on iOS
func StartService(s *SessionModel, configDir string, locale string, settings Settings) {
	session := &panickingSessionImpl{s}
	startOnce.Do(func() {
		go runOniOS(locale, configDir, settings, session)
	})
}

func HTTPProxyPort() int {
	if addr, ok := client.Addr(6 * time.Second); ok {
		if _, p, err := net.SplitHostPort(addr.(string)); err == nil {
			port, _ := strconv.Atoi(p)
			return port
		}
	}
	log.Errorf("Couldn't retrieve HTTP proxy addr in time")
	return 0
}
