package internalsdk

import (
	"context"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"net/url"
	"strings"
	"testing"
	"time"

	"golang.org/x/net/proxy"

	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/integrationtest"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type testSession struct {
	serializedInternalHeaders string
}

type testSettings struct {
	Settings
}

func (c testSettings) StickyConfig() bool       { return true }
func (c testSettings) TimeoutMillis() int       { return 15000 }
func (c testSettings) GetHttpProxyHost() string { return "127.0.0.1" }
func (c testSettings) GetHttpProxyPort() int    { return 49128 }
func (c testSettings) GetReplicaPort() int      { return 0 }
func (c testSettings) ShouldRunReplica() bool   { return false }

func (c testSession) AfterStart() error                                        { return nil }
func (c testSession) BandwidthUpdate(int, int, int, int) error                 { return nil }
func (c testSession) ConfigUpdate(bool) error                                  { return nil }
func (c testSession) GetUserID() (int64, error)                                { return 0, nil }
func (c testSession) GetToken() (string, error)                                { return "", nil }
func (c testSession) GetForcedCountryCode() (string, error)                    { return "", nil }
func (c testSession) GetDNSServer() (string, error)                            { return "8.8.8.8", nil }
func (c testSession) SetStaging(bool) error                                    { return nil }
func (c testSession) SetCountry(string) error                                  { return nil }
func (c testSession) SetIP(string) error                                       { return nil }
func (c testSession) ProxyAll() (bool, error)                                  { return true, nil }
func (c testSession) GetDeviceID() (string, error)                             { return "123456789", nil }
func (c testSession) AccountId() (string, error)                               { return "1234", nil }
func (c testSession) Locale() (string, error)                                  { return "en-US", nil }
func (c testSession) GetTimeZone() (string, error)                             { return "Americas/Chicago", nil }
func (c testSession) IsProUser() (bool, error)                                 { return true, nil }
func (c testSession) ForceReplica() bool                                       { return true }
func (c testSession) SetReplicaAddr(replicaAddr string)                        {}
func (c testSession) SplitTunnelingEnabled() (bool, error)                     { return true, nil }
func (c testSession) UpdateStats(string, string, string, int, int, bool) error { return nil }

func (c testSession) UpdateAdSettings(AdSettings) error { return nil }

func (c testSession) GetAppName() string                         { return "lantern" }
func (c testSession) AppVersion() (string, error)                { return "6.9.0", nil }
func (c testSession) Code() (string, error)                      { return "1", nil }
func (c testSession) Currency() (string, error)                  { return "usd", nil }
func (c testSession) DeviceOS() (string, error)                  { return "android", nil }
func (c testSession) Email() (string, error)                     { return "test@getlantern.org", nil }
func (c testSession) GetCountryCode() (string, error)            { return "us", nil }
func (c testSession) IsStoreVersion() (bool, error)              { return false, nil }
func (c testSession) Provider() (string, error)                  { return "stripe", nil }
func (c testSession) SetChatEnabled(enabled bool)                {}
func (c testSession) SetMatomoEnabled(bool)                      {}
func (c testSession) IsPlayVersion() (bool, error)               { return false, nil }
func (c testSession) SetShowInterstitialAdsEnabled(enabled bool) {}

func (c testSession) SerializedInternalHeaders() (string, error) {
	return c.serializedInternalHeaders, nil
}

func TestProxying(t *testing.T) {

	baseListenPort := 24000
	helper, err := integrationtest.NewHelper(t, baseListenPort)
	if assert.NoError(t, err, "Unable to create temp configDir") {
		defer helper.Close()
		result, err := Start(helper.ConfigDir, "en_US", testSettings{}, testSession{})
		require.NoError(t, err, "Should have been able to start lantern")
		newResult, err := Start("testapp", "en_US", testSettings{}, testSession{})
		require.NoError(t, err, "Should have been able to start lantern twice")
		require.Equal(t, result.HTTPAddr, newResult.HTTPAddr, "2nd start should have resulted in the same address")
		err = testProxiedRequest(helper, result.HTTPAddr, result.DNSGrabAddr, false)
		require.NoError(t, err, "Proxying request via HTTP should have worked")
		err = testProxiedRequest(helper, result.SOCKS5Addr, result.DNSGrabAddr, true)
		assert.NoError(t, err, "Proxying request via SOCKS should have worked")
		// testRelay(t)
	}
}

func testProxiedRequest(helper *integrationtest.Helper, proxyAddr string, dnsGrabAddr string, socks bool) error {
	host := helper.HTTPServerAddr
	if socks {
		resolver := &net.Resolver{
			PreferGo: true,
			Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
				// use dnsgrabber to resolve
				return net.DialTimeout("udp", dnsGrabAddr, 2*time.Second)
			},
		}
		resolved, err := resolver.LookupHost(context.Background(), host)
		log.Debugf("resolved %v to %v: %v", host, resolved, err)
		for _, addr := range resolved {
			ip := net.ParseIP(addr).To4()
			if ip != nil {
				log.Debugf("Using resolved IPv4 address: %v", addr)
				host = addr
				break
			}
		}
	}
	hostWithPort := fmt.Sprintf("%v:80", host)

	req, _ := http.NewRequest(http.MethodGet, fmt.Sprintf("http://%v/humans.txt", host), nil)
	req.Header.Set("Host", hostWithPort)

	transport := &http.Transport{}
	if socks {
		// Set up SOCKS proxy
		proxyURL, err := url.Parse("socks5://" + proxyAddr)
		if err != nil {
			return fmt.Errorf("Failed to parse proxy URL: %v\n", err)
		}

		socksDialer, err := proxy.FromURL(proxyURL, proxy.Direct)
		if err != nil {
			return fmt.Errorf("Failed to obtain proxy dialer: %v\n", err)
		}
		transport.Dial = socksDialer.Dial
	} else {
		proxyURL, _ := url.Parse("http://" + proxyAddr)
		transport.Proxy = http.ProxyURL(proxyURL)
	}

	client := &http.Client{
		Timeout:   time.Second * 15,
		Transport: transport,
	}

	var res *http.Response
	var err error

	if res, err = client.Do(req); err != nil {
		return err
	}

	var buf []byte

	buf, err = ioutil.ReadAll(res.Body)
	if err != nil {
		return err
	}

	fmt.Printf(string(buf) + "\n")

	if string(buf) != integrationtest.Content {
		return errors.New("expecting another response.")
	}

	return nil
}

func testRelay(t *testing.T) {
	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err, "should listen")
	defer l.Close()

	log.Debug("allocating relay")
	relayAddr, err := AllocateRelayAddress(l.Addr().String())
	require.NoError(t, err, "should allocate relay")

	log.Debugf("relaying to %v", relayAddr)
	localRelayAddr, err := RelayTo(relayAddr)
	require.NoError(t, err, "should get relayAddr")

	log.Debug("dialing relay")
	peer, err := net.Dial("tcp", localRelayAddr)
	require.NoError(t, err)
	defer peer.Close()

	log.Debug("writing hello")
	_, err = peer.Write([]byte("hello"))
	require.NoError(t, err)

	log.Debug("accepting")
	client, err := l.Accept()
	require.NoError(t, err)
	defer client.Close()

	log.Debug("reading")
	b := make([]byte, 5)
	_, err = io.ReadFull(client, b)
	require.NoError(t, err)

	require.Equal(t, "hello", string(b), "client should read hello")
}

func TestInternalHeaders(t *testing.T) {
	var tests = []struct {
		input    string
		expected map[string]string
	}{
		// Legit
		{
			"{\"X-Lantern-Foo-Bar\": \"foobar\", \"X-Lantern-Baz\": \"quux\"}",
			map[string]string{"X-Lantern-Foo-Bar": "foobar", "X-Lantern-Baz": "quux"},
		},
		// Ignored
		{
			"",
			map[string]string{},
		},
		{
			"jf91283r7f0--",
			map[string]string{},
		},
		{
			"[\"X-Lantern-Foo-Bar\", \"foobar\"]",
			map[string]string{},
		},
		// Partially ignored
		{
			"{\"X-Lantern-Foo-Bar\": {\"foobar\": \"baz\"}, \"X-Lantern-Baz\": \"quux\"}",
			map[string]string{"X-Lantern-Baz": "quux"},
		},
	}

	for _, test := range tests {
		s := UserConfig{&panickingSessionImpl{testSession{serializedInternalHeaders: test.input}}}
		got := s.GetInternalHeaders()
		assert.Equal(t, test.expected, got, "Headers did not decode as expected")
	}
}

type testDeviceInfo struct {
	DeviceInfo
}

func (d testDeviceInfo) DeviceID() string { return "123456789" }
func (d testDeviceInfo) UserID() string   { return "1" }
func (d testDeviceInfo) Model() string    { return "Nokia 7 plus" }
func (d testDeviceInfo) Hardware() string { return "qcom" }
func (d testDeviceInfo) SdkVersion() int  { return 28 }

type testUpdater struct{}

func (tu testUpdater) Progress(percent int) {

}

// This test requires the tag "lantern" to be set at testing time like:
//
//	go test -tags="lantern"
func TestAutoUpdate(t *testing.T) {
	if testing.Short() {
		t.Skip("Skip test in short mode")
	}

	updateCfg := buildUpdateCfg()
	updateCfg.HTTPClient = &http.Client{}
	updateCfg.CurrentVersion = "0.0.1"
	updateCfg.OS = "android"
	updateCfg.Arch = "arm"

	deviceInfo := testDeviceInfo{}
	// Update available
	result, err := checkForUpdates(updateCfg, deviceInfo)
	require.NoError(t, err)
	assert.Contains(t, result, "update_android_arm.bz2")
	assert.Contains(t, result, strings.ToLower(common.DefaultAppName))

	// No update available
	updateCfg.CurrentVersion = "9999.9.9"
	result, err = checkForUpdates(updateCfg, deviceInfo)
	require.NoError(t, err)
	assert.Empty(t, result)
}

func TestCheckForUpdates(t *testing.T) {
	deviceInfo := testDeviceInfo{}
	result, err := CheckForUpdates(deviceInfo)
	require.NoError(t, err, "Update check should succeed")
	require.Empty(t, result, "UpdateURL should be empty because no update is available")
}

func TestDownloadUpdate(t *testing.T) {
	deviceInfo := testDeviceInfo{}
	assert.False(t, DownloadUpdate(deviceInfo, "", "", &testUpdater{}))
}
