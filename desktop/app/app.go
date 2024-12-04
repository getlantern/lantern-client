package app

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"net"
	"net/http"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"github.com/getsentry/sentry-go"

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

	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/datacap"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
)

var (
	log       = golog.LoggerFor("lantern-desktop.app")
	startTime = time.Now()
)

func init() {
	autoupdate.Version = common.ApplicationVersion
	autoupdate.PublicKey = []byte(packagePublicKey)

}

// App is the core of the Lantern desktop application, in the form of a library.
type App struct {
	hasExited            atomic.Bool
	fetchedGlobalConfig  atomic.Bool
	fetchedProxiesConfig atomic.Bool
	hasSucceedingProxy   atomic.Bool

	Flags         flashlight.Flags
	configDir     string
	exited        eventual.Value
	settings      *settings.Settings
	configService *configService
	statsTracker  *statsTracker

	muExitFuncs sync.RWMutex
	exitFuncs   []func()

	translations eventual.Value

	flashlight *flashlight.Flashlight

	authClient auth.AuthClient
	proClient  proclient.ProClient

	selectedTab Tab

	connectionStatusCallbacks []func(isConnected bool)

	// Websocket-related settings
	websocketAddr string
	ws            ws.UIChannel

	cachedUserData sync.Map

	onUserData []func(current *protos.User, new *protos.User)

	mu sync.RWMutex
}

// NewApp creates a new desktop app that initializes the app and acts as a moderator between all desktop components.
func NewApp() *App {
	// initialize app config and flags based on environment variables
	flags, err := initializeAppConfig()
	if err != nil {
		log.Fatalf("failed to initialize app config: %w", err)
	}
	return NewAppWithFlags(flags, flags.ConfigDir)
}

// NewAppWithFlags creates a new instance of App initialized with the given flags and configDir
func NewAppWithFlags(flags flashlight.Flags, configDir string) *App {
	if configDir == "" {
		log.Debug("Config directory is empty, using default location")
		configDir = appdir.General(common.DefaultAppName)
	}
	ss := settings.LoadSettings(configDir)
	statsTracker := NewStatsTracker()
	app := &App{
		Flags:                     flags,
		configDir:                 configDir,
		exited:                    eventual.NewValue(),
		settings:                  ss,
		connectionStatusCallbacks: make([]func(isConnected bool), 0),
		selectedTab:               VPNTab,
		configService:             new(configService),
		statsTracker:              statsTracker,
		translations:              eventual.NewValue(),
		ws:                        ws.NewUIChannel(),
	}

	if err := app.serveWebsocket(); err != nil {
		log.Error(err)
	}
	golog.OnFatal(app.exitOnFatal)

	app.onProStatusChange(func(isPro bool) {
		statsTracker.SetIsPro(isPro)
	})

	datacap.AddDataCapListener(func(hitDataCap bool) {
		statsTracker.SetHitDataCap(hitDataCap)
	})

	log.Debugf("Using configdir: %v", configDir)

	app.translations.Set(os.DirFS("locale/translation"))

	if e := app.configService.StartService(app.ws); e != nil {
		app.Exit(fmt.Errorf("unable to register config service: %q", e))
	}

	return app
}

// Run starts the app.
func (app *App) Run(ctx context.Context) {
	golog.OnFatal(app.exitOnFatal)
	go func() {
		for <-geolookup.OnRefresh() {
			app.Settings().SetCountry(geolookup.GetCountry(0))
		}
	}()

	// Run below in separate goroutine as config.Init() can potentially block when Lantern runs
	// for the first time. User can still quit Lantern through systray menu when it happens.
	go func() {
		log.Debug(app.Flags)
		userConfig := func() common.UserConfig {
			return settings.UserConfig(app.Settings())
		}
		proClient := proclient.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), &webclient.Opts{
			UserConfig: userConfig,
		})
		authClient := auth.NewClient(fmt.Sprintf("https://%s", common.DFBaseUrl), userConfig)

		app.mu.Lock()
		app.proClient = proClient
		app.authClient = authClient
		app.mu.Unlock()

		settings := app.Settings()

		if app.Flags.ProxyAll {
			// If proxyall flag was supplied, force proxying of all
			settings.SetProxyAll(true)
		}

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
		var err error
		app.flashlight, err = flashlight.New(
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
			// Dummy analytics function
			func(category, action, label string) {},
			flashlight.WithOnConfig(app.onConfigUpdate),
			flashlight.WithOnProxies(app.onProxiesUpdate),
			flashlight.WithOnSucceedingProxy(app.onSucceedingProxy),
		)
		if err != nil {
			app.Exit(err)
			return
		}
		app.beforeStart(ctx, listenAddr)

		app.flashlight.Run(
			listenAddr,
			socksAddr,
			app.afterStart,
			func(err error) { _ = app.Exit(err) },
		)
	}()
}

// IsFeatureEnabled checks whether or not the given feature is enabled by flashlight
func (app *App) IsFeatureEnabled(feature string) bool {
	if app.flashlight == nil {
		return false
	}
	return app.flashlight.EnabledFeatures()[feature]
}

func (app *App) beforeStart(ctx context.Context, listenAddr string) {
	log.Debug("Got first config")

	if app.Flags.CpuProfile != "" || app.Flags.MemProfile != "" {
		log.Debugf("Start profiling with cpu file %s and mem file %s", app.Flags.CpuProfile, app.Flags.MemProfile)
		finishProfiling := profiling.Start(app.Flags.CpuProfile, app.Flags.MemProfile)
		app.AddExitFunc("finish profiling", finishProfiling)
	}

	if err := setUpSysproxyTool(); err != nil {
		app.Exit(err)
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

	if e := app.settings.StartService(app.ws); e != nil {
		app.Exit(fmt.Errorf("unable to register settings service: %q", e))
		return
	}

	isProUser := func() (bool, bool) {
		return app.IsProUser(context.Background(), settings.UserConfig(app.Settings()))
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

	app.AddExitFunc("stopping loconf scanner", LoconfScanner(app.settings, app.configDir, 4*time.Hour, isProUser, func() string {
		return "/img/lantern_logo.png"
	}))
	//app.AddExitFunc("stopping notifier", notifier.NotificationsLoop(app.analyticsSession))
}

// Connect turns on proxying
func (app *App) Connect() {
	ops.Begin("connect").End()
	app.settings.SetDisconnected(false)
}

// Disconnect turns off proxying
func (app *App) Disconnect() {
	ops.Begin("disconnect").End()
	app.settings.SetDisconnected(true)
}

// GetLanguage returns the user language
func (app *App) GetLanguage() string {
	return app.settings.GetLanguage()
}

// SetLanguage sets the user language
func (app *App) SetLanguage(lang string) {
	app.settings.SetLanguage(lang)
	log.Debugf("Setting language to %v", lang)
	app.SendMessageToUI("pro", map[string]interface{}{
		"language": lang,
	})
}

func (app *App) SetUserLoggedIn(value bool) {
	app.settings.SetUserLoggedIn(value)
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

func (app *App) SendUpdateUserDataToUI() {
	user, found := app.GetUserData(app.Settings().GetUserID())
	if !found {
		return
	}
	if user.UserLevel == "" {
		user.UserLevel = "free"
	}
	b, _ := json.Marshal(user)
	log.Debugf("SendUpdateUserDataToUI: %s", string(b))
	app.ws.SendMessage("pro", user)
}

// OnSettingChange sets a callback cb to get called when attr is changed from server.
// When calling multiple times for same attr, only the last one takes effect.
func (app *App) OnSettingChange(attr settings.SettingName, cb func(interface{})) {
	app.settings.OnChange(attr, cb)
}

// OnStatsChange adds a listener for Stats changes.
func (app *App) OnStatsChange(fn func(stats.Stats)) {
	app.statsTracker.AddListener(fn)
}

func (app *App) afterStart(cl *flashlightClient.Client) {
	ctx := context.Background()
	go app.fetchOrCreateUser(ctx)
	go app.proClient.DesktopPaymentMethods(ctx)
	go app.fetchDeviceLinkingCode(ctx)

	app.OnSettingChange(settings.SNSystemProxy, func(val interface{}) {
		enable := val.(bool)
		if enable {
			app.SysproxyOn()
		} else {
			app.SysProxyOff()
		}
	})

	app.AddExitFunc("turning off system proxy", func() {
		app.SysProxyOff()
	})
	app.AddExitFunc("flushing to opentelemetry", otel.Stop)
	if addr, ok := flashlightClient.Addr(6 * time.Second); ok {
		app.settings.SetAddr(addr.(string))
	} else {
		log.Errorf("Couldn't retrieve HTTP proxy addr in time")
	}
	if socksAddr, ok := flashlightClient.Socks5Addr(6 * time.Second); ok {
		app.settings.SetSOCKSAddr(socksAddr.(string))
	} else {
		log.Errorf("Couldn't retrieve SOCKS proxy addr in time")
	}
	if err := app.servePro(app.ws); err != nil {
		log.Errorf("Unable to serve pro data to UI: %v", err)
	}
	// send configs to UI
	app.SendMessageToUI("pro", map[string]interface{}{
		"login": app.settings.IsUserLoggedIn(),
	})
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
		if ShouldReportToSentry() {
			sentry.ConfigureScope(func(scope *sentry.Scope) {
				scope.SetLevel(sentry.LevelFatal)
			})

			sentry.CaptureException(err)
			if result := sentry.Flush(common.SentryTimeout); !result {
				log.Error("Flushing to Sentry timed out")
			}
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
	sentry.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetLevel(sentry.LevelFatal)
	})

	sentry.CaptureMessage(msg)
	if result := sentry.Flush(common.SentryTimeout); !result {
		log.Error("Flushing to Sentry timed out")
	}
}

func (app *App) exitOnFatal(err error) {
	_ = logging.Close()
	app.Exit(err)
}

// IsPro indicates whether or not the app is pro
func (app *App) IsPro() bool {
	isPro, _ := app.IsProUserFast(settings.UserConfig(app.Settings()))
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
		app.proClient.UpdateUserData(ctx, app)
	}
}

func (app *App) fetchDeviceLinkingCode(ctx context.Context) (string, error) {
	deviceName := func() string {
		deviceName, _ := osversion.GetHumanReadable()
		return deviceName
	}
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

func (app *App) devices() protos.Devices {
	user, found := app.GetUserData(app.Settings().GetUserID())

	if !found && user == nil {
		return protos.Devices{}
	}
	log.Debugf("Devices: %v", user.Devices)
	return protos.Devices{
		Devices: user.Devices,
	}
}

// ProxyAddrReachable checks if Lantern's HTTP proxy responds with the correct status
// within the deadline.
func (app *App) ProxyAddrReachable(ctx context.Context) error {
	req, err := http.NewRequest("GET", "http://"+app.settings.GetAddr(), nil)
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

// ShouldReportToSentry determines if we should report errors/panics to Sentry
func ShouldReportToSentry() bool {
	return !common.IsDevEnvironment()
}

// GetTranslations accesses translations with the given filename
func (app *App) GetTranslations(filename string) ([]byte, error) {
	log.Tracef("Accessing translations %v", filename)
	tr, ok := app.translations.Get(30 * time.Second)
	if !ok || tr == nil {
		return nil, fmt.Errorf("could not get traslation for file name: %v", filename)
	}
	f, err := tr.(fs.FS).Open(filename)
	if err != nil {
		return nil, fmt.Errorf("could not get traslation for file name: %v, %w", filename, err)
	}
	return io.ReadAll(f)
}

func (app *App) Settings() *settings.Settings {
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
func (app *App) FetchUserData() error {
	go app.proClient.PaymentMethodsCache(context.Background())
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

func (app *App) SetReferralCode(referral string) error {
	app.Settings().SetReferralCode(referral)
	return nil
}

func (app *App) SetExpiration(exp int64) error {
	app.Settings().SetExpiration(exp)
	return nil
}
