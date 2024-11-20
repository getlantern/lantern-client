// package sdk provides an API for interacting with flashlight
package sdk

// #cgo LDFLAGS: -static-libstdc++
import "C"

import (
	"errors"
	"fmt"
	"net"
	"strconv"
	"sync"
	"time"

	"github.com/getlantern/flashlight/client"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
)

const startTimeout = 5 * time.Second

var (
	log = golog.LoggerFor("lantern")

	once sync.Once

	cl       *client.Client
	clientMu sync.Mutex

	ss         *settings
	settingsMu sync.Mutex
)

type settings struct {
	configDir string
	locale    string
}

// StartResult provides information about the started Lantern
type StartResult struct {
	Addr string
}

func Setup(apiKey, configDir, locale string) {
	settingsMu.Lock()
	defer settingsMu.Unlock()
	ss = &settings{
		configDir: configDir,
		locale:    locale,
	}
}

// StartHTTPProxy starts an HTTP proxy at the requested address. It blocks up
// til the given timeout and returns the address the proxy is listening. If the proxy doesn't
// start within the given timeout, this method returns an error.
func StartHTTPProxy(httpProxyAddr string) (*StartResult, error) {
	settingsMu.Lock()
	settings := ss
	settingsMu.Unlock()
	if settings == nil {
		return nil, errors.New("Missing setup call")
	}
	once.Do(func() {
		go runFlashlight(settings, httpProxyAddr)
	})

	addr, ok := client.Addr(startTimeout)
	if !ok {
		return nil, fmt.Errorf("HTTP Proxy didn't start within %v timeout", startTimeout)
	}
	return &StartResult{addr.(string)}, nil
}

func setClient(c *client.Client) {
	clientMu.Lock()
	defer clientMu.Unlock()
	cl = c
}

func getClient() *client.Client {
	clientMu.Lock()
	c := cl
	clientMu.Unlock()
	return c
}

func StopHTTPProxy() error {
	cl := getClient()
	if cl == nil {
		return errors.New("flashlight is not running")
	}
	if err := cl.Stop(); err != nil {
		return err
	}
	return nil
}

// HTTPProxyPort returns the port the HTTP proxy is listening on
func HTTPProxyPort() (int, error) {
	result, isValid := client.Addr(5 * time.Second)
	if !isValid {
		return 0, errors.New("flashlight is not running")
	}
	_, portStr, _ := net.SplitHostPort(result.(string))
	port, _ := strconv.Atoi(portStr)
	return port, nil
}

func runFlashlight(ss *settings, httpProxyAddr string) *flashlight.Flashlight {
	configDir, locale := ss.configDir, ss.locale
	log.Debugf("Starting lantern: configDir %s locale %s", configDir, locale)

	userConfig := common.NewUserConfig("", "a34113", 3456344, "tok123", map[string]string{}, "")

	runner, err := flashlight.New(
		common.DefaultAppName,
		common.ApplicationVersion,
		common.RevisionDate,
		configDir,                    // place to store lantern configuration
		false,                        // don't enable vpn mode for Android (VPN is handled in Java layer)
		func() bool { return false }, // always connected
		func() bool { return true },
		func() bool { return false }, // do not proxy private hosts on Android
		func() bool { return true },  // auto report
		map[string]interface{}{},
		userConfig,
		stats.NewTracker(),
		func() bool { return false },
		func() string { return "" }, // only used for desktop
		nil,
		func(category, action, label string) {},
	)
	if err != nil {
		log.Fatalf("failed to start flashlight: %v", err)
	}
	go func() {
		runner.Run(
			httpProxyAddr, // listen for HTTP on provided address
			"127.0.0.1:0", // listen for SOCKS on random address
			func(c *client.Client) {
				setClient(c)
			},
			nil, // onError
		)
	}()
}
