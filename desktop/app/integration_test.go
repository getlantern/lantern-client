//go:build integration
// +build integration

package app

import (
	"context"
	"crypto/tls"
	"io/ioutil"
	"net/http"
	"net/url"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/getlantern/flashlight/v7"
	flashops "github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/golog"
	"github.com/getlantern/golog/testlog"
	"github.com/getlantern/ops"
	"github.com/getlantern/waitforserver"

	"github.com/getlantern/flashlight/v7/chained"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/goroutines"
	"github.com/getlantern/flashlight/v7/integrationtest"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/lantern-client/desktop/doh"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	LocalProxyAddr = "localhost:18345"
	SocksProxyAddr = "localhost:18346"
)

// TestProxyinAll is a comprehensive functional test for all supported proxy
// protocols. For a simpler and shorter test only, see TestProxyingHttpSimple
// below
func TestProxyinAll(t *testing.T) {
	if testing.Short() {
		t.Skip("Skip test in short mode")
	}

	golog.SetPrepender(logging.Timestamped)
	defer testlog.Capture(t)()

	chained.InsecureSkipVerifyTLSMasqOrigin = true
	defer func() { chained.InsecureSkipVerifyTLSMasqOrigin = false }()

	reporter := func(failure error, dimensions map[string]interface{}) {
		values := map[string]flashops.Val{}

		// Convert metrics to values
		for dim, val := range dimensions {
			metric, ok := val.(flashops.Val)
			if ok {
				delete(dimensions, dim)
				values[dim] = metric
			}
		}

		_op, found := dimensions["op"]
		if !found {
			return
		}
		op := _op.(string)

		getVal := func(name string) float64 {
			val := values[name]
			if val == nil {
				return 0
			}
			return val.Get().(float64)
		}

		switch op {
		case "client_stopped":
			uptime := getVal("uptime")
			assert.True(t, uptime > 0, "Uptime should be greater than 0")
			assert.True(t, uptime < 5000, "Uptime should be less than 5 seconds")
			assert.Equal(t, strings.ToLower(common.DefaultAppName)+"-client", dimensions["app"])
		case "catchall_fatal":
			assert.Equal(t, "test fatal error", dimensions["error"])
			assert.Equal(t, "test fatal error", dimensions["error_text"])
		case "probe":
			assert.True(t, getVal("probe_rtt") > 0)
		}
	}
	ops.RegisterReporter(reporter)

	baseListenPort := 23000
	helper, err := integrationtest.NewHelper(t, baseListenPort)
	assert.NoError(t, err)
	// Starts the Lantern App
	a, err := startApp(t, helper)
	assert.NoError(t, err)

	proxyURL, _ := url.Parse("http://" + LocalProxyAddr)
	client := &http.Client{
		Transport: &http.Transport{
			Proxy: http.ProxyURL(proxyURL),
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
		Timeout: time.Second * 10,
	}

	testRequest := func(t *testing.T) {
		doRequest(t, client, "http://"+helper.HTTPServerAddr)
		doRequest(t, client, "https://"+helper.HTTPSServerAddr)
		goroutines.PrintProfile(10)
	}

	protocols := []string{
		"https",
		"quic_ietf",
		"shadowsocks",
		"shadowsocks+mux",
		"tlsmasq",
		"https+smux",
		"https+psmux",
	}

	for i, proto := range protocols {
		if i > 0 {
			// https is the default
			helper.SetProtocol(proto)
			time.Sleep(2 * time.Second)
		}
		t.Run(proto, testRequest)
	}

	// Disconnected Lantern and try again
	a.Disconnect()
	t.Run("disconnected", testRequest)

	// Connect Lantern and try again
	a.Connect()
	t.Run("reconnected", testRequest)

	// Do a fake proxybench op to make sure it gets reported
	ops.Begin("proxybench").Set("success", false).End()

	log.Fatal("test fatal error")
	log.Debug("Exiting")
	a.Exit(nil)

	helper.Close()
	// now starts a new helper and application test multipath with all protocols
	helper, err = integrationtest.NewHelper(t, baseListenPort+1000)
	assert.NoError(t, err)
	defer helper.Close()

	log.Debug("Starting app")
	a, err = startApp(t, helper)
	assert.NoError(t, err)
	defer func() {
		log.Debug("Exiting app")
		a.Exit(nil)
	}()

	proto := strings.Join(protocols, ",")
	helper.SetProtocol(proto)
	time.Sleep(2 * time.Second)
	t.Run("multipath with "+proto, testRequest)
}

func startApp(t *testing.T, helper *integrationtest.Helper) (*App, error) {
	ctx := context.Background()
	configURL := "http://" + helper.ConfigServerAddr
	flags := flashlight.Flags{
		CloudConfig:        configURL,
		Addr:               LocalProxyAddr,
		SocksAddr:          SocksProxyAddr,
		Headless:           true,
		ProxyAll:           true,
		ConfigDir:          helper.ConfigDir,
		Initialize:         false,
		VPN:                false,
		StickyConfig:       false,
		ClearProxySettings: false,
		ReadableConfig:     true,
		UIAddr:             "127.0.0.1:16823",
		Timeout:            time.Duration(0),
	}
	ss := emptySettings()
	a, err := NewAppWithFlags(flags, helper.ConfigDir)
	require.NoError(t, err)
	id := ss.GetUserID()
	if id == 0 {
		ss.SetUserIDAndToken(1, "token")
	}

	go a.Run(ctx)

	return a, waitforserver.WaitForServer("tcp", LocalProxyAddr, 10*time.Second)
}

func doRequest(t *testing.T, client *http.Client, url string) {
	resp, err := client.Get(url)
	if assert.NoError(t, err, "Unable to GET for "+url) {
		defer resp.Body.Close()
		b, err := ioutil.ReadAll(resp.Body)
		if assert.NoError(t, err, "Unable to read response for "+url) {
			if assert.Equal(t, http.StatusOK, resp.StatusCode, "Bad response status for "+url+": "+string(b)) {
				assert.Equal(t, integrationtest.Content, string(b))
			}
		}
	}
}

// TestProxyingHttpSimple runs lantern-desktop's app, sends a couple of
// requests through the proxy, and asserts if the request return a 200 OK.
//
// This test only uses 'https' protocol
func TestProxyingHttpSimple(t *testing.T) {
	defer testlog.Capture(t)()

	helper, err := integrationtest.NewHelper(t, 23000)
	require.NoError(t, err)
	defer helper.Close()
	helper.SetProtocol("https")
	time.Sleep(2 * time.Second)

	_, err = startApp(t, helper)
	require.NoError(t, err)

	proxyURL, err := url.Parse("http://" + LocalProxyAddr)
	require.NoError(t, err)
	client := &http.Client{
		Transport: &http.Transport{
			Proxy: http.ProxyURL(proxyURL),
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}
	f := func(url string) {
		resp, err := client.Get(url)
		require.NoError(t, err)
		defer resp.Body.Close()
		_, err = ioutil.ReadAll(resp.Body)
		require.NoError(t, err)
		require.Equal(t, http.StatusOK, resp.StatusCode)
	}
	f("https://httpbin.org/get")
	f("https://www.google.com/humans.txt")
}

// TestProxyingDohSimple runs lantern-desktop's app, sends a couple of
// DoH (dns-over-https) requests through the proxy, and asserts if the responses
// match those of 'dig'
//
// This test only uses 'https' protocol
func TestProxyingDohSimple(t *testing.T) {
	defer testlog.Capture(t)()

	helper, err := integrationtest.NewHelper(t, 23000)
	require.NoError(t, err)
	defer helper.Close()
	helper.SetProtocol("https")
	time.Sleep(2 * time.Second)
	_, err = startApp(t, helper)
	require.NoError(t, err)

	proxyURL, err := url.Parse("http://" + LocalProxyAddr)
	require.NoError(t, err)
	httpClient := &http.Client{
		Transport: &http.Transport{
			Proxy: http.ProxyURL(proxyURL),
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
		Timeout: time.Second * 10,
	}

	for _, tcase := range []struct {
		host string
	}{
		{host: "cloudflare.com"},
		{host: "amazon.com"},
		{host: "ft.com"},
	} {
		t.Run(tcase.host, func(t *testing.T) {
			ctx, cancelFunc := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancelFunc()
			resp, err := doh.MakeDohRequest(ctx, httpClient, doh.DnsDomain(tcase.host), doh.TypeA)
			require.NoError(t, err)
			require.NotNil(t, resp)

			// Assert our results match those of dig
			cmd := exec.Command("dig", tcase.host, "+short")
			out, err := cmd.CombinedOutput()
			require.NoError(t, err)
			dnsRespFromDigArr := strings.Split(strings.TrimSpace(string(out)), "\n")
			for _, dohResp := range resp.Answer {
				require.Contains(t, dnsRespFromDigArr, dohResp.Data)
			}
		})
	}
}
