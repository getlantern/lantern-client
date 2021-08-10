package internalsdk

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"net/url"
	"strings"
	"testing"
	"time"

	"golang.org/x/net/proxy"

	"github.com/getlantern/flashlight/common"
	"github.com/getlantern/flashlight/integrationtest"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type testProtector struct{}

type testSession struct {
	Session
	serializedInternalHeaders string
}

type testSettings struct {
	Settings
}

func (c testSettings) StickyConfig() bool       { return true }
func (c testSettings) TimeoutMillis() int       { return 15000 }
func (c testSettings) GetHttpProxyHost() string { return "127.0.0.1" }
func (c testSettings) GetHttpProxyPort() int    { return 49128 }

func (c testSession) AfterStart() error                        { return nil }
func (c testSession) BandwidthUpdate(int, int, int, int) error { return nil }
func (c testSession) ConfigUpdate(bool) error                  { return nil }
func (c testSession) GetUserID() (int64, error)                { return 0, nil }
func (c testSession) GetToken() (string, error)                { return "", nil }
func (c testSession) GetForcedCountryCode() (string, error)    { return "", nil }
func (c testSession) GetDNSServer() (string, error)            { return "8.8.8.8", nil }
func (c testSession) SetStaging(bool) error                    { return nil }
func (c testSession) SetCountry(string) error                  { return nil }
func (c testSession) ProxyAll() (bool, error)                  { return true, nil }
func (c testSession) GetDeviceID() (string, error)             { return "123456789", nil }
func (c testSession) AccountId() (string, error)               { return "1234", nil }
func (c testSession) Locale() (string, error)                  { return "en-US", nil }
func (c testSession) GetTimeZone() (string, error)             { return "Americas/Chicago", nil }
func (c testSession) IsProUser() (bool, error)                 { return true, nil }

func (c testSession) UpdateStats(string, string, string, int, int) error { return nil }

func (c testSession) UpdateAdSettings(AdSettings) error { return nil }

func (c testSession) SerializedInternalHeaders() (string, error) {
	return c.serializedInternalHeaders, nil
}

func (c testSession) SetSentryExtra(key, value string) error { return nil }

func TestProxying(t *testing.T) {

	baseListenPort := 24000
	helper, err := integrationtest.NewHelper(t, baseListenPort)
	if assert.NoError(t, err, "Unable to create temp configDir") {
		defer helper.Close()
		result, err := Start(helper.ConfigDir, "en_US", testSettings{}, testSession{})
		if assert.NoError(t, err, "Should have been able to start lantern") {
			newResult, err := Start("testapp", "en_US", testSettings{}, testSession{})
			if assert.NoError(t, err, "Should have been able to start lantern twice") {
				if assert.Equal(t, result.HTTPAddr, newResult.HTTPAddr, "2nd start should have resulted in the same address") {
					err := testProxiedRequest(helper, result.HTTPAddr, result.DNSGrabAddr, false)
					if assert.NoError(t, err, "Proxying request via HTTP should have worked") {
						err := testProxiedRequest(helper, result.SOCKS5Addr, result.DNSGrabAddr, true)
						assert.NoError(t, err, "Proxying request via SOCKS should have worked")
					}
				}
			}
		}
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

	fmt.Printf(string(buf) + "\n")

	if string(buf) != integrationtest.Content {
		return errors.New("Expecting another response.")
	}

	return nil
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
		s := userConfig{&panicLoggingSession{testSession{serializedInternalHeaders: test.input}}}
		got := s.GetInternalHeaders()
		assert.Equal(t, test.expected, got, "Headers did not decode as expected")
	}
}

// This test requires the tag "lantern" to be set at testing time like:
//
//    go test -tags="lantern"
//
func TestAutoUpdate(t *testing.T) {
	if testing.Short() {
		t.Skip("Skip test in short mode")
	}

	updateCfg := buildUpdateCfg()
	updateCfg.HTTPClient = &http.Client{}
	updateCfg.CurrentVersion = "0.0.1"
	updateCfg.OS = "android"
	updateCfg.Arch = "arm"

	// Update available
	result, err := checkForUpdates(updateCfg)
	require.NoError(t, err)
	assert.Contains(t, result, "update_android_arm.bz2")
	assert.Contains(t, result, strings.ToLower(common.AppName))

	// No update available
	updateCfg.CurrentVersion = "9999.9.9"
	result, err = checkForUpdates(updateCfg)
	require.NoError(t, err)
	assert.Empty(t, result)
}
