// package internalsdk implements the mobile application functionality of flashlight
package internalsdk

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/getlantern/android-lantern/internalsdk/analytics"
	"github.com/getlantern/appdir"
	"github.com/getlantern/autoupdate"
	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/dnsgrab/persistentcache"
	"github.com/getlantern/errors"
	"github.com/getlantern/eventual/v2"
	"github.com/getlantern/flashlight"
	"github.com/getlantern/flashlight/balancer"
	"github.com/getlantern/flashlight/bandwidth"
	"github.com/getlantern/flashlight/client"
	"github.com/getlantern/flashlight/common"
	"github.com/getlantern/flashlight/config"
	"github.com/getlantern/flashlight/email"
	"github.com/getlantern/flashlight/geolookup"
	"github.com/getlantern/flashlight/logging"
	"github.com/getlantern/golog"
	"github.com/getlantern/memhelper"
	"github.com/getlantern/mtime"

	// import gomobile just to make sure it stays in go.mod
	_ "golang.org/x/mobile/bind/java"
)

const (
	// forever indicates that Get should wait forever
	forever       = -1
	maxDNSGrabAge = 24 * time.Hour // this doesn't need to be huge, since we use a TTL of 1 second for our DNS responses
)

var (
	log = golog.LoggerFor("lantern")

	startOnce sync.Once

	clEventual               = eventual.NewValue()
	dnsGrabEventual          = eventual.NewValue()
	dnsGrabAddrEventual      = eventual.NewValue()
	errNoAdProviderAvailable = errors.New("no ad provider available")
)

type Settings interface {
	StickyConfig() bool
	GetHttpProxyHost() string
	GetHttpProxyPort() int
	TimeoutMillis() int
}

// Session provides an interface for interacting with the Android Java/Kotlin code.
// Note - all methods return an error so that Go has the opportunity to inspect any exceptions
// thrown from the Java code. If a method interface doesn't include an error, exceptions on the
// Java side immediately result in a panic from which Go cannot recover.
type Session interface {
	GetAppName() string
	GetDeviceID() (string, error)
	GetUserID() (int64, error)
	GetToken() (string, error)
	SetCountry(string) error
	UpdateAdSettings(AdSettings) error
	UpdateStats(string, string, string, int, int, bool) error
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
	IsPlayVersion() (bool, error)
	Email() (string, error)
	Currency() (string, error)
	DeviceOS() (string, error)
	IsProUser() (bool, error)
	SetReplicaAddr(string)
	ForceReplica() bool
	SetChatEnabled(bool)

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
	UpdateStats(string, string, string, int, int, bool)
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
	IsPlayVersion() bool
	Email() string
	Currency() string
	DeviceOS() string
	IsProUser() bool
	SetChatEnabled(bool)

	// workaround for lack of any sequence types in gomobile bind... ;_;
	// used to implement GetInternalHeaders() map[string]string
	// Should return a JSON encoded map[string]string {"key":"val","key2":"val", ...}
	SerializedInternalHeaders() string

	Wrapped() Session
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

func (s *panickingSessionImpl) Wrapped() Session {
	return s.wrapped
}

func (s *panickingSessionImpl) GetAppName() string {
	return s.wrapped.GetAppName()
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

func (s *panickingSessionImpl) UpdateStats(city, country, countryCode string, httpsUpgrades, adsBlocked int, hasSucceedingProxy bool) {
	panicIfNecessary(s.wrapped.UpdateStats(city, country, countryCode, httpsUpgrades, adsBlocked, hasSucceedingProxy))
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

func (s *panickingSessionImpl) SetChatEnabled(enabled bool) {
	s.wrapped.SetChatEnabled(enabled)
}

func (s *panickingSessionImpl) SerializedInternalHeaders() string {
	result, err := s.wrapped.SerializedInternalHeaders()
	panicIfNecessary(err)
	return result
}

type userConfig struct {
	session panickingSession
}

func (uc *userConfig) GetAppName() string              { return common.DefaultAppName }
func (uc *userConfig) GetDeviceID() string             { return uc.session.GetDeviceID() }
func (uc *userConfig) GetUserID() int64                { return uc.session.GetUserID() }
func (uc *userConfig) GetToken() string                { return uc.session.GetToken() }
func (uc *userConfig) GetEnabledExperiments() []string { return nil }
func (uc *userConfig) GetLanguage() string             { return uc.session.Locale() }
func (uc *userConfig) GetTimeZone() (string, error)    { return uc.session.GetTimeZone(), nil }
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

func getBalancer(timeout time.Duration) *balancer.Balancer {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	cl := getClient(ctx)
	if cl == nil {
		return nil
	}
	return cl.GetBalancer()
}

func getClient(ctx context.Context) *client.Client {
	_cl, _ := clEventual.Get(ctx)
	if _cl == nil {
		return nil
	}
	return _cl.(*client.Client)
}

func getDNSGrab(ctx context.Context) dnsgrab.Server {
	_dg, _ := dnsGrabEventual.Get(ctx)
	if _dg == nil {
		return nil
	}
	return _dg.(dnsgrab.Server)
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
	ctx, cancel := context.WithTimeout(context.Background(), startTimeout-elapsed())
	defer cancel()
	da, _ := dnsGrabAddrEventual.Get(ctx)
	if da == nil {
		err := fmt.Errorf("dnsgrab didn't start within %v timeout", startTimeout)
		log.Error(err.Error())
		return nil, err
	}
	return &StartResult{addr.(string), socksAddr.(string),
		da.(string)}, nil
}

// EnableLogging enables logging.
func EnableLogging(configDir string) {
	logging.EnableFileLogging(common.DefaultAppName, configDir)
}

func newAnalyticsSession(deviceID string) analytics.Session {
	session := analytics.Start(deviceID, common.Version)
	go func() {
		session.SetIP(geolookup.GetIP(forever))
	}()
	return session
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
		log.Errorf("unable to create configDir at %v: %v", configDir, err)
		return
	}

	if settings.StickyConfig() {
		flags["stickyconfig"] = true
		flags["readableconfig"] = true
	}

	log.Debugf("Writing log messages to %s/lantern.log", configDir)

	cache, err := persistentcache.New(filepath.Join(configDir, "dnsgrab.cache"), maxDNSGrabAge)
	if err != nil {
		log.Errorf("unable to open dnsgrab cache: %v", err)
		return
	}

	grabber, err := dnsgrab.ListenWithCache(
		"127.0.0.1:0",
		session.GetDNSServer,
		cache,
	)
	if err != nil {
		log.Errorf("unable to start dnsgrab: %v", err)
		return
	}
	dnsGrabEventual.Set(grabber)
	dnsGrabAddrEventual.Set(grabber.LocalAddr().String())
	go func() {
		serveErr := grabber.Serve()
		if serveErr != nil {
			log.Errorf("error serving dns: %v", serveErr)
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
	globalConfigChanged := make(chan interface{})
	geoRefreshed := geolookup.OnRefresh()

	var runner *flashlight.Flashlight
	runner, err = flashlight.New(
		common.DefaultAppName,
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
			if session.IsPlayVersion() {
				runner.EnableNamedDomainRules("google_play") // for google play build we want to make sure that Google Play domains are not being proxied
			}
			email.SetDefaultRecipient(cfg.ReportIssueEmail)
			select {
			case globalConfigChanged <- nil:
				// okay
			default:
				// don't block
			}
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
				return "", errors.New("invalid IP address")
			}
			if splitErr != nil {
				return updatedHost, nil
			}
			return fmt.Sprintf("%v:%v", updatedHost, port), nil
		},
		func() string { return "" },
		func(category, action, label string) {},
		nil,
	)
	if err != nil {
		log.Fatalf("failed to start flashlight: %v", err)
	}

	replicaServer := &ReplicaServer{
		ConfigDir:        configDir,
		Flashlight:       runner,
		analyticsSession: newAnalyticsSession(session.GetDeviceID()),
		Session:          session.Wrapped(),
		UserConfig:       userConfig,
	}
	session.Wrapped().SetReplicaAddr("") // start off with no Replica address

	// Check whether features should be enabled anytime that the global config changes or our geolocation info changed,
	// and also check right at start.
	//
	// TODO: should also check if our user info changes. Right now we don't segment on users so it's not urgent.
	// TODO: a lot of this feature enabled stuff, including checking whether enabled features have changed and permanently
	//       remembering enabled features, seems like it should just be baked into the enabled features logic in flashlight.
	checkFeatures := func() {
		replicaServer.CheckEnabled()
		chatEnabled := runner.FeatureEnabled("chat")
		log.Debugf("Chat enabled? %v", chatEnabled)
		session.SetChatEnabled(chatEnabled)
	}

	// When features are enabled/disabled, the UI changes. To minimize this, we only check features once on startup, preferring
	// to do it based on geography but not waiting too long for that
	go func() {
		select {
		case <-geoRefreshed:
			checkFeatures()
		case <-time.After(5 * time.Second):
			<-globalConfigChanged
			checkFeatures()
		}
	}()
	replicaServer.CheckEnabled()

	go runner.Run(
		httpProxyAddr, // listen for HTTP on provided address
		"127.0.0.1:0", // listen for SOCKS on random address
		func(c *client.Client) {
			clEventual.Set(c)
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
	if allowed > 50000000 {
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
