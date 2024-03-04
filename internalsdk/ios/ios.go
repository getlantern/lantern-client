package ios

import (
	"context"
	"io"
	"net"
	"path/filepath"
	"sync"
	"time"

	"github.com/getlantern/common/config"
	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/dnsgrab/persistentcache"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/bandit"
	"github.com/getlantern/flashlight/v7/buffers"
	"github.com/getlantern/flashlight/v7/chained"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/idletiming"
	"github.com/getlantern/ipproxy"
	"github.com/getlantern/netx"
	"gvisor.dev/gvisor/pkg/buffer"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv4"
	"gvisor.dev/gvisor/pkg/tcpip/stack"
)

const (
	maxDNSGrabAge = 1 * time.Hour // this doesn't need to be long because our fake DNS records have a TTL of only 1 second. We use a smaller value than on Android to be conservative with memory usag.

	quotaSaveInterval            = 1 * time.Minute
	shortFrontedAvailableTimeout = 30 * time.Second
	longFrontedAvailableTimeout  = 5 * time.Minute

	logMemoryInterval = 5 * time.Second
	forceGCInterval   = 250 * time.Millisecond

	dialTimeout      = 30 * time.Second
	shortIdleTimeout = 5 * time.Second
	closeTimeout     = 1 * time.Second

	maxConcurrentDials         = 2
	ipWriteBufferDepth         = 100
	downstreamWriteBufferDepth = 100
)

type Writer interface {
	Write([]byte) bool
}

type writeRequest struct {
	b  []byte
	ok chan bool
}

type writerAdapter struct {
	writer    Writer
	requests  chan *writeRequest
	closeOnce sync.Once
}

func newWriterAdapter(writer Writer) io.WriteCloser {
	wa := &writerAdapter{
		writer:   writer,
		requests: make(chan *writeRequest, ipWriteBufferDepth),
	}

	// MEMORY_OPTIMIZATION - handle all writing of output packets on a single goroutine to avoid creating more native threads
	go wa.handleWrites()
	return wa
}

func (wa *writerAdapter) Write(b []byte) (int, error) {
	req := &writeRequest{
		b:  b,
		ok: make(chan bool),
	}
	wa.requests <- req
	ok := <-req.ok
	if !ok {
		return 0, errors.New("error writing")
	}
	return len(b), nil
}

func (wa *writerAdapter) handleWrites() {
	for req := range wa.requests {
		req.ok <- wa.writer.Write(req.b)
	}
}

func (wa *writerAdapter) Close() error {
	wa.closeOnce.Do(func() {
		close(wa.requests)
	})
	return nil
}

type ClientWriter interface {
	// Write writes the given bytes. As a side effect of writing, we periodically
	// record updated bandwidth quota information in the configured quota.txt file.
	// If user has exceeded bandwidth allowance, returns a positive integer
	// representing the bandwidth allowance.
	Write([]byte) (int, error)

	// Reconfigure forces the ClientWriter to update its configuration
	Reconfigure()

	Close() error
}

type cw struct {
	ipStack        io.WriteCloser
	client         *iosClient
	dialer         *bandit.BanditDialer
	ipp            ipproxy.Proxy
	quotaTextPath  string
	lastSavedQuota time.Time
}

func (c *cw) Write(b []byte) (int, error) {
	//_, err := c.ipStack.Write(b)
	c.ipp.Endpoint().InjectInbound(ipv4.ProtocolNumber, stack.NewPacketBuffer(stack.PacketBufferOptions{Payload: buffer.MakeWithData(b)}))
	result := 0
	return result, nil
}

func (c *cw) Reconfigure() {
	dialers, err := c.client.loadDialers()
	if err != nil {
		// this causes the NetworkExtension process to die. Since the VPN is configured as "on-demand",
		// the OS will automatically restart the service, at which point we'll read the new config anyway.
		panic(log.Errorf("Unable to load dialers on reconfigure: %v", err))
	}

	c.dialer, err = bandit.New(dialers)
	if err != nil {
		log.Errorf("Unable to create dialer on reconfigure: %v", err)
	}
}

func (c *cw) Close() error {
	if c.client != nil {
		c.client.packetsOut.Close()
	}
	return nil
}

type iosClient struct {
	packetsOut io.WriteCloser

	memChecker      MemChecker
	configDir       string
	mtu             int
	capturedDNSHost string
	realDNSHost     string
	uc              *UserConfig

	ipp ipproxy.Proxy

	clientWriter    *cw
	memoryAvailable int64
	started         time.Time
}

func Client(packetsOut Writer, memChecker MemChecker, configDir string, mtu int, capturedDNSHost, realDNSHost string) (ClientWriter, error) {
	LogDebug("Creating new iOS client")
	if mtu <= 0 {
		log.Debug("Defaulting MTU to 1500")
		mtu = 1500
	}

	c := &iosClient{
		packetsOut:      newWriterAdapter(packetsOut),
		memChecker:      memChecker,
		configDir:       configDir,
		mtu:             mtu,
		capturedDNSHost: capturedDNSHost,
		realDNSHost:     realDNSHost,
		started:         time.Now(),
	}
	c.optimizeMemoryUsage()
	go c.gcPeriodically()
	go c.logMemory()

	return c.start()
}

func createIPProxy(dialer *bandit.BanditDialer, dnsGrabAddr string, mtu int) (ipproxy.Proxy, error) {
	opts := &ipproxy.Opts{
		DeviceName:          "utun123",
		IdleTimeout:         70 * time.Second,
		StatsInterval:       15 * time.Second,
		DisableIPv6:         true,
		MTU:                 mtu,
		OutboundBufferDepth: 10000,
		TCPConnectBacklog:   100,
		DialTCP: func(ctx context.Context, network, addr string) (net.Conn, error) {
			return dialer.DialContext(ctx, network, addr)
		},
		DialUDP: func(ctx context.Context, network, addr string) (net.Conn, error) {
			_, port, _ := net.SplitHostPort(addr)
			isDNS := port == "53"
			if isDNS {
				// intercept and reroute DNS traffic to dnsgrab
				addr = dnsGrabAddr
			}
			conn, err := netx.DialContext(ctx, network, addr)
			if isDNS && err == nil {
				// wrap our DNS requests in a connection that closes immediately to avoid piling up file descriptors for DNS requests
				conn = idletiming.Conn(conn, 10*time.Second, nil)
			}
			return conn, err
		},
	}
	return ipproxy.New(opts)
}

func (o *iosClient) copyToDownstream(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		default:
			if ptr := o.ipp.Endpoint().ReadContext(ctx); ptr != nil {
				pktInfo := ptr.Clone()
				pkt := make([]byte, 0, o.mtu)

				for _, view := range pktInfo.AsSlices() {
					pkt = append(pkt, view...)
				}

				o.packetsOut.Write(pkt)
				pktInfo.DecRef()
				continue
			}
		}
	}
}

func (c *iosClient) start() (ClientWriter, error) {
	if err := c.loadUserConfig(); err != nil {
		return nil, log.Errorf("error loading user config: %v", err)
	}

	log.Debugf("Running client for device '%v' at config path '%v'", c.uc.GetDeviceID(), c.configDir)
	log.Debugf("Max buffer bytes: %d", buffers.MaxBufferBytes())

	dialers, err := c.loadDialers()
	if err != nil {
		return nil, err
	}
	dialer, err := bandit.New(dialers)
	if err != nil {
		return nil, err
	}
	// We use a persistent cache for dnsgrab because some clients seem to hang on to our fake IP addresses for a while, even though we set a TTL of 1 second.
	// That can be a problem when the network extension is automatically restarted. Caching the dns cache on disk allows us to successfully reverse look up
	// those IP addresses even after a restart.
	cacheFile := filepath.Join(c.configDir, "dnsgrab.cache")
	cache, err := persistentcache.New(cacheFile, maxDNSGrabAge)
	if err != nil {
		return nil, errors.New("Unable to initialize dnsgrab cache at %v: %v", cacheFile, err)
	}
	grabber, err := dnsgrab.ListenWithCache(
		"127.0.0.1:0",
		func() string { return c.realDNSHost },
		cache,
	)
	if err != nil {
		return nil, errors.New("Unable to start dnsgrab: %v", err)
	}

	ipp, err := createIPProxy(dialer, grabber.LocalAddr().String(), c.mtu)
	if err != nil {
		return nil, err
	}
	c.ipp = ipp
	ctx := context.Background()
	go c.copyToDownstream(ctx)

	freeMemory()

	c.clientWriter = &cw{
		ipp:           ipp,
		client:        c,
		dialer:        dialer,
		quotaTextPath: filepath.Join(c.configDir, "quota.txt"),
	}

	return c.clientWriter, nil
}

func (c *iosClient) loadDialers() ([]bandit.Dialer, error) {
	cf := &configurer{configFolderPath: c.configDir}
	chained.PersistSessionStates(c.configDir)

	proxies := make(map[string]*config.ProxyConfig)
	_, _, err := cf.openConfig(proxiesYaml, proxies, []byte{})
	if err != nil {
		return nil, err
	}

	dialers := chained.CreateDialers(c.configDir, proxies, c.uc)
	chained.TrackStatsFor(dialers, c.configDir)
	return dialers, nil
}

func partialUserConfigFor(deviceID string) *UserConfig {
	return userConfigFor(0, "", deviceID)
}

func userConfigFor(userID int, proToken, deviceID string) *UserConfig {
	// TODO: plug in implementation of fetching timezone for iOS to work around https://github.com/golang/go/issues/20455
	return &UserConfig{
		UserConfigData: *common.NewUserConfigData(
			"Lantern",
			deviceID,
			int64(userID),
			proToken,
			nil, // Headers currently unused
			"",  // Language currently unused
		),
	}
}
