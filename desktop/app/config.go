package app

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"sync"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7"
	fcommon "github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

const (
	defaultConfigDirPerm = 0750
)

type configService struct {
	service     *ws.Service
	listeners   []func(ConfigOptions)
	listenersMx sync.RWMutex
}

type ChatOptions struct {
	OnBoardingStatus     bool `json:"onBoardingStatus"`
	AcceptedTermsVersion int  `json:"acceptedTermsVersion"`
}

// ConfigOptions are the config options that Lantern is running with
type ConfigOptions struct {
	DevelopmentMode      bool                   `json:"developmentMode"`
	ReplicaAddr          string                 `json:"replicaAddr"`
	HttpProxyAddr        string                 `json:"httpProxyAddr"`
	SocksProxyAddr       string                 `json:"socksProxyAddr"`
	AuthEnabled          bool                   `json:"authEnabled"`
	ChatEnabled          bool                   `json:"chatEnabled"`
	SplitTunneling       bool                   `json:"splitTunneling"`
	HasSucceedingProxy   bool                   `json:"hasSucceedingProxy"`
	FetchedGlobalConfig  bool                   `json:"fetchedGlobalConfig"`
	FetchedProxiesConfig bool                   `json:"fetchedProxiesConfig"`
	Plans                []protos.Plan          `json:"plans"`
	PaymentMethods       []protos.PaymentMethod `json:"paymentMethods"`
	Devices              protos.Devices         `json:"devices"`
	SdkVersion           string                 `json:"sdkVersion"`
	AppVersion           string                 `json:"appVersion"`
	DeviceId             string                 `json:"deviceId"`
	ExpirationDate       string                 `json:"expirationDate"`
	Chat                 ChatOptions            `json:"chat"`
	ProxyAll             bool                   `json:"proxyAll"`
}

func (s *configService) StartService(channel ws.UIChannel) (err error) {
	s.service, err = channel.Register("config", nil)
	return err
}

func (s *configService) sendConfigOptions(cfg *ConfigOptions) {
	b, _ := json.Marshal(&cfg)
	log.Debugf("Sending config options to client %s", string(b))
	s.service.Out <- cfg
}

// AddListener adds a listener for any updates to the startup
func (s *configService) AddListener(f func(ConfigOptions)) {
	s.listenersMx.Lock()
	s.listeners = append(s.listeners, f)
	s.listenersMx.Unlock()
}

func (app *App) sendConfigOptions() {
	authEnabled := func(a *App) bool {
		authEnabled := a.IsFeatureEnabled(config.FeatureAuth)
		if ok, err := strconv.ParseBool(os.Getenv("ENABLE_AUTH_FEATURE")); err == nil && ok {
			authEnabled = true
		}
		log.Debugf("DEBUG: Auth enabled: %v", authEnabled)
		return authEnabled
	}
	ctx := context.Background()
	plans, _ := app.proClient.Plans(ctx)
	paymentMethods, _ := app.proClient.DesktopPaymentMethods(ctx)
	devices, _ := json.Marshal(app.devices())
	log.Debugf("DEBUG: Devices: %s", string(devices))
	log.Debugf("Expiration date: %s", app.settings.GetExpirationDate())

	app.configService.sendConfigOptions(&ConfigOptions{
		DevelopmentMode:      common.IsDevEnvironment(),
		AppVersion:           common.ApplicationVersion,
		ReplicaAddr:          "",
		HttpProxyAddr:        app.settings.GetAddr(),
		SocksProxyAddr:       app.settings.GetSOCKSAddr(),
		AuthEnabled:          authEnabled(app),
		ChatEnabled:          false,
		SplitTunneling:       false,
		HasSucceedingProxy:   app.HasSucceedingProxy(),
		Plans:                plans,
		PaymentMethods:       paymentMethods,
		FetchedGlobalConfig:  app.fetchedGlobalConfig.Load(),
		FetchedProxiesConfig: app.fetchedProxiesConfig.Load(),
		SdkVersion:           fcommon.LibraryVersion,
		DeviceId:             app.settings.GetDeviceID(),
		ExpirationDate:       app.settings.GetExpirationDate(),
		Devices:              app.devices(),
		ProxyAll:             app.settings.GetProxyAll(),
		Chat: ChatOptions{
			AcceptedTermsVersion: 0,
			OnBoardingStatus:     false,
		},
	})
}

// initializeAppConfig initializes application configuration and flags based on environment variables
func initializeAppConfig() (flashlight.Flags, error) {
	flags := flashlight.ParseFlags()
	if flags.Pprof {
		go startPprof("localhost:6060")
	}
	parseBoolEnv := func(key string, defaultValue bool) bool {
		val := os.Getenv(key)
		parsedValue, err := strconv.ParseBool(val)
		if err != nil {
			return defaultValue
		}
		return parsedValue
	}

	// helper to resolve CONFIG_DIR to an absolute path
	resolveConfigDir := func(dir string) string {
		if filepath.IsAbs(dir) {
			return dir
		}
		absPath, err := filepath.Abs(dir)
		if err != nil {
			return dir
		}
		return absPath
	}

	// Parse environment-based flags
	stickyConfig := parseBoolEnv("STICKY_CONFIG", false)
	readableConfig := parseBoolEnv("READABLE_CONFIG", true)
	configDir := os.Getenv("CONFIG_DIR")
	if configDir == "" {
		configDir = appdir.General(common.DefaultAppName)
		log.Debugf("CONFIG_DIR not set. Using default: %s", configDir)
	} else {
		configDir = resolveConfigDir(configDir)
	}
	if err := createDirIfNotExists(configDir, defaultConfigDirPerm); err != nil {
		return flags, fmt.Errorf("unable to create config directory %s: %v", configDir, err)
	}
	flags.StickyConfig = stickyConfig
	flags.ReadableConfig = readableConfig
	flags.ConfigDir = configDir

	log.Debugf("Config options: directory %v sticky %v readable %v", configDir,
		stickyConfig, readableConfig)
	return flags, nil
}
