// package internalsdk implements the mobile application functionality of flashlight
package internalsdk

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/autoupdate"
	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/dnsgrab/persistentcache"
	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight"
	"github.com/getlantern/flashlight/balancer"
	"github.com/getlantern/flashlight/bandwidth"
	"github.com/getlantern/flashlight/client"
	"github.com/getlantern/flashlight/common"
	"github.com/getlantern/flashlight/config"
	"github.com/getlantern/flashlight/email"
	"github.com/getlantern/flashlight/geolookup"
	"github.com/getlantern/flashlight/logging"
	"github.com/getlantern/flashlight/proxied"
	"github.com/getlantern/golog"
	"github.com/getlantern/memhelper"
	"github.com/getlantern/mtime"
	"github.com/getlantern/netx"
	"github.com/getlantern/protected"
	replicaServer "github.com/getlantern/replica/server"
	replicaService "github.com/getlantern/replica/service"
	"github.com/gorilla/mux"
	"github.com/pkg/errors"
)

const (
	maxDNSGrabAge = 24 * time.Hour // this doesn't need to be huge, since we use a TTL of 1 second for our DNS responses
)

var (
	log = golog.LoggerFor("lantern")

	// XXX mobile does not respect the autoupdate global config
	updateClient = &http.Client{Transport: proxied.ChainedThenFrontedWith("")}

	defaultLocale = `en-US`

	startOnce sync.Once

	cl          = eventual.NewValue()
	dnsGrabAddr = eventual.NewValue()

	errNoAdProviderAvailable = errors.New("no ad provider available")
)

type Settings interface {
	StickyConfig() bool
	GetReplicaPort() int
	ShouldRunReplica() bool
	GetHttpProxyHost() string
	GetHttpProxyPort() int
	TimeoutMillis() int
}

// Session provides an interface for interacting with the Android Java/Kotlin code.
// Note - all methods return an error so that Go has the opportunity to inspect any exceptions
// thrown from the Java code. If a method interface doesn't include an error, exceptions on the
// Java side immediately result in a panic from which Go cannot recover.
type Session interface {
	GetDeviceID() (string, error)
	GetUserID() (int64, error)
	GetToken() (string, error)
	SetCountry(string) error
	UpdateAdSettings(AdSettings) error
	UpdateStats(string, string, string, int, int) error
	SetStaging(bool) error
	ProxyAll() (bool, error)
	BandwidthUpdate(int, int, int, int) error
	Locale() (string, error)
	GetTimeZone() (string, error)
	Code() (string, error)
	GetCountryCode() (string, error)
	GetForcedCountryCode() (string, error)
	GetDNSServer() (string, error)
	Provider() (string, error)
	AppVersion() (string, error)
	IsPlayVersion() (bool, error)
	Email() (string, error)
	Currency() (string, error)
	DeviceOS() (string, error)
	IsProUser() (bool, error)

	// workaround for lack of any sequence types in gomobile bind... ;_;
	// used to implement GetInternalHeaders() map[string]string
	// Should return a JSON encoded map[string]string {"key":"val","key2":"val", ...}
	SerializedInternalHeaders() (string, error)
}

// panickingSession wraps the Session interface but panics instead of returning errors
type panickingSession interface {
	common.AuthConfig
	SetCountry(string)
	UpdateAdSettings(AdSettings)
	UpdateStats(string, string, string, int, int)
	SetStaging(bool)
	ProxyAll() bool
	BandwidthUpdate(int, int, int, int)
	Locale() string
	GetTimeZone() string
	Code() string
	GetCountryCode() string
	GetForcedCountryCode() string
	GetDNSServer() string
	Provider() string
	AppVersion() string
	IsPlayVersion() bool
	Email() string
	Currency() string
	DeviceOS() string
	IsProUser() bool

	// workaround for lack of any sequence types in gomobile bind... ;_;
	// used to implement GetInternalHeaders() map[string]string
	// Should return a JSON encoded map[string]string {"key":"val","key2":"val", ...}
	SerializedInternalHeaders() string
}

func panicIfNecessary(err error) {
	if err != nil {
		panic(err)
	}
}

// panickingSessionImpl implements panickingSession
type panickingSessionImpl struct {
	wrapped Session
}

func (s *panickingSessionImpl) GetDeviceID() string {
	result, err := s.wrapped.GetDeviceID()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) GetUserID() int64 {
	result, err := s.wrapped.GetUserID()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) GetToken() string {
	result, err := s.wrapped.GetToken()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) SetCountry(country string) {
	panicIfNecessary(s.wrapped.SetCountry(country))
}

func (s *panickingSessionImpl) UpdateAdSettings(settings AdSettings) {
	panicIfNecessary(s.wrapped.UpdateAdSettings(settings))
}

func (s *panickingSessionImpl) UpdateStats(city, country, countryCode string, httpsUpgrades, adsBlocked int) {
	panicIfNecessary(s.wrapped.UpdateStats(city, country, countryCode, httpsUpgrades, adsBlocked))
}

func (s *panickingSessionImpl) SetStaging(staging bool) {
	panicIfNecessary(s.wrapped.SetStaging(staging))
}

func (s *panickingSessionImpl) ProxyAll() bool {
	result, err := s.wrapped.ProxyAll()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) BandwidthUpdate(percent, remaining, allowed, ttlSeconds int) {
	panicIfNecessary(s.wrapped.BandwidthUpdate(percent, remaining, allowed, ttlSeconds))
}

func (s *panickingSessionImpl) Locale() string {
	result, err := s.wrapped.Locale()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) GetTimeZone() string {
	result, err := s.wrapped.GetTimeZone()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) Code() string {
	result, err := s.wrapped.Code()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) GetCountryCode() string {
	result, err := s.wrapped.GetCountryCode()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) GetForcedCountryCode() string {
	result, err := s.wrapped.GetForcedCountryCode()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) GetDNSServer() string {
	result, err := s.wrapped.GetDNSServer()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) Provider() string {
	result, err := s.wrapped.Provider()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) AppVersion() string {
	result, err := s.wrapped.AppVersion()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) IsPlayVersion() bool {
	result, err := s.wrapped.IsPlayVersion()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) Email() string {
	result, err := s.wrapped.Email()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) Currency() string {
	result, err := s.wrapped.Currency()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) DeviceOS() string {
	result, err := s.wrapped.DeviceOS()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) IsProUser() bool {
	result, err := s.wrapped.IsProUser()
	panicIfNecessary(err)
	return result
}

func (s *panickingSessionImpl) SerializedInternalHeaders() string {
	result, err := s.wrapped.SerializedInternalHeaders()
	panicIfNecessary(err)
	return result
}

type userConfig struct {
	session panickingSession
}

func (uc *userConfig) GetDeviceID() string          { return uc.session.GetDeviceID() }
func (uc *userConfig) GetUserID() int64             { return uc.session.GetUserID() }
func (uc *userConfig) GetToken() string             { return uc.session.GetToken() }
func (uc *userConfig) GetLanguage() string          { return uc.session.Locale() }
func (uc *userConfig) GetTimeZone() (string, error) { return uc.session.GetTimeZone(), nil }
func (uc *userConfig) GetInternalHeaders() map[string]string {
	h := make(map[string]string)

	var f interface{}
	if err := json.Unmarshal([]byte(uc.session.SerializedInternalHeaders()), &f); err != nil {
		return h
	}
	m, ok := f.(map[string]interface{})
	if !ok {
		return h
	}

	for k, v := range m {
		vv, ok := v.(string)
		if ok {
			h[k] = vv
		}
	}
	return h
}

func newUserConfig(session panickingSession) *userConfig {
	return &userConfig{session: session}
}

// SocketProtector is an interface for classes that can protect Android sockets,
// meaning those sockets will not be passed through the VPN.
type SocketProtector interface {
	ProtectConn(fileDescriptor int) error
	// The DNS server is used to resolve host only when dialing a protected connection
	// from within Lantern client.
	DNSServerIP() string
}

// ProtectConnections allows connections made by Lantern to be protected from
// routing via a VPN. This is useful when running Lantern as a VPN on Android,
// because it keeps Lantern's own connections from being captured by the VPN and
// resulting in an infinite loop.

func ProtectConnections(protector SocketProtector) {
	log.Debug("Protecting connections")
	p := protected.New(protector.ProtectConn, protector.DNSServerIP)
	netx.OverrideDial(p.DialContext)
	netx.OverrideDialUDP(p.DialUDP)
	netx.OverrideResolveIPs(p.ResolveIPs)
	netx.OverrideListenUDP(p.ListenUDP)
	bal := getBalancer(0)
	if bal != nil {
		log.Debug("Protected after balancer already created, force redial")
		bal.ResetFromExisting()
	}
}

// RemoveOverrides removes the protected tlsdialer overrides
// that allowed connections to bypass the VPN.
func RemoveOverrides() {
	log.Debug("Removing overrides")
	netx.Reset()
}

func getBalancer(timeout time.Duration) *balancer.Balancer {
	_cl, ok := cl.Get(timeout)
	if !ok {
		return nil
	}
	c := _cl.(*client.Client)
	return c.GetBalancer()
}

type SurveyInfo struct {
	Enabled     bool    `json:"enabled"`
	Probability float64 `json:"probability"`
	Campaign    string  `json:"campaign"`
	Url         string  `json:"url"`
	Message     string  `json:"message"`
	Thanks      string  `json:"thanks"`
	Button      string  `json:"button"`
}

// StartResult provides information about the started Lantern
type StartResult struct {
	HTTPAddr    string
	SOCKS5Addr  string
	DNSGrabAddr string
}

// AdSettings is an interface for retrieving mobile ad settings from the
// global config
type AdSettings interface {
	// GetAdProvider gets an ad provider if and only if ads are enabled based on the passed parameters.
	GetAdProvider(isPro bool, countryCode string, daysSinceInstalled int) (AdProvider, error)
}

// AdProvider provides information for displaying an ad and makes decisions on whether or not to display it.
type AdProvider interface {
	GetNativeBannerZoneID() string
	GetStandardBannerZoneID() string
	GetInterstitialZoneID() string
	ShouldShowAd() bool
}

type adSettings struct {
	wrapped *config.AdSettings
}

func (s *adSettings) GetAdProvider(isPro bool, countryCode string, daysSinceInstalled int) (AdProvider, error) {
	adProvider := s.wrapped.GetAdProvider(isPro, countryCode, daysSinceInstalled)
	if adProvider == nil {
		return nil, errNoAdProviderAvailable
	}
	return adProvider, nil
}

type Updater autoupdate.Updater

// Start starts a HTTP and SOCKS proxies at random addresses. It blocks up till
// the given timeout waiting for the proxy to listen, and returns the addresses
// at which it is listening (HTTP, SOCKS). If the proxy doesn't start within the
// given timeout, this method returns an error.
//
// If a Lantern proxy is already running within this process, that proxy is
// reused.
//
// Note - this does not wait for the entire initialization sequence to finish,
// just for the proxy to be listening. Once the proxy is listening, one can
// start to use it, even as it finishes its initialization sequence. However,
// initial activity may be slow, so clients with low read timeouts may
// time out.
func Start(configDir string,
	locale string,
	settings Settings,
	wrappedSession Session) (*StartResult, error) {

	session := &panickingSessionImpl{wrappedSession}

	startOnce.Do(func() {
		go run(configDir, locale, settings, session)
	})

	startTimeout := time.Duration(settings.TimeoutMillis()) * time.Millisecond

	elapsed := mtime.Stopwatch()
	addr, ok := client.Addr(startTimeout)
	if !ok {
		return nil, fmt.Errorf("HTTP Proxy didn't start within %v timeout", startTimeout)
	}

	socksAddr, ok := client.Socks5Addr(startTimeout - elapsed())
	if !ok {
		err := fmt.Errorf("SOCKS5 Proxy didn't start within %v timeout", startTimeout)
		log.Error(err.Error())
		return nil, err
	}
	log.Debugf("Started socks proxy at %s", socksAddr)

	dnsGrabberAddr, ok := dnsGrabAddr.Get(startTimeout - elapsed())
	if !ok {
		err := fmt.Errorf("dnsgrab didn't start within %v timeout", startTimeout)
		log.Error(err.Error())
		return nil, err
	}

	return &StartResult{addr.(string), socksAddr.(string), dnsGrabberAddr.(string)}, nil
}

// EnableLogging enables logging.
func EnableLogging(configDir string) {
	logging.EnableFileLogging(configDir)
}

// serveReplica serves 'handler' over localhost with 'port'.
func serveReplica(handler *replicaServer.HttpHandler, port int) {
	fmt.Printf("Serving replica over port %v ...\n", port)
	r := mux.NewRouter()
	r.PathPrefix("/replica").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("r = %+v\n", r)
		http.StripPrefix("/replica", handler).ServeHTTP(w, r)
	})
	http.Handle("/", r)
	srv := &http.Server{
		Handler: r,
		// Serve over localhost, not for all interfaces, since we don't want
		// the device to broadcast a Replica server
		Addr:         "127.0.0.1:" + strconv.Itoa(port),
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}
	srv.ListenAndServe()
}

// newReplicaHttpHandler constructs a replicaServer.HttpHandler.
// This function will lazily fetch information from the global yaml config
// using 'fetchFeatureOptionsFunc' function.
func newReplicaHttpHandler(
	configDir string,
	userConfig *userConfig,
	// function to lazily fetch config.FeatureOptions for Replica from Flashlight
	fetchFeatureOptionsFunc func(string, config.FeatureOptions) error,
) (*replicaServer.HttpHandler, error) {
	if userConfig == nil {
		panic(errors.New("userConfig is nil"))
	}
	if fetchFeatureOptionsFunc == nil {
		panic(errors.New("featureOptionsFunc is nil"))
	}

	fmt.Printf("Starting replica with configDir [%v] and userConfig [%+v]\n", configDir, userConfig)
	optsFunc := func() *config.ReplicaOptions {
		var opts config.ReplicaOptions
		if err := fetchFeatureOptionsFunc(config.FeatureReplica, &opts); err != nil {
			log.Errorf("Could not fetch replica feature options: %v", err)
			return nil
		}
		return &opts
	}

	input := replicaServer.NewHttpHandlerInput{}
	input.SetDefaults()
	input.RootUploadsDir = configDir
	input.CacheDir = configDir
	input.UserConfig = userConfig
	input.HttpClient = &http.Client{
		Transport: proxied.AsRoundTripper(
			func(req *http.Request) (*http.Response, error) {
				chained, err := proxied.ChainedNonPersistent("")
				if err != nil {
					return nil, fmt.Errorf("connecting to proxy: %w", err)
				}
				return chained.RoundTrip(req)
			},
		),
	}
	input.ReplicaServiceClient = replicaService.ServiceClient{
		HttpClient: input.HttpClient,
		ReplicaServiceEndpoint: func() *url.URL {
			// TODO <08-10-21, soltzen> Maybe make this modifiable like lantern-desktop?
			// Ref: https://github.com/getlantern/lantern-desktop/blob/778f6e600433d0cf6349c04e9738c0673758d76e/desktop/app.go#L587
			return &url.URL{
				Scheme: "https",
				Host:   "replica-search-aws.lantern.io",
			}
		},
	}
	input.GlobalConfig = optsFunc
	replicaHandler, err := replicaServer.NewHTTPHandler(input)
	if err != nil {
		return nil, errors.Wrap(err, "creating replica http server")
	}
	return replicaHandler, nil
}

func run(configDir, locale string,
	settings Settings, session panickingSession) {

	memhelper.Track(15*time.Second, 15*time.Second)
	appdir.SetHomeDir(configDir)
	session.SetStaging(common.Staging)

	log.Debugf("Starting lantern: configDir %s locale %s sticky config %t",
		configDir, locale, settings.StickyConfig())

	flags := map[string]interface{}{
		"borda-report-interval":   5 * time.Minute,
		"borda-sample-percentage": float64(0.01),
		"staging":                 common.Staging,
	}

	err := os.MkdirAll(configDir, 0755)
	if os.IsExist(err) {
		log.Errorf("Unable to create configDir at %v: %v", configDir, err)
		return
	}

	if settings.StickyConfig() {
		flags["stickyconfig"] = true
		flags["readableconfig"] = true
	}

	log.Debugf("Writing log messages to %s/lantern.log", configDir)

	cache, err := persistentcache.New(filepath.Join(configDir, "dnsgrab.cache"), maxDNSGrabAge)
	if err != nil {
		log.Errorf("Unable to open dnsgrab cache: %v", err)
		return
	}

	grabber, err := dnsgrab.ListenWithCache(
		"127.0.0.1:0",
		session.GetDNSServer,
		cache,
	)
	if err != nil {
		log.Errorf("Unable to start dnsgrab: %v", err)
		return
	}
	dnsGrabAddr.Set(grabber.LocalAddr().String())
	go func() {
		serveErr := grabber.Serve()
		if serveErr != nil {
			log.Errorf("Error serving dns: %v", serveErr)
		}
	}()

	httpProxyAddr := fmt.Sprintf("%s:%d",
		settings.GetHttpProxyHost(),
		settings.GetHttpProxyPort())

	forcedCountryCode := session.GetForcedCountryCode()
	if forcedCountryCode != "" {
		config.ForceCountry(forcedCountryCode)
	}

	userConfig := newUserConfig(session)

	runner, err := flashlight.New(
		common.AppName,
		configDir,                    // place to store lantern configuration
		false,                        // don't enable vpn mode for Android (VPN is handled in Java layer)
		func() bool { return false }, // always connected
		session.ProxyAll,
		func() bool { return false }, // don't intercept Google ads
		func() bool { return false }, // do not proxy private hosts on Android
		// TODO: allow configuring whether or not to enable reporting (just like we
		// already have in desktop)
		func() bool { return true }, // auto report
		flags,
		func(cfg *config.Global, src config.Source) {
			session.UpdateAdSettings(&adSettings{cfg.AdSettings})
			email.SetDefaultRecipient(cfg.ReportIssueEmail)
		}, // onConfigUpdate
		nil, // onProxiesUpdate
		userConfig,
		NewStatsTracker(session),
		session.IsProUser,
		func() string { return "" }, // only used for desktop
		func() string { return "" }, // only used for desktop
		func(addr string) (string, error) {
			host, port, splitErr := net.SplitHostPort(addr)
			if splitErr != nil {
				host = addr
			}
			ip := net.ParseIP(host)
			if ip == nil {
				log.Debugf("Unable to parse IP %v, passing through address as is", host)
				return addr, nil
			}
			updatedHost, ok := grabber.ReverseLookup(ip)
			if !ok {
				return "", errors.New("Invalid IP address")
			}
			if splitErr != nil {
				return updatedHost, nil
			}
			return fmt.Sprintf("%v:%v", updatedHost, port), nil
		},
		func() string { return "" },
		func(category, action, label string) {},
	)
	if err != nil {
		log.Fatalf("Failed to start flashlight: %v", err)
	}

	if settings.ShouldRunReplica() {
		replicaHandler, err := newReplicaHttpHandler(configDir, userConfig, runner.FeatureOptions)
		if err != nil {
			panic(errors.Wrap(err, "Failed to start replica server"))
		}
		go serveReplica(replicaHandler, settings.GetReplicaPort())
	}

	go runner.Run(
		httpProxyAddr, // listen for HTTP on provided address
		"127.0.0.1:0", // listen for SOCKS on random address
		func(c *client.Client) {
			cl.Set(c)
			afterStart(session)
		},
		nil, // onError
	)
}

func bandwidthUpdates(session panickingSession) {
	go func() {
		for quota := range bandwidth.Updates {
			percent, remaining, allowed := getBandwidth(quota)
			session.BandwidthUpdate(percent, remaining, allowed, int(quota.TTLSeconds))
		}
	}()
}

func getBandwidth(quota *bandwidth.Quota) (int, int, int) {
	remaining := 0
	percent := 100
	if quota == nil {
		return 0, 0, 0
	}

	allowed := quota.MiBAllowed
	if allowed < 0 || allowed > 50000000 {
		return 0, 0, 0
	}

	if quota.MiBUsed >= quota.MiBAllowed {
		percent = 100
		remaining = 0
	} else {
		percent = int(100 * (float64(quota.MiBUsed) / float64(quota.MiBAllowed)))
		remaining = int(quota.MiBAllowed - quota.MiBUsed)
	}
	return percent, remaining, int(quota.MiBAllowed)
}

func setBandwidth(session panickingSession) {
	quota, _ := bandwidth.GetQuota()
	percent, remaining, allowed := getBandwidth(quota)
	if percent != 0 && remaining != 0 {
		session.BandwidthUpdate(percent, remaining, allowed, int(quota.TTLSeconds))
	}
}

func afterStart(session panickingSession) {
	bandwidthUpdates(session)

	go func() {
		if <-geolookup.OnRefresh() {
			country := geolookup.GetCountry(0)
			log.Debugf("Successful geolookup: country %s", country)
			session.SetCountry(country)
		}
	}()
}

// handleError logs the given error message
func handleError(err error) {
	log.Error(err)
}

// CheckForUpdates checks to see if a new version of Lantern is available
func CheckForUpdates() (string, error) {
	return checkForUpdates(buildUpdateCfg())
}

func checkForUpdates(updateCfg *autoupdate.Config) (string, error) {
	return autoupdate.CheckMobileUpdate(updateCfg)
}

// DownloadUpdate downloads the latest APK from the given url to the apkPath
// file destination.
func DownloadUpdate(url, apkPath string, updater Updater) {
	autoupdate.UpdateMobile(url, apkPath, updater, updateClient)
}

func buildUpdateCfg() *autoupdate.Config {
	return &autoupdate.Config{
		CurrentVersion: common.CompileTimePackageVersion,
		URL:            fmt.Sprintf("https://update.getlantern.org/update/%s", strings.ToLower(common.AppName)),
		HTTPClient:     updateClient,
		PublicKey:      []byte(autoupdate.PackagePublicKey),
	}
}
