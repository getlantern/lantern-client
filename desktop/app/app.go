package app

import (
	"context"
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
	flashlightClient "github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/email"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/otel"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/memhelper"
	"github.com/getlantern/profiling"

	"github.com/getlantern/lantern-client/desktop/analytics"

	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/datacap"
	"github.com/getlantern/lantern-client/desktop/notifier"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/desktop/ws"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
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
	fetchedGlobalConfig  atomic.Bool
	fetchedProxiesConfig atomic.Bool
	hasSucceedingProxy   atomic.Bool

	Flags            flashlight.Flags
	configDir        string
	exited           eventual.Value
	analyticsSession analytics.Session
	settings         *settings.Settings
	statsTracker     *statsTracker

	muExitFuncs sync.RWMutex
	exitFuncs   []func()

	translations eventual.Value

	flashlight *flashlight.Flashlight

	issueReporter *issueReporter
	proClient     proclient.ProClient
	referralCode  string
	selectedTab   Tab
	stats         *stats.Stats

	connectionStatusCallbacks []func(isConnected bool)
	_sysproxyOff              func() error

	// Websocket-related settings
	websocketAddr   string
	websocketServer *http.Server
	ws              ws.UIChannel

	mu sync.Mutex
}

// NewApp creates a new desktop app that initializes the app and acts as a moderator between all desktop components.
func NewApp(flags flashlight.Flags, configDir string, proClient proclient.ProClient, settings *settings.Settings) *App {
	analyticsSession := newAnalyticsSession(settings)
	app := &App{
		Flags:                     flags,
		configDir:                 configDir,
		exited:                    eventual.NewValue(),
		proClient:                 proClient,
		settings:                  settings,
		analyticsSession:          analyticsSession,
		connectionStatusCallbacks: make([]func(isConnected bool), 0),
		selectedTab:               VPNTab,
		translations:              eventual.NewValue(),
		ws:                        ws.NewUIChannel(),
	}
	app.statsTracker = NewStatsTracker(app)
	if err := app.serveWebsocket(); err != nil {
		log.Error(err)
	}
	golog.OnFatal(app.exitOnFatal)

	app.AddExitFunc("stopping analytics", app.analyticsSession.End)
	onProStatusChange(func(isPro bool) {
		app.statsTracker.SetIsPro(isPro)
	})
	datacap.AddDataCapListener(func(hitDataCap bool) {
		app.statsTracker.SetHitDataCap(hitDataCap)
	})

	log.Debugf("Using configdir: %v", configDir)

	app.issueReporter = newIssueReporter(app)
	app.translations.Set(os.DirFS("locale/translation"))

	return app
}

func newAnalyticsSession(settings *settings.Settings) analytics.Session {
	if settings.IsAutoReport() {
		session := analytics.Start(settings.GetDeviceID(), common.ApplicationVersion)
		go func() {
			session.SetIP(geolookup.GetIP(eventual.Forever))
		}()
		return session
	} else {
		return analytics.NullSession{}
	}
}

// Run starts the app.
func (app *App) Run(isMain bool) {
	golog.OnFatal(app.exitOnFatal)

	memhelper.Track(15*time.Second, 15*time.Second, func(err error) {
		sentry.CaptureException(err)
	})

	go func() {
		for <-geolookup.OnRefresh() {
			app.settings.SetCountry(geolookup.GetCountry(0))
		}
	}()

	// Run below in separate goroutine as config.Init() can potentially block when Lantern runs
	// for the first time. User can still quit Lantern through systray menu when it happens.
	go func() {
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
						app.Flags.Timeout, app.fetchedGlobalConfig.Load(), app.fetchedProxiesConfig.Load()))
				})
			}()
		}

		cacheDir, err := os.UserCacheDir()
		if err != nil {
			cacheDir = os.TempDir()
		}
		cacheDir = filepath.Join(cacheDir, common.DefaultAppName, "dhtup", "data")
		os.MkdirAll(cacheDir, 0o700)

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
			app.analyticsSession.EventWithLabel,
			flashlight.WithOnConfig(app.onConfigUpdate),
			flashlight.WithOnProxies(app.onProxiesUpdate),
			flashlight.WithOnSucceedingProxy(func() {
				app.onSucceedingProxy(true)
			}),
		)
		if err != nil {
			app.Exit(err)
			return
		}
		app.beforeStart(listenAddr)

		app.flashlight.Run(
			listenAddr,
			socksAddr,
			app.afterStart,
			func(err error) { _ = app.Exit(err) },
		)
	}()
}

// checkEnabledFeatures checks if features are enabled
func (app *App) checkEnabledFeatures() {
	enabledFeatures := app.flashlight.EnabledFeatures()
	log.Debugf("Starting enabled features: %v", enabledFeatures)
	//go app.startReplicaIfNecessary(enabledFeatures)
}

// IsFeatureEnabled checks whether or not the given feature is enabled by flashlight
func (app *App) IsFeatureEnabled(feature string) bool {
	if app.flashlight == nil {
		return false
	}
	return app.flashlight.EnabledFeatures()[feature]
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

	if e := app.settings.StartService(app.ws); e != nil {
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
	}))
	app.AddExitFunc("stopping notifier", notifier.NotificationsLoop(app.analyticsSession))
}

// GetLanguage returns the user language
func (app *App) GetLanguage() string {
	return app.settings.GetLanguage()
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
func (app *App) OnSettingChange(attr settings.SettingName, cb func(interface{})) {
	app.settings.OnChange(attr, cb)
}

// OnStatsChange adds a listener for Stats changes.
func (app *App) OnStatsChange(fn func(stats.Stats)) {
	app.statsTracker.AddListener(fn)
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
	if err := app.servePro(app.ws); err != nil {
		log.Errorf("Unable to serve pro data to UI: %v", err)
	}
	if err := app.serveConnectionStatus(app.ws); err != nil {
		log.Errorf("Unable to serve connection status: %v", err)
	}
}

func (app *App) onConfigUpdate(cfg *config.Global, src config.Source) {
	log.Debugf("[Startup Desktop] Got config update from %v", src)
	app.fetchedGlobalConfig.Store(true)
	/*autoupdate.Configure(cfg.UpdateServerURL, cfg.AutoUpdateCA, func() string {
		return "/img/lantern_logo.png"
	})*/
	email.SetDefaultRecipient(cfg.ReportIssueEmail)
}

func (app *App) onProxiesUpdate(proxies []bandit.Dialer, src config.Source) {
	log.Debugf("[Startup Desktop] Got proxies update from %v", src)
	app.fetchedProxiesConfig.Store(true)
}

func (app *App) onSucceedingProxy(succeeding bool) {
	app.hasSucceedingProxy.Store(succeeding)
	log.Debugf("[Startup Desktop] onSucceedingProxy %v", succeeding)
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
	isPro, _ := app.isProUserFast(context.Background())
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
	app.onSucceedingProxy(true)
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
