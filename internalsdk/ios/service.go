package ios

import (
	"fmt"
	"net"
	"path/filepath"
	"strconv"
	"sync"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/bandit"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/lantern-client/internalsdk"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/yaml"
)

var (
	clEventual = eventual.NewValue()
	startOnce  sync.Once
)

type LanternService struct {
	memoryAvailable int64
	sessionModel    *internalsdk.SessionModel
}

func NewService(sessionModel *internalsdk.SessionModel) *LanternService {
	return &LanternService{
		sessionModel: sessionModel,
	}
}

func (s *LanternService) Start(configDir string, locale string, settings internalsdk.Settings) {
	optimizeMemoryUsage(&s.memoryAvailable)
	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
	session := internalsdk.NewPanickingSession(s.sessionModel)
	startOnce.Do(func() {
		go run(configDir, locale, settings, session)
	})
}

func run(configDir, locale string, settings internalsdk.Settings, session internalsdk.PanickingSession) {

	log.Debugf("Starting lantern: configDir %s locale %s sticky config %t",
		configDir, locale, settings.StickyConfig())

	// Set home directory prior to starting Lantern
	appdir.SetHomeDir(configDir)

	grabber, err := internalsdk.InitDnsGrab(configDir, session)
	if err != nil {
		log.Error(err)
		return
	}

	httpProxyAddr := fmt.Sprintf("%s:%d",
		settings.GetHttpProxyHost(),
		settings.GetHttpProxyPort())
	var runner *flashlight.Flashlight
	runner, err = flashlight.New(
		common.DefaultAppName,
		common.ApplicationVersion,
		common.RevisionDate,
		configDir,                    // place to store lantern configuration
		false,                        // don't enable vpn mode for iOS (VPN is handled in the Swift layer)
		func() bool { return false }, // always connected
		func() bool { return true },
		func() bool { return false }, // do not proxy private hosts on iOS
		// TODO: allow configuring whether or not to enable reporting (just like we
		// already have in desktop)
		func() bool { return true }, // auto report
		map[string]interface{}{},
		func(cfg *config.Global, src config.Source) {
			b, err := yaml.Marshal(cfg)
			if err != nil {
				log.Errorf("Unable to marshal user config: %v", err)
			} else {
				log.Debugf("Got new global config %s", string(b))
				//cf.saveConfig("global.yaml", b)
			}
		}, // onConfigUpdate
		func(proxies []bandit.Dialer, src config.Source) {
			/*if src == config.Fetched {
				if b, err := yaml.Marshal(proxies); err != nil {
					log.Debugf("Writing proxies to file %s", string(b))
					saveConfig(configDir, "proxies.yaml", b)
				}
			}*/
		}, // onProxiesUpdate
		internalsdk.NewUserConfig(session),
		internalsdk.NewStatsTracker(session),
		session.IsProUser,
		func() string { return "" }, // only used for desktop
		internalsdk.ReverseDns(grabber),
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
