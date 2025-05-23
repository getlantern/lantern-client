package app

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/errors"
	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight/v7"
	flashlightClient "github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/dialer"
	"github.com/getlantern/flashlight/v7/email"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/otel"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/osversion"
	"github.com/getlantern/profiling"
	"github.com/joho/godotenv"

	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/datacap"
	"github.com/getlantern/lantern-client/desktop/sentry"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

var (
	log       = golog.LoggerFor("lantern-client.app")
	startTime = time.Now()
)

func init() {
	autoupdate.Version = common.ApplicationVersion
	autoupdate.PublicKey = []byte(packagePublicKey)

}

// App is the core of the Lantern desktop application, managing components and configurations.
type App struct {
	hasExited            atomic.Bool      // Tracks if the app has exited.
	fetchedGlobalConfig  atomic.Bool      // Indicates if the global configuration was fetched.
	fetchedProxiesConfig atomic.Bool      // Tracks whether the proxy configuration was fetched.
	hasSucceedingProxy   atomic.Bool      // Tracks if a succeeding proxy is available.
	Flags                flashlight.Flags // Command-line flags passed to the app.
	configDir            string           // Directory for storing configuration files.
	exited               eventual.Value   // Signals when the app has exited.
	settings             *Settings        // User settings for the application.
	configService        *configService   // Config service used by the applicaiton.
	statsTracker         *statsTracker    // Tracks stats for service usage by the client.
	muExitFuncs          sync.RWMutex
	exitFuncs            []func()
	flashlight           *flashlight.Flashlight // Flashlight library for networking and proxying.
	authClient           auth.AuthClient        // Client for managing authentication.
	proClient            proclient.ProClient    // Client for managing interaction with the Pro server

	// Websocket-related settings
	websocketAddr string       // Address for WebSocket connections.
	ws            ws.UIChannel // UI channel for WebSocket communication.
	wsServer      *http.Server
	userCache     sync.Map // Cached user data.
	mu            sync.RWMutex
}

// NewApp creates a new desktop app that initializes the app and acts as a moderator between all desktop components.
func NewApp() (*App, error) {
	// filter macOS system arguments
	filterSystemArgs()

	cdir, flags, err := initializeAppConfig()
	if err != nil {
		return nil, err
	}

	return NewAppWithFlags(flags, cdir)
}

// NewAppWithFlags creates a new App instance with the given flags and configuration directory.
func NewAppWithFlags(flags flashlight.Flags, configDir string) (*App, error) {

	log.Debugf("Config directory %s sticky %v readable %v", configDir, flags.StickyConfig, flags.ReadableConfig)

	// Load application configuration from .env file
	err := godotenv.Load()
	if err != nil {
		log.Errorf("Error loading .env file: %v", err)
	} else {
		log.Debug("Successfully loaded .env file")
	}

	logging.EnableFileLogging(common.DefaultAppName, appdir.Logs(common.DefaultAppName))

	if shouldReportToSentry() {
		sentry.InitSentry(sentry.Opts{
			DSN:             common.SentryDSN,
			MaxMessageChars: common.SentryMaxMessageChars,
		})
	}
	golog.SetPrepender(logging.Timestamped)
	// Load settings and initialize trackers and services.
	ss := LoadSettings(configDir)
	statsTracker := NewStatsTracker()
	uc := userConfig(ss)

	app := &App{
		Flags:         flags,
		configDir:     configDir,
		exited:        eventual.NewValue(),
		settings:      ss,
		configService: &configService{},
		authClient:    auth.NewClient(fmt.Sprintf("https://%s", common.DFBaseUrl), uc),
		proClient:     proclient.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), uc),
		statsTracker:  statsTracker,
		ws:            ws.NewUIChannel(),
	}

	// Start the WebSocket server for UI communication.
	if err := app.serveWebsocket(); err != nil {
		return nil, err
	}
	golog.OnFatal(app.exitOnFatal)

	datacap.AddDataCapListener(func(hitDataCap bool) {
		statsTracker.SetHitDataCap(hitDataCap)
	})

	log.Debugf("Using configdir: %v", configDir)

	if e := app.configService.StartService(app.ws); e != nil {
		return nil, fmt.Errorf("unable to register config service: %q", e)
	}

	return app, nil
}

// Run creates a new instance of App, initializes necessary components, and starts running the application.
func (app *App) Run(ctx context.Context) error {
	go func() {
		app.Settings().SetCountry(geolookup.GetCountry(0))
		for <-geolookup.OnRefresh() {
			app.Settings().SetCountry(geolookup.GetCountry(0))
		}
	}()

	log.Debug(app.Flags)

	settings := app.Settings()

	// Check and apply the ProxyAll flag.
	if app.Flags.ProxyAll {
		settings.SetProxyAll(true)
	}

	// Determine the listen address for local HTTP and SOCKS proxies
	listenAddr := app.Flags.Addr
	if listenAddr == "" {
		listenAddr = settings.GetAddr()
	}
	if listenAddr == "" {
		listenAddr = defaultHTTPProxyAddress
	}

	socksAddr := app.Flags.SocksAddr
	if socksAddr == "" {
		socksAddr = settings.GetSOCKSAddr()
	}
	if socksAddr == "" {
		socksAddr = defaultSOCKSProxyAddress
	}

	if app.Flags.Timeout > 0 {
		go func() {
			time.AfterFunc(app.Flags.Timeout, func() {
				app.Exit(errors.New("No succeeding proxy got after running for %v, global config fetched: %v, proxies fetched: %v",
					app.Flags.Timeout, app.fetchedGlobalConfig.Load(), app.fetchedProxiesConfig.Load()))
			})
		}()
	}
	// Initialize flashlight
	flashlight, err := flashlight.New(
		common.DefaultAppName,
		common.ApplicationVersion,
		common.RevisionDate,
		app.configDir,
		app.Flags.VPN,
		func() bool { return settings.GetDisconnected() }, // check whether we're disconnected
		settings.GetProxyAll,
		func() bool { return false }, // on desktop, we do not allow private hosts
		settings.IsAutoReport,
		app.Flags.AsMap(),
		settings,
		app.statsTracker,
		app.IsPro,
		settings.GetLanguage,
		func(addr string) (string, error) { return addr, nil }, // no dnsgrab reverse lookups on desktop
		func(category, action, label string) {},                // Dummy analytics function
		flashlight.WithOnConfig(app.onConfigUpdate),
		flashlight.WithOnProxies(app.onProxiesUpdate),
		flashlight.WithOnSucceedingProxy(app.onSucceedingProxy),
	)
	if err != nil {
		return err
	}
	app.mu.Lock()
	app.flashlight = flashlight
	app.mu.Unlock()
	if err := app.beforeStart(ctx, listenAddr); err != nil {
		return err
	}

	go flashlight.Run(
		listenAddr,
		socksAddr,
		app.afterStart,
		func(err error) { _ = app.Exit(err) },
	)

	return nil
}

func (app *App) beforeStart(ctx context.Context, listenAddr string) error {
	log.Debug("Got first config")

	if app.Flags.CpuProfile != "" || app.Flags.MemProfile != "" {
		log.Debugf("Start profiling with cpu file %s and mem file %s", app.Flags.CpuProfile, app.Flags.MemProfile)
		finishProfiling := profiling.Start(app.Flags.CpuProfile, app.Flags.MemProfile)
		app.AddExitFunc("finish profiling", finishProfiling)
	}

	if err := setUpSysproxyTool(); err != nil {
		return err
	}

	if app.Flags.ClearProxySettings {
		// This is a workaround that attempts to fix a Windows-only problem where
		// Lantern was unable to clean the system's proxy settings before logging
		// off.
		//
		// See: https://github.com/getlantern/lantern/issues/2776
		log.Debug("Requested clearing of proxy settings")
		_, port, splitErr := net.SplitHostPort(listenAddr)
		if splitErr == nil && port != "0" {
			log.Debugf("Clearing system proxy settings for: %v", listenAddr)
			clearSysproxyFor(listenAddr)
		} else {
			log.Debugf("Can't clear proxy settings for: %v", listenAddr)
		}
		app.Exit(nil)
		os.Exit(0)
	}

	if e := app.Settings().StartService(app.ws); e != nil {
		return fmt.Errorf("unable to register settings service: %q", e)
	}

	isProUser := func() (bool, bool) {
		return app.IsProUser(context.Background(), app.UserConfig())
	}

	if err := app.statsTracker.StartService(app.ws); err != nil {
		log.Errorf("Unable to serve stats to UI: %v", err)
	}

	if err := datacap.ServeDataCap(app.ws, func() string {
		return "/img/lantern_logo.png"
	}, func() string { return "" }, isProUser); err != nil {
		log.Errorf("Unable to serve bandwidth to UI: %v", err)
	}

	if err := app.serveConnectionStatus(app.ws); err != nil {
		log.Errorf("Unable to serve connection status: %v", err)
	}

	if err := app.servePro(app.ws); err != nil {
		log.Errorf("Unable to serve pro data to UI: %v", err)
	}

	app.AddExitFunc("stopping loconf scanner", LoconfScanner(app.settings, app.configDir, 4*time.Hour, isProUser, func() string {
		return "/img/lantern_logo.png"
	}))

	return nil
}

func (app *App) afterStart(cl *flashlightClient.Client) {
	app.sendConfigOptions()
	ctx := context.Background()
	// Fetch or create a user in the background
	go app.fetchOrCreateUser(ctx)
	if app.Settings().GetUserID() != 0 {
		// fetch plan only if user is created
		go app.proClient.DesktopPaymentMethods(ctx)
	}

	go app.fetchDeviceLinkingCode(ctx)

	// Listen for changes to the system proxy setting
	app.OnSettingChange(SNSystemProxy, func(val interface{}) {
		enable := val.(bool)
		if enable {
			app.SysproxyOn()
		} else {
			app.SysProxyOff()
		}
	})
	// Add exit function to turn off the system proxy when the app exits
	app.AddExitFunc("turning off system proxy", func() {
		app.SysProxyOff()
	})
	app.AddExitFunc("flushing to opentelemetry", otel.Stop)
	if addr, ok := flashlightClient.Addr(6 * time.Second); ok {
		app.Settings().SetAddr(addr.(string))
	} else {
		log.Errorf("Couldn't retrieve HTTP proxy addr in time")
	}
	if socksAddr, ok := flashlightClient.Socks5Addr(6 * time.Second); ok {
		app.Settings().SetSOCKSAddr(socksAddr.(string))
	} else {
		log.Errorf("Couldn't retrieve SOCKS proxy addr in time")
	}
}

// IsFeatureEnabled checks whether or not the given feature is enabled by flashlight
func (app *App) IsFeatureEnabled(feature string) bool {
	if app.flashlight == nil {
		return false
	}
	return app.flashlight.EnabledFeatures()[feature]
}

// Connect turns on proxying
func (app *App) Connect() {
	ops.Begin("connect").End()
	app.Settings().SetDisconnected(false)
}

// Disconnect turns off proxying
func (app *App) Disconnect() {
	ops.Begin("disconnect").End()
	app.Settings().SetDisconnected(true)
}

// GetLanguage returns the user language
func (app *App) GetLanguage() string {
	return app.Settings().GetLanguage()
}

// SetLanguage sets the user language
func (app *App) SetLanguage(lang string) {
	app.Settings().SetLanguage(lang)
	log.Debugf("Setting language to %v", lang)
	app.SendMessageToUI("pro", map[string]interface{}{
		"language": lang,
	})
}

func (app *App) SetUserLoggedIn(value bool) {
	app.Settings().SetUserLoggedIn(value)
	app.SendMessageToUI("pro", map[string]interface{}{
		"login": value,
	})
}

func (app *App) IsUserLoggedIn() bool {
	return app.Settings().IsUserLoggedIn()

}

// Create func that send message to UI
func (app *App) SendMessageToUI(service string, message interface{}) {
	if app.ws != nil {
		app.ws.SendMessage(service, message)
	}
}

// OnSettingChange sets a callback cb to get called when attr is changed from server.
// When calling multiple times for same attr, only the last one takes effect.
func (app *App) OnSettingChange(attr SettingName, cb func(interface{})) {
	app.Settings().OnChange(attr, cb)
}

// OnStatsChange adds a listener for Stats changes.
func (app *App) OnStatsChange(fn func(stats.Stats)) {
	app.statsTracker.AddListener(fn)
}

func (app *App) SendConfig() {
	app.sendConfigOptions()
}

func (app *App) onConfigUpdate(cfg *config.Global, src config.Source) {
	log.Debugf("[Startup Desktop] Got config update from %v", src)
	autoupdate.Configure(cfg.UpdateServerURL, cfg.AutoUpdateCA, func() string {
		return "/img/lantern_logo.png"
	})
	app.fetchedGlobalConfig.Store(true)
	app.sendConfigOptions()
	email.SetDefaultRecipient(cfg.ReportIssueEmail)
}

func (app *App) onProxiesUpdate(proxies []dialer.ProxyDialer, src config.Source) {
	log.Debugf("[Startup Desktop] Got proxies update from %v", src)
	app.fetchedProxiesConfig.Store(true)
	app.hasSucceedingProxy.Store(true)
	app.sendConfigOptions()
}

func (app *App) onSucceedingProxy() {
	app.hasSucceedingProxy.Store(true)
	log.Debugf("[Startup Desktop] onSucceedingProxy")
}

// HasSucceedingProxy returns whether or not the app is currently configured with any succeeding proxies
func (app *App) HasSucceedingProxy() bool {
	return app.hasSucceedingProxy.Load()
}

func (app *App) GetHasConfigFetched() bool {
	return app.fetchedGlobalConfig.Load()
}

func (app *App) GetHasProxyFetched() bool {
	return app.fetchedProxiesConfig.Load()
}

func (app *App) GetOnSuccess() bool {
	return app.HasSucceedingProxy()
}

// AddExitFunc adds a function to be called before the application exits.
func (app *App) AddExitFunc(label string, exitFunc func()) {
	app.muExitFuncs.Lock()
	app.exitFuncs = append(app.exitFuncs, func() {
		log.Debugf("Processing exit function: %v", label)
		exitFunc()
		log.Debugf("Done processing exit function: %v", label)
	})
	app.muExitFuncs.Unlock()
}

// Exit tells the application to exit, optionally supplying an error that caused
// the exit. Returns true if the app is actually exiting, false if exit has
// already been requested.
func (app *App) Exit(err error) bool {
	if app.hasExited.CompareAndSwap(false, true) {
		app.doExit(err)
		return true
	}
	return false
}

func (app *App) doExit(err error) {
	if err != nil {
		log.Errorf("Exiting app %d(%d) because of %v", os.Getpid(), os.Getppid(), err)
		if shouldReportToSentry() {
			sentry.OnExit(err)
		}
	} else {
		log.Debugf("Exiting app %d(%d)", os.Getpid(), os.Getppid())
	}
	recordStopped()
	defer func() {
		app.exited.Set(err)
		log.Debugf("Finished exiting app %d(%d)", os.Getpid(), os.Getppid())
	}()

	ch := make(chan struct{})
	go func() {
		app.runExitFuncs()
		close(ch)
	}()
	t := time.NewTimer(10 * time.Second)
	select {
	case <-ch:
		log.Debug("Finished running exit functions")
	case <-t.C:
		log.Debug("Timeout running exit functions, quit anyway")
	}
	if err := logging.Close(); err != nil {
		log.Errorf("Error closing log: %v", err)
	}
}

func (app *App) runExitFuncs() {
	var wg sync.WaitGroup
	// call plain exit funcs in parallel
	app.muExitFuncs.RLock()
	log.Debugf("Running %d exit functions", len(app.exitFuncs))
	wg.Add(len(app.exitFuncs))
	for _, f := range app.exitFuncs {
		go func(f func()) {
			f()
			wg.Done()
		}(f)
	}
	app.muExitFuncs.RUnlock()
	wg.Wait()
}

// WaitForExit waits for a request to exit the application.
func (app *App) WaitForExit() error {
	err, _ := app.exited.Get(-1)
	if err == nil {
		return nil
	}
	return err.(error)
}

// is only used in the panicwrap parent process.
func (app *App) LogPanicAndExit(msg string) {
	sentry.LogPanic(msg)
}

func (app *App) exitOnFatal(err error) {
	_ = logging.Close()
	app.Exit(err)
}

// IsPro indicates whether or not the app is pro
func (app *App) IsPro() bool {
	isPro, _ := app.IsProUserFast()
	return isPro
}

func (app *App) fetchOrCreateUser(ctx context.Context) {
	ss := app.Settings()
	lang := ss.GetLanguage()
	if lang == "" {
		// set default language
		ss.SetLanguage("en_us")
	}
	if userID := ss.GetUserID(); userID == 0 {
		ss.SetUserFirstVisit(true)
		app.proClient.RetryCreateUser(ctx, app, 5*time.Minute)
	} else {
		app.RefreshUserData()
	}
}

func (app *App) fetchDeviceLinkingCode(ctx context.Context) (string, error) {
	resp, err := app.proClient.LinkCodeRequest(ctx, deviceName())
	if err != nil {
		return "", errors.New("Could not create new Pro user: %v", err)
	}
	app.SendMessageToUI("pro", map[string]interface{}{
		"type":              "pro",
		"deviceLinkingCode": resp.Code,
	})
	return resp.Code, nil
}

func deviceName() string {
	deviceName, _ := osversion.GetHumanReadable()
	return deviceName
}

func (app *App) currentDevice() *protos.Device {
	deviceID := app.Settings().GetDeviceID()
	return &protos.Device{
		Id:   deviceID,
		Name: deviceName(),
	}
}

func (app *App) devices() *protos.Devices {
	devices := []*protos.Device{app.currentDevice()}
	user, found := app.UserData()
	if !found || user == nil || user.Devices == nil {
		return &protos.Devices{
			Devices: devices,
		}
	}
	devices = append(devices, user.Devices...)
	log.Debugf("Devices: %v", devices)
	return &protos.Devices{
		Devices: devices,
	}
}

// ProxyAddrReachable checks if Lantern's HTTP proxy responds with the correct status
// within the deadline.
func (app *App) ProxyAddrReachable(ctx context.Context) error {
	req, err := http.NewRequest("GET", "http://"+app.Settings().GetAddr(), nil)
	if err != nil {
		return err
	}
	resp, err := http.DefaultClient.Do(req.WithContext(ctx))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusBadRequest {
		return fmt.Errorf("unexpected HTTP status %v", resp.StatusCode)
	}
	return nil
}

func recordStopped() {
	ops.Begin("client_stopped").
		SetMetricSum("uptime", time.Since(startTime).Seconds()).
		End()
}

// shouldReportToSentry determines if we should report errors/panics to Sentry
func shouldReportToSentry() bool {
	return !common.IsDevEnvironment()
}

func (app *App) Settings() *Settings {
	app.mu.RLock()
	defer app.mu.RUnlock()
	return app.settings
}

func (app *App) AuthClient() auth.AuthClient {
	app.mu.RLock()
	defer app.mu.RUnlock()
	return app.authClient
}

func (app *App) ProClient() proclient.ProClient {
	app.mu.RLock()
	defer app.mu.RUnlock()
	return app.proClient
}

// Client session methods
// this method get call when user is being created first time
func (app *App) FetchUserData() error {
	go app.proClient.UserData(context.Background())
	go app.proClient.FetchPaymentMethodsAndCache(context.Background())
	//Update UI
	app.sendConfigOptions()
	return nil
}

func (app *App) GetDeviceID() (string, error) {
	return app.Settings().GetDeviceID(), nil
}

func (app *App) GetUserFirstVisit() (bool, error) {
	return app.Settings().GetUserFirstVisit(), nil
}

func (app *App) SetUserIDAndToken(id int64, token string) error {
	app.Settings().SetUserIDAndToken(id, token)
	return nil
}

func (app *App) SetProUser(pro bool) error {
	app.Settings().SetProUser(pro)
	return nil
}

func (app *App) SetEmailAddress(email string) error {
	app.Settings().SetEmailAddress(email)
	return nil
}

func (app *App) SetReferralCode(referral string) error {
	app.Settings().SetReferralCode(referral)
	return nil
}

func (app *App) SetExpiration(exp int64) error {
	app.Settings().SetExpiration(exp)
	return nil
}
