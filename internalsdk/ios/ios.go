package ios

import (
	"io"
	"path/filepath"
	"sync"
	"time"

	tun2socks "github.com/eycorsican/go-tun2socks/core"

	"github.com/getlantern/common/config"
	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/dnsgrab/persistentcache"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/bandwidth"
	"github.com/getlantern/flashlight/v7/chained"
	"github.com/getlantern/flashlight/v7/dialer"
	"github.com/getlantern/flashlight/v7/stats"

	"github.com/getlantern/lantern-client/internalsdk/common"
)

const (
	maxDNSGrabAge = 1 * time.Hour // this doesn't need to be long because our fake DNS records have a TTL of only 1 second. We use a smaller value than on Android to be conservative with memory usag.

	quotaSaveInterval = 1 * time.Minute

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

type StatsTracker interface {
	UpdateStats(string, string, string, int, int, bool)
}

type BandwidthTracker interface {
	BandwidthUpdate(string, int, int, int, int)
}

type cw struct {
	ipStack       io.WriteCloser
	client        *iosClient
	quotaTextPath string
}

func (c *cw) Write(b []byte) (int, error) {
	_, err := c.ipStack.Write(b)

	result := 0
	return result, err
}

func (c *cw) Reconfigure() {
	if c.client != nil {
		c.client.reconfigure()
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
	udpDialer  UDPDialer

	memChecker      MemChecker
	configDir       string
	mtu             int
	capturedDNSHost string
	realDNSHost     string
	uc              common.UserConfig
	tcpHandler      *proxiedTCPHandler
	udpHandler      *directUDPHandler

	clientWriter     *cw
	memoryAvailable  int64
	started          time.Time
	bandwidthTracker BandwidthTracker
	statsTracker     StatsTracker
	dialer           dialer.Dialer
	tracker          stats.Tracker
}

func Client(packetsOut Writer, udpDialer UDPDialer, memChecker MemChecker, configDir string, mtu int,
	capturedDNSHost, realDNSHost string, bandwidthTracker BandwidthTracker, statsTracker StatsTracker) (ClientWriter, error) {
	log.Debug("Creating new iOS client")
	if mtu <= 0 {
		log.Debug("Defaulting MTU to 1500")
		mtu = 1500
	}

	c := &iosClient{
		packetsOut: newWriterAdapter(packetsOut),
		memChecker: memChecker,
		configDir:  configDir,
		//ipp:             ipp,
		mtu:              mtu,
		udpDialer:        udpDialer,
		capturedDNSHost:  capturedDNSHost,
		realDNSHost:      realDNSHost,
		started:          time.Now(),
		bandwidthTracker: bandwidthTracker,
		statsTracker:     statsTracker,
		dialer:           dialer.NewProxylessDialer(),
		tracker:          stats.NewTracker(),
	}
	optimizeMemoryUsage(&c.memoryAvailable)
	go c.gcPeriodically()
	go c.logMemory()

	return c.start()
}

func (c *iosClient) start() (ClientWriter, error) {
	if err := c.loadUserConfig(); err != nil {
		return nil, log.Errorf("error loading user config: %v", err)
	}
	log.Debugf("Running client at config path '%v'", c.configDir)
	start := time.Now()
	log.Debugf("User config process start at %v", start)
	dialers, err := c.loadDialers()
	if err != nil {
		return nil, err
	}
	if len(dialers) == 0 {
		return nil, errors.New("No dialers found")
	}
	c.onDialers(dialers)

	// get stats updates
	go c.statsTrackerUpdates()
	// get bandwidth updates
	go bandwidthUpdates(c.bandwidthTracker)

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

	c.tcpHandler = newProxiedTCPHandler(c, c.dialer, grabber)
	c.udpHandler = newDirectUDPHandler(c, c.udpDialer, grabber, c.capturedDNSHost)

	ipStack := tun2socks.NewLWIPStack()
	tun2socks.RegisterOutputFn(c.packetsOut.Write)
	tun2socks.RegisterTCPConnHandler(c.tcpHandler)
	tun2socks.RegisterUDPConnHandler(c.udpHandler)

	freeMemory()

	c.clientWriter = &cw{
		ipStack:       ipStack,
		client:        c,
		quotaTextPath: filepath.Join(c.configDir, "quota.txt"),
	}

	return c.clientWriter, nil
}

func (c *iosClient) reconfigure() {
	dialers, err := c.loadDialers()
	if err != nil {
		// this causes the NetworkExtension process to die. Since the VPN is configured as "on-demand",
		// the OS will automatically restart the service, at which point we'll read the new config anyway.
		panic(log.Errorf("Unable to load dialers on reconfigure: %v", err))
	}
	c.onDialers(dialers)
}

func (c *iosClient) onDialers(dialers []dialer.ProxyDialer) {
	c.dialer.OnOptions(&dialer.Options{
		Dialers: dialers,
		OnSuccess: func(pd dialer.ProxyDialer) {
			c.tracker.SetHasSucceedingProxy(true)
			countryCode, country, city := pd.Location()
			previousStats := c.tracker.Latest()
			if previousStats.CountryCode == "" || previousStats.CountryCode != countryCode {
				c.tracker.SetActiveProxyLocation(
					city,
					country,
					countryCode,
				)
			}
		},
	})
}

func bandwidthUpdates(bt BandwidthTracker) {
	go func() {

		quota, _ := bandwidth.GetQuota()
		if quota == nil {
			// quota is nil, so then we are uncapped
			bt.BandwidthUpdate("", 0, 0, 0, 0)
			return
		}

		for quota := range bandwidth.Updates {
			percent, remaining, allowed := getBandwidth(quota)
			bt.BandwidthUpdate("", percent, remaining, allowed, int(quota.TTLSeconds))
		}
	}()
}
func (c *iosClient) statsTrackerUpdates() {
	c.tracker.AddListener(func(st stats.Stats) {
		if st.City != "" && st.Country != "" && st.CountryCode != "" {
			log.Debug("updating stats")
			c.statsTracker.UpdateStats(st.City, st.Country, st.CountryCode, st.HTTPSUpgrades, st.AdsBlocked, st.HasSucceedingProxy)
		}
	})
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

func (c *iosClient) loadUserConfig() error {
	cf := &configurer{configFolderPath: c.configDir}
	uc, err := cf.readUserConfig()
	if err != nil {
		return err
	}
	c.uc = uc
	return nil
}

func (c *iosClient) loadDialers() ([]dialer.ProxyDialer, error) {
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

func userConfigFor(userID int, proToken, deviceID string) *UserConfig {
	// TODO: plug in implementation of fetching timezone for iOS to work around https://github.com/golang/go/issues/20455
	return &UserConfig{
		UserConfigData: *common.NewUserConfig(
			"Lantern",
			deviceID,
			int64(userID),
			proToken,
			nil, // Headers currently unused
			"",  // Language currently unused
		),
	}
}
