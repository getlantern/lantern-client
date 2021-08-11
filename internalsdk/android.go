// package internalsdk implements the mobile application functionality of flashlight
package internalsdk

import (
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"net/http"
	"os"
	"path/filepath"
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
	DefaultDnsServer() string
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

	SetSentryExtra(key, value string) error
}

// panickingSession mimics the Session interface but its methods panic instead of returning errors
// In practice, this is implemented by panicLoggingSession which first logs errors to Sentry before
// panicking.
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

	SetSentryExtra(key, value string)
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
}

// ProtectConnections allows connections made by Lantern to be protected from
// routing via a VPN. This is useful when running Lantern as a VPN on Android,
// because it keeps Lantern's own connections from being captured by the VPN and
// resulting in an infinite loop.

// The DNS server is used to resolve host only when dialing a protected connection
// from within Lantern client.
func ProtectConnections(protector SocketProtector, dnsServer string) {
	defer sentryRecover(nil)

	log.Debug("Protecting connections")
	p := protected.New(protector.ProtectConn, dnsServer)
	netx.OverrideDial(p.DialContext)
	netx.OverrideDialUDP(p.DialUDP)
	netx.OverrideResolve(p.ResolveTCP)
	netx.OverrideResolveUDP(p.ResolveUDP)
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
	defer sentryRecover(nil)

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
	defer sentryRecover(nil)

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

	defer sentryRecover(wrappedSession)

	session := &panicLoggingSession{wrappedSession}

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
	log.Debugf("Starting socks proxy at %s", socksAddr)

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
		session.GetDNSServer(),
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
		newUserConfig(session),
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
	)
	if err != nil {
		log.Fatalf("Failed to start flashlight: %v", err)
	}

	configureSentryScope(session)

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
