package app

import (
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	. "github.com/anacrolix/generics"
	"github.com/getsentry/sentry-go"

	"github.com/getlantern/dhtup"
	"github.com/getlantern/errors"
	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/balancer"
	"github.com/getlantern/flashlight/v7/browsers/simbrowser"
	flashlightClient "github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/email"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/pro"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/i18n"
	"github.com/getlantern/memhelper"
	notify "github.com/getlantern/notifier"
	"github.com/getlantern/profiling"
	"github.com/getlantern/trafficlog-flashlight/tlproc"

	"github.com/getlantern/lantern-client/desktop/analytics"
	uicommon "github.com/getlantern/lantern-client/desktop/common"
	"github.com/getlantern/lantern-client/desktop/features"
	"github.com/getlantern/lantern-client/desktop/notifier"
	"github.com/getlantern/lantern-client/desktop/server"
	"github.com/getlantern/lantern-client/desktop/ws"
)

var (
	log                = golog.LoggerFor("lantern-desktop.app")
	startTime          = time.Now()
	translationAppName = strings.ToUpper(common.DefaultAppName)
)

// App is the core of the Lantern desktop application, in the form of a library.
type App struct {
	hasExited            int64
	fetchedGlobalConfig  int32
	fetchedProxiesConfig int32

	Flags            flashlight.Flags
	configDir        string
	exited           eventual.Value
	analyticsSession analytics.Session
	settings         *Settings
	statsTracker     *statsTracker

	muExitFuncs sync.RWMutex
	exitFuncs   []func()

	chGlobalConfigChanged chan bool

	ws           ws.UIChannel
	flashlight   *flashlight.Flashlight
	dhtupContext Option[dhtup.Context]

	// If both the trafficLogLock and proxiesLock are needed, the trafficLogLock should be obtained
	// first. Keeping the order consistent avoids deadlocking.

	// Log of network traffic to and from the proxies. Used to attach packet capture files to
	// reported issues. Nil if traffic logging is not enabled.
	trafficLog     *tlproc.TrafficLogProcess
	trafficLogLock sync.RWMutex

	// Also protected by trafficLogLock.
	captureSaveDuration time.Duration

	// proxies are tracked by the application solely for data collection purposes. This value should
	// not be changed, except by Flashlight.onProxiesUpdate. State-changing methods on the dialers
	// should not be called. In short, this slice and its elements should be treated as read-only.
	proxies     []balancer.Dialer
	proxiesLock sync.RWMutex

	selectedTab   Tab
	selectedTabMu sync.Mutex
}

// NewApp creates a new desktop app that initializes the app and acts as a moderator between all desktop components.
func NewApp(flags flashlight.Flags, configDir string, settings *Settings) *App {
	analyticsSession := newAnalyticsSession(settings)
	app := &App{
		configDir:        configDir,
		exited:           eventual.NewValue(),
		settings:         settings,
		analyticsSession: analyticsSession,
		selectedTab:      AccountTab,
		statsTracker:     NewStatsTracker(),
		ws:               ws.NewUIChannel(),
	}

	return app
}

func newAnalyticsSession(settings *Settings) analytics.Session {
	if settings.IsAutoReport() {
		session := analytics.Start(settings.GetDeviceID(), ApplicationVersion)
		go func() {
			session.SetIP(geolookup.GetIP(eventual.Forever))
		}()
		return session
	} else {
		return analytics.NullSession{}
	}
}

func (app *App) SelectedTab() Tab {
	app.selectedTabMu.Lock()
	defer app.selectedTabMu.Unlock()
	return app.selectedTab
}

func (app *App) SetSelectedTab(selectedTab Tab) {
	app.selectedTabMu.Lock()
	defer app.selectedTabMu.Unlock()
	app.selectedTab = selectedTab
}

func (app *App) GetDebugHttpHandlers() []server.PathHandler {
	return []server.PathHandler{{
		Pattern: "/dhtupContextTorrentClientStatus",
		Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// I think it's okay to return the Option Value without checking if it's set, because this handler is
			// invoked on demand, and should only crash the handler. An alternative might be to just return a nice error
			// message saying that there's no dhtup Context.
			app.dhtupContext.Value.TorrentClient.WriteStatus(w)
		}),
	}}
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
			listenAddr = app.settings.getString(SNAddr)
		}
		if listenAddr == "" {
			listenAddr = defaultHTTPProxyAddress
		}

		socksAddr := app.Flags.SocksAddr
		if socksAddr == "" {
			socksAddr = app.settings.getString(SNSOCKSAddr)
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

		if app.Flags.Initialize {
			app.statsTracker.AddListener(func(newStats stats.Stats) {
				if newStats.HasSucceedingProxy {
					log.Debug("Finished initialization")
					app.Exit(nil)
				}
			})
		}

		cacheDir, err := os.UserCacheDir()
		if err != nil {
			cacheDir = os.TempDir()
		}
		cacheDir = filepath.Join(cacheDir, common.DefaultAppName, "dhtup", "data")
		os.MkdirAll(cacheDir, 0o700)
		dhtContextValue, err := dhtup.NewContext(
			net.ParseIP(geolookup.GetIP(0)),
			cacheDir)
		if err != nil {
			log.Errorf("creating dhtup context: %w", err)
		} else {
			app.dhtupContext = Some(dhtContextValue)
			app.AddExitFunc("Closing dhtupContext", app.dhtupContext.Value.Close)
		}

		app.flashlight, err = flashlight.New(
			common.DefaultAppName,
			ApplicationVersion,
			RevisionDate,
			app.configDir,
			app.Flags.VPN,
			func() bool { return app.settings.getBool(SNDisconnected) }, // check whether we're disconnected
			app.settings.GetProxyAll,
			app.settings.GetGoogleAds,
			func() bool { return false }, // on desktop, we do not allow private hosts
			app.settings.IsAutoReport,
			app.Flags.AsMap(),
			app.onConfigUpdate,
			app.onProxiesUpdate,
			app.settings,
			app.statsTracker,
			app.IsPro,
			app.settings.GetLanguage,
			func() string {
				isPro, statusKnown := app.isProUserFast()
				if (isPro || !statusKnown) && !common.ForceAds() {
					// pro user (or status unknown), don't ad swap
					return ""
				}
				return app.PlansURL()
			},
			func(addr string) (string, error) { return addr, nil }, // no dnsgrab reverse lookups on desktop
			app.AdTrackURL,
			app.analyticsSession.EventWithLabel,
		)
		if err != nil {
			app.Exit(err)
			return
		}
		app.beforeStart(listenAddr)

		chProStatusChanged := make(chan bool, 1)
		pro.OnProStatusChange(func(isPro bool, _ bool) {
			chProStatusChanged <- isPro
		})
		chUserChanged := make(chan bool, 1)
		app.settings.OnChange(SNUserID, func(v interface{}) {
			chUserChanged <- true
		})
		// Just pass all of the channels that should trigger re-evaluating which features
		// are enabled for this user, country, etc.
		app.startFeaturesService(geolookup.OnRefresh(), chUserChanged, chProStatusChanged, app.chGlobalConfigChanged)

		notifyConfigSaveErrorOnce := new(sync.Once)
		app.flashlight.SetErrorHandler(func(t flashlight.HandledErrorType, err error) {
			switch t {
			case flashlight.ErrorTypeProxySaveFailure, flashlight.ErrorTypeConfigSaveFailure:
				log.Errorf("failed to save config (%v): %v", t, err)

				notifyConfigSaveErrorOnce.Do(func() {
					note := &notify.Notification{
						Title:      i18n.T("BACKEND_CONFIG_SAVE_ERROR_TITLE"),
						Message:    i18n.T("BACKEND_CONFIG_SAVE_ERROR_MESSAGE", i18n.T(translationAppName)),
						ClickLabel: i18n.T("BACKEND_CLICK_LABEL_GOT_IT"),
						IconURL:    app.AddToken("/img/lantern_logo.png"),
					}
					_ = notifier.ShowNotification(note, "alert-prompt")
				})

			default:
				log.Errorf("flashlight error: %v: %v", t, err)
			}
		})

		// The default HTTP handler is often exposed for debugging purposes by default, such as by
		// anacrolix/envpprof, and should never be exposed publicly.
		if isMain {
			for _, handler := range app.GetDebugHttpHandlers() {
				http.Handle(handler.Pattern, handler.Handler)
			}
		}

		app.flashlight.Run(
			listenAddr,
			socksAddr,
			app.afterStart,
			func(err error) { _ = app.Exit(err) },
		)
	}()
}

// setFeatures enables or disables the features specified by values in the features map
// sent back to the UI
func (app *App) setFeatures(enabledFeatures map[string]bool, values map[features.Feature]bool) {
	for feature, isEnabled := range values {
		if isEnabled {
			enabledFeatures[feature.String()] = isEnabled
		}
	}
}

// checkEnabledFeatures checks if features are enabled
// (based on the env vars at build time or the user's settings/geolocation)
// and starts appropriate services
func (app *App) checkEnabledFeatures(enabledFeatures map[string]bool) {
	app.setFeatures(enabledFeatures, features.EnabledFeatures)

	log.Debugf("Starting enabled features: %v", enabledFeatures)
	//go app.startReplicaIfNecessary(enabledFeatures)
	enableTrafficLog := app.isFeatureEnabled(enabledFeatures, config.FeatureTrafficLog)
	go app.toggleTrafficLog(enableTrafficLog)
}

// startFeaturesService starts a new features service that dispatches features to any relevant
// listeners.
func (app *App) startFeaturesService(chans ...<-chan bool) {
	if service, err := app.ws.Register("features", func(write func(interface{})) {
		enabledFeatures := app.flashlight.EnabledFeatures()
		app.checkEnabledFeatures(enabledFeatures)
		write(enabledFeatures)
	}); err != nil {
		log.Errorf("Unable to serve enabled features to UI: %v", err)
	} else {
		for _, ch := range chans {
			go func(c <-chan bool) {
				for range c {
					features := app.flashlight.EnabledFeatures()
					app.checkEnabledFeatures(features)
					select {
					case service.Out <- features:
						// ok
					default:
						// don't block if no-one is listening
					}
				}
			}(ch)
		}
	}
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
}

func (app *App) isFeatureEnabled(features map[string]bool, feature string) bool {
	val, ok := features[feature]
	return ok && val
}

// Connect turns on proxying
func (app *App) Connect() {
	app.analyticsSession.Event("systray-menu", "connect")
	ops.Begin("connect").End()
	app.settings.setBool(SNDisconnected, false)
}

// Disconnect turns off proxying
func (app *App) Disconnect() {
	app.analyticsSession.Event("systray-menu", "disconnect")
	ops.Begin("disconnect").End()
	app.settings.setBool(SNDisconnected, true)
}

// GetLanguage returns the user language
func (app *App) GetLanguage() string {
	return app.settings.GetLanguage()
}

// SetLanguage sets the user language
func (app *App) SetLanguage(lang string) {
	app.settings.SetLanguage(lang)
}

// OnSettingChange sets a callback cb to get called when attr is changed from server.
// When calling multiple times for same attr, only the last one takes effect.
func (app *App) OnSettingChange(attr SettingName, cb func(interface{})) {
	app.settings.OnChange(attr, cb)
}

// OnStatsChange adds a listener for Stats changes.
func (app *App) OnStatsChange(fn func(stats.Stats)) {
	app.statsTracker.AddListener(fn)
}

func (app *App) SysproxyOn() {
	if err := SysproxyOn(); err != nil {
		app.statsTracker.SetAlert(
			stats.FAIL_TO_SET_SYSTEM_PROXY, err.Error(), false)
	}
}

func (app *App) afterStart(cl *flashlightClient.Client) {
	app.OnSettingChange(SNSystemProxy, func(val interface{}) {
		enable := val.(bool)
		if enable {
			app.SysproxyOn()
		} else {
			SysProxyOff()
		}
	})
}

func (app *App) onConfigUpdate(cfg *config.Global, src config.Source) {
	if src == config.Fetched {
		atomic.StoreInt32(&app.fetchedGlobalConfig, 1)
	}
	/*autoupdate.Configure(cfg.UpdateServerURL, cfg.AutoUpdateCA, func() string {
		return app.AddToken("/img/lantern_logo.png")
	})*/
	email.SetDefaultRecipient(cfg.ReportIssueEmail)
	if len(cfg.GlobalBrowserMarketShareData) > 0 {
		err := simbrowser.SetMarketShareData(
			cfg.GlobalBrowserMarketShareData, cfg.RegionalBrowserMarketShareData)
		if err != nil {
			log.Errorf("failed to set browser market share data: %v", err)
		}
	}
	app.chGlobalConfigChanged <- true
}

func (app *App) onProxiesUpdate(proxies []balancer.Dialer, src config.Source) {
	if src == config.Fetched {
		atomic.StoreInt32(&app.fetchedProxiesConfig, 1)
	}
	app.trafficLogLock.Lock()
	app.proxiesLock.Lock()
	app.proxies = proxies
	if app.trafficLog != nil {
		proxyAddresses := []string{}
		for _, p := range proxies {
			proxyAddresses = append(proxyAddresses, p.Addr())
		}
		if err := app.trafficLog.UpdateAddresses(proxyAddresses); err != nil {
			log.Errorf("failed to update traffic log addresses: %v", err)
		}
	}
	app.proxiesLock.Unlock()
	app.trafficLogLock.Unlock()
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

func (app *App) exitOnFatal(err error) {
	_ = logging.Close()
	app.Exit(err)
}

// IsPro indicates whether or not the app is pro
func (app *App) IsPro() bool {
	isPro, _ := app.isProUserFast()
	return isPro
}

func recordStopped() {
	ops.Begin("client_stopped").
		SetMetricSum("uptime", time.Since(startTime).Seconds()).
		End()
}

// ShouldReportToSentry determines if we should report errors/panics to Sentry
func ShouldReportToSentry() bool {
	return !uicommon.IsDevEnvironment()
}

// OnTrayShow indicates the user has selected to show lantern from the tray.
func (app *App) OnTrayShow() {
	app.analyticsSession.Event("systray-menu", "show")
}

// OnTrayUpgrade indicates the user has selected to upgrade lantern from the tray.
func (app *App) OnTrayUpgrade() {
	app.analyticsSession.Event("systray-menu", "upgrade")
}

// PlansURL returns the URL for accessing the checkout/plans page directly.
func (app *App) PlansURL() string {
	return "#/plans"
}

// AdTrackURL returns the URL for adding tracking on injected ads.
func (app *App) AdTrackURL() string {
	return "/ad_track"
}

// AddToken adds our secure token to a given request path.
func (app *App) AddToken(path string) string {
	return path
}
