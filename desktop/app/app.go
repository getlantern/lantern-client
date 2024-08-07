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
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/getsentry/sentry-go"

	"github.com/getlantern/errors"
	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/bandit"
	"github.com/getlantern/flashlight/v7/browsers/simbrowser"
	flashlightClient "github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/email"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/otel"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/i18n"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/profiling"

	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
)

var (
	log                = golog.LoggerFor("lantern-desktop.app")
	startTime          = time.Now()
	translationAppName = strings.ToUpper(common.DefaultAppName)
)

func init() {
	autoupdate.Version = common.ApplicationVersion
	autoupdate.PublicKey = []byte(packagePublicKey)

}

// App is the core of the Lantern desktop application, in the form of a library.
type App struct {
	hasExited            int64
	fetchedGlobalConfig  int32
	fetchedProxiesConfig int32
	hasSucceedingProxy   int32

	Flags        flashlight.Flags
	configDir    string
	settings     *settings.Settings
	statsTracker stats.Tracker

	muExitFuncs sync.RWMutex
	exitFuncs   []func()

	translations eventual.Value

	flashlight *flashlight.Flashlight

	issueReporter *issueReporter
	authClient    auth.AuthClient
	proClient     proclient.ProClient
	referralCode  string
	selectedTab   Tab

	connectionStatusCallbacks []func(isConnected bool)
	_sysproxyOff              func() error

	// Websocket-related settings
	websocketAddr   string
	websocketServer *http.Server
	ws              ws.UIChannel

	userData userMap

	mu sync.Mutex
}

// NewApp creates a new desktop app that initializes the app and acts as a moderator between all desktop components.
func NewApp(flags flashlight.Flags, configDir string) *App {
	app := &App{
		Flags:                     flags,
		configDir:                 configDir,
		settings:                  loadSettings(configDir),
		connectionStatusCallbacks: make([]func(isConnected bool), 0),
		selectedTab:               VPNTab,
		statsTracker:              stats.NewNoop(),
		translations:              eventual.NewValue(),
		userData: userMap{
			data:       make(map[int64]*protos.User),
			onUserData: make([]func(current *protos.User, new *protos.User), 0),
		},
		//ws:                        ws.NewUIChannel(),
	}

	webclientOpts := &webclient.Opts{
		HttpClient: &http.Client{
			//Transport: proxied.ParallelForIdempotent(),
			Timeout: 30 * time.Second,
		},
		UserConfig: app.UserConfig,
	}
	app.proClient = proclient.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), webclientOpts)
	app.authClient = auth.NewClient(fmt.Sprintf("https://%s", common.V1BaseUrl), webclientOpts)

	/*if err := app.serveWebsocket(); err != nil {
		log.Error(err)
	}

	onProStatusChange(func(isPro bool) {
		app.statsTracker.SetIsPro(isPro)
	})
	datacap.AddDataCapListener(func(hitDataCap bool) {
		app.statsTracker.SetHitDataCap(hitDataCap)
	})*/

	log.Debugf("Using configdir: %v", configDir)

	app.issueReporter = newIssueReporter(app)
	app.translations.Set(os.DirFS("locale/translation"))

	return app
}

func (app *App) UserConfig() common.UserConfig {
	settings := app.settings
	var userID int64
	var deviceID, token string
	if settings != nil {
		userID, deviceID, token = settings.GetUserID(), settings.GetDeviceID(), settings.GetToken()
	}
	return common.NewUserConfig(
		common.DefaultAppName,
		deviceID,
		userID,
		token,
		nil,
		settings.GetLanguage(),
	)
}

// loadSettings loads the initial settings at startup, either from disk or using defaults.
func loadSettings(configDir string) *settings.Settings {
	path := filepath.Join(configDir, "settings.yaml")
	if common.IsStagingEnvironment() {
		path = filepath.Join(configDir, "settings-staging.yaml")
	}
	settings := settings.LoadSettingsFrom(common.ApplicationVersion, common.RevisionDate, common.BuildDate, path)
	if common.IsStagingEnvironment() {
		settings.SetUserIDAndToken(9007199254740992, "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA")
	}
	return settings
}

// Run starts the app.
func (app *App) Run() {
	/*go func() {
		for <-geolookup.OnRefresh() {
			app.settings.SetCountry(geolookup.GetCountry(0))
		}
	}()*/
	i18nInit(app)
	// Run below in separate goroutine as config.Init() can potentially block when Lantern runs
	// for the first time. User can still quit Lantern through systray menu when it happens.

	log.Debug(app.Flags)
	if app.Flags.ProxyAll {
		// If proxyall flag was supplied, force proxying of all
		app.settings.SetProxyAll(true)
	}

	listenAddr := app.Flags.Addr
	if listenAddr == "" {
		listenAddr = app.settings.GetAddr()
	}
	if listenAddr == "" {
		listenAddr = defaultHTTPProxyAddress
	}

	socksAddr := app.Flags.SocksAddr
	if socksAddr == "" {
		socksAddr = app.settings.GetSOCKSAddr()
	}
	if socksAddr == "" {
		socksAddr = defaultSOCKSProxyAddress
	}

	if app.Flags.Timeout > 0 {
		go func() {
			time.AfterFunc(app.Flags.Timeout, func() {
				app.Exit(errors.New("No succeeding proxy got after running for %v, global config fetched: %v, proxies fetched: %v",
					app.Flags.Timeout, atomic.LoadInt32(&app.fetchedGlobalConfig) == 1, atomic.LoadInt32(&app.fetchedProxiesConfig) == 1))
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
		func() bool { return app.settings.GetDisconnected() }, // check whether we're disconnected
		app.settings.GetProxyAll,
		func() bool { return false }, // on desktop, we do not allow private hosts
		app.settings.IsAutoReport,
		app.Flags.AsMap(),
		app.settings,
		app.statsTracker,
		app.IsPro,
		app.settings.GetLanguage,
		func(addr string) (string, error) { return addr, nil }, // no dnsgrab reverse lookups on desktop
		func(string, string, string) {},
		flashlight.WithOnConfig(app.onConfigUpdate),
		flashlight.WithOnProxies(app.onProxiesUpdate),
		flashlight.WithOnDialError(func(err error, hasSucceeding bool) {
			if err != nil && !hasSucceeding {
				app.onSucceedingProxy(hasSucceeding)
			}
		}),
		flashlight.WithOnSucceedingProxy(func() {
			app.onSucceedingProxy(true)
		}),
	)
	if err != nil {
		app.Exit(err)
		return
	}
	app.beforeStart(listenAddr)
	/*app.flashlight.Run(
		listenAddr,
		socksAddr,
		app.afterStart,
		func(err error) { _ = app.Exit(err) },
	)*/

}

func (app *App) setSettings(settings *settings.Settings) {
	app.mu.Lock()
	app.settings = settings
	app.mu.Unlock()
}

// IsFeatureEnabled checks whether or not the given feature is enabled by flashlight
func (app *App) IsFeatureEnabled(feature string) bool {
	if app.flashlight == nil {
		return false
	}
	return false
	//return app.flashlight.EnabledFeatures()[feature]
}

func (app *App) beforeStart(listenAddr string) {
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

	/*if e := app.settings.StartService(app.ws); e != nil {
		app.Exit(fmt.Errorf("unable to register settings service: %q", e))
		return
	}

	isProUser := func() (bool, bool) {
		return app.IsProUser(context.Background())
	}

	if err := datacap.ServeDataCap(app.ws, func() string {
		return "/img/lantern_logo.png"
	}, func() string { return "" }, isProUser); err != nil {
		log.Errorf("Unable to serve bandwidth to UI: %v", err)
	}

	app.AddExitFunc("stopping loconf scanner", LoconfScanner(app.settings, app.configDir, 4*time.Hour, isProUser, func() string {
		return "/img/lantern_logo.png"
	}))*/
}

// GetLanguage returns the user language
func (app *App) GetLanguage() string {
	if app.settings == nil {
		return ""
	}
	lang := app.settings.GetLanguage()
	if lang == "" {
		return defaultLocale
	}
	return lang
}

func (app *App) fetchPayentMethodV4() error {
	settings := app.Settings()
	userID := settings.GetUserID()
	if userID == 0 {
		return errors.New("User ID is not set")
	}
	resp, err := app.proClient.PaymentMethodsV4(context.Background())
	if err != nil {
		return errors.New("Could not get payment methods: %v", err)
	}
	log.Debugf("DEBUG: Payment methods: %+v", resp)
	log.Debugf("DEBUG: Payment methods providers: %+v", resp.Providers)
	bytes, err := json.Marshal(resp)
	if err != nil {
		return errors.New("Could not marshal payment methods: %v", err)
	}
	settings.SetPaymentMethodPlans(bytes)
	return nil
}

// SetLanguage sets the user language
func (app *App) SetLanguage(lang string) {
	app.settings.SetLanguage(lang)
	log.Debugf("Setting language to %v", lang)
	if app.ws != nil {
		app.ws.SendMessage("pro", map[string]interface{}{
			"type":     "pro",
			"language": lang,
		})
	}
}

func (app *App) SetUserLoggedIn(value bool) {
	app.settings.SetUserLoggedIn(value)
	if app.ws != nil {
		app.ws.SendMessage("pro", map[string]interface{}{
			"login": value,
		})
	}
}

func (app *App) IsUserLoggedIn() bool {
	settings := app.Settings()
	return settings != nil && settings.IsUserLoggedIn()
}

// Create func that send message to UI
func (app *App) SendMessageToUI(service string, message interface{}) {
	if app.ws != nil {
		app.ws.SendMessage(service, message)
	}
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

func (a *App) startUpAPICalls() {
	userCreate := func() error {
		// User is new
		user, err := a.proClient.UserCreate(context.Background())
		if err != nil {
			return errors.New("Could not create new Pro user: %v", err)
		}
		log.Debugf("DEBUG: User created: %v", user)
		if user.BaseResponse != nil && user.BaseResponse.Error != "" {
			return errors.New("Could not create new Pro user: %v", err)
		}
		a.Settings().SetUserIDAndToken(user.UserId, user.Token)

		return nil
	}

	fetchOrCreate := func() error {
		settings := a.Settings()
		settings.SetLanguage("en_us")
		userID := settings.GetUserID()
		if userID == 0 {
			a.Settings().SetUserFirstVisit(true)
			err := userCreate()
			if err != nil {
				return err
			}
			// if the user is new mean we need to fetch the payment methods
			a.fetchPayentMethodV4()
		}
		return nil
	}
	go fetchOrCreate()
	go a.fetchPayentMethodV4()
}

func (app *App) afterStart(cl *flashlightClient.Client) {
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
	/*if err := app.servePro(app.ws); err != nil {
		log.Errorf("Unable to serve pro data to UI: %v", err)
	}
	if err := app.serveConnectionStatus(app.ws); err != nil {
		log.Errorf("Unable to serve connection status: %v", err)
	}*/
}

func (app *App) onConfigUpdate(cfg *config.Global, src config.Source) {
	log.Debugf("[Startup Desktop] Got config update from %v", src)
	atomic.StoreInt32(&app.fetchedGlobalConfig, 1)
	autoupdate.Configure(cfg.UpdateServerURL, cfg.AutoUpdateCA, func() string {
		return "/img/lantern_logo.png"
	})
	email.SetDefaultRecipient(cfg.ReportIssueEmail)
	if len(cfg.GlobalBrowserMarketShareData) > 0 {
		err := simbrowser.SetMarketShareData(
			cfg.GlobalBrowserMarketShareData, cfg.RegionalBrowserMarketShareData)
		if err != nil {
			log.Errorf("failed to set browser market share data: %v", err)
		}
	}
}

func (app *App) onProxiesUpdate(proxies []bandit.Dialer, src config.Source) {
	log.Debugf("[Startup Desktop] Got proxies update from %v", src)
	atomic.StoreInt32(&app.fetchedProxiesConfig, 1)
}

func (app *App) onSucceedingProxy(succeeding bool) {
	hasSucceedingProxy := int32(0)
	if succeeding {
		hasSucceedingProxy = 1
	}
	atomic.StoreInt32(&app.hasSucceedingProxy, hasSucceedingProxy)
	log.Debugf("[Startup Desktop] onSucceedingProxy %v", succeeding)
}

// HasSucceedingProxy returns whether or not the app is currently configured with any succeeding proxies
func (app *App) HasSucceedingProxy() bool {
	return atomic.LoadInt32(&app.hasSucceedingProxy) == 1
}

func (app *App) GetHasConfigFetched() bool {
	return atomic.LoadInt32(&app.fetchedGlobalConfig) == 1
}

func (app *App) GetHasProxyFetched() bool {
	return atomic.LoadInt32(&app.fetchedProxiesConfig) == 1
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
	if atomic.CompareAndSwapInt64(&app.hasExited, 0, 1) {
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
	isPro, _ := app.IsProUserFast(context.Background())
	return isPro
}

// ReferralCode returns a user's unique referral code
func (app *App) ReferralCode(uc common.UserConfig) (string, error) {
	referralCode := app.referralCode
	if referralCode == "" {
		resp, err := app.proClient.UserData(context.Background())
		if err != nil {
			return "", errors.New("error fetching user data: %v", err)
		} else if resp.User == nil {
			return "", errors.New("error fetching user data")
		}

		app.SetReferralCode(resp.User.Code)
		return resp.User.Code, nil
	}
	return referralCode, nil
}

func (app *App) SetReferralCode(referralCode string) {
	app.mu.Lock()
	defer app.mu.Unlock()
	app.referralCode = referralCode
}

func (app *App) AuthClient() auth.AuthClient {
	return app.authClient
}

func (app *App) ProClient() proclient.ProClient {
	return app.proClient
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
	return app.settings
}

func (app *App) Stats() *stats.Stats {
	if app.statsTracker == nil {
		return nil
	}
	stats := app.statsTracker.Latest()
	return &stats
}

const defaultLocale = "en-US"

// useOSLocale detect OS locale for current user and let i18n to use it
func useOSLocale(a *App) (string, error) {
	userLocale, err := jibber_jabber.DetectIETF()
	if err != nil || userLocale == "C" {
		log.Debugf("Ignoring OS locale and using default")
		userLocale = defaultLocale
	}
	log.Debugf("Using OS locale of current user: %v", userLocale)
	a.SetLanguage(userLocale)
	return userLocale, nil
}

// Localization is happening on the client side but we are keeping this around for notifications
func i18nInit(a *App) {
	i18n.SetMessagesFunc(func(filename string) ([]byte, error) {
		return a.GetTranslations(filename)
	})
	locale := a.GetLanguage()
	log.Debugf("Using locale: %v", locale)
	if _, err := i18n.SetLocale(locale); err != nil {
		log.Debugf("i18n.SetLocale(%s) failed, fallback to OS default: %q", locale, err)

		// On startup GetLanguage will return '' We use the OS locale instead and make sure the language is
		// populated.
		if locale, err := useOSLocale(a); err != nil {
			log.Debugf("i18n.UseOSLocale: %q", err)
			a.SetLanguage(defaultLocale)
		} else {
			a.SetLanguage(locale)
		}
	}
}
