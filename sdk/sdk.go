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

	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
)

const startTimeout = 5 * time.Second

var (
	log = golog.LoggerFor("lantern")

	once sync.Once

	cl       *lanternClient
	clientMu sync.Mutex
)

type lanternClient struct {
	*client.Client

	appName   string
	configDir string

	mu sync.Mutex
}

// StartResult provides information about the started Lantern
type StartResult struct {
	Addr string
}

// Setup is used to initially configure the Lantern SDK and specifies the config directory and app name to use
// - appName: unique identifier for the current application (used for assigning proxies and tracking usage)
// - configDir: application directory to place Lantern configure files
func Setup(appName, configDir string) {
	clientMu.Lock()
	defer clientMu.Unlock()
	cl = &lanternClient{
		appName:   appName,
		configDir: configDir,
	}
}

// start starts Lantern and sets it as the system proxy at the requested address. It blocks up
// til the given timeout and returns the address the proxy is listening. If the proxy doesn't
// start within the given timeout, this method returns an error.
// - appName: unique identifier for the current application (used for assigning proxies and tracking usage)
// - proxyAll: if true, traffic to all domains will be proxied. If false, only domains on Lantern's whitelist, or domains detected as blocked, will be proxied.
// - startTimeoutMillis: how long to wait for Lantern to start before throwing an exception
// It returns the address at which the Lantern HTTP proxy is listening for connections.
func Start(
	httpProxyAddr string,
	proxyAll bool,
) (*StartResult, error) {
	return start(httpProxyAddr, proxyAll, 10*time.Second)
}

func start(
	httpProxyAddr string,
	proxyAll bool,
	startTimeoutMillis time.Duration,
) (*StartResult, error) {
	clientMu.Lock()
	client := cl
	clientMu.Unlock()
	if client == nil {
		return nil, errors.New("Missing setup call")
	}
	once.Do(func() {
		go runLantern(client, httpProxyAddr, proxyAll, startTimeoutMillis)
	})

	addr, ok := client.Addr(startTimeout)
	if !ok {
		return nil, fmt.Errorf("HTTP Proxy didn't start within %v timeout", startTimeout)
	}
	return &StartResult{addr.(string)}, nil
}

func setClient(c *lanternClient) {
	clientMu.Lock()
	defer clientMu.Unlock()
	cl = c
}

func getClient() *lanternClient {
	clientMu.Lock()
	c := cl
	clientMu.Unlock()
	return c
}

// Stops circumventing with Lantern. Lantern will actually continue running in the background
// in order to keep its configuration up-to-date. Subsequent calls to start() will reuse the
// running Lantern and complete quickly.
func Stop() error {
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

func runLantern(cl *lanternClient, httpProxyAddr string, proxyAll bool, startTimeoutMillis time.Duration) *flashlight.Flashlight {
	appName, configDir := cl.appName, cl.configDir
	log.Debugf("Starting lantern: configDir %s", configDir)

	userConfig := common.NewUserConfig("", "a34113", 3456344, "tok123", map[string]string{}, "")

	runner, err := flashlight.New(
		appName,
		common.ApplicationVersion,
		common.RevisionDate,
		configDir,                    // place to store lantern configuration
		false,                        // don't enable vpn mode for Android (VPN is handled in Java layer)
		func() bool { return false }, // always connected
		func() bool { return proxyAll },
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
				setClient(cl)
			},
			nil, // onError
		)
	}()
	return runner
}
