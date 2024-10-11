package internalsdk

import (
	"context"
	"fmt"
	"io"
	"net"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/idletiming"
	"github.com/getlantern/ipproxy"
	"github.com/getlantern/netx"

	"golang.org/x/net/proxy"
)

var (
	currentDeviceMx sync.Mutex
	// currentDevice   io.ReadWriteCloser
	currentIPP ipproxy.Proxy
)

// Tun2Socks wraps the TUN device identified by fd with an ipproxy server that
// does the following:
//
// 1. dns packets (any UDP packets to port 53) are routed to dnsGrabAddr
// 2. All other udp packets are routed directly to their destination
// 3. All TCP traffic is routed through the Lantern proxy at the given socksAddr.
func Tun2Socks(fd int, socksAddr, dnsGrabAddr string, mtu int, wrappedSession Session) error {
	runtime.LockOSThread()
	defer logPanicAndRecover()
	// perform geo lookup after establishing the VPN connection, prior to running tun2socks
	go geoLookup(&panickingSessionImpl{wrappedSession})

	log.Debugf("Starting tun2socks connecting to socks at %v", socksAddr)
	socksDialer, err := proxy.SOCKS5("tcp", socksAddr, nil, nil)
	if err != nil {
		return errors.New("Unable to get SOCKS5 dialer: %v", err)
	}

	ipp := ipproxy.New(&ipproxy.Opts{
		DeviceName:          fmt.Sprintf("fd://%d", fd),
		IdleTimeout:         70 * time.Second,
		StatsInterval:       15 * time.Second,
		DisableIPv6:         true,
		MTU:                 mtu,
		OutboundBufferDepth: 10000,
		TCPConnectBacklog:   100,
		DialTCP: func(ctx context.Context, network, addr string) (net.Conn, error) {
			if strings.HasSuffix(addr, ":853") {
				// This is usually DNS over TLS, we blackhole this to force DNS through dnsgrab.
				return nil, errors.New("blackholing DNS over TLS traffic to %v", addr)
			}
			return socksDialer.Dial(network, addr)
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
	})

	currentDeviceMx.Lock()
	currentIPP = ipp
	currentDeviceMx.Unlock()

	ctx := context.Background()

	err = ipp.Start(ctx)
	if err != io.EOF {
		return log.Errorf("unexpected error serving TUN traffic: %v", err)
	}
	return nil
}

// StopTun2Socks stops the current tun device.
func StopTun2Socks() {
	defer logPanicAndRecover()

	currentDeviceMx.Lock()
	ipp := currentIPP

	currentIPP = nil
	currentDeviceMx.Unlock()
	if ipp != nil {
		go func() {
			log.Debug("Closing ipproxy")
			if err := ipp.Stop(); err != nil {
				log.Errorf("Error closing ipproxy: %v", err)
			}
			log.Debug("Closed ipproxy")
		}()
	}
}
