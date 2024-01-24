package internalsdk

import (
	"context"
	"io"
	"net"
	"os"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/ipproxy"

	"golang.org/x/net/proxy"
)

var (
	currentDeviceMx sync.Mutex
	currentDevice   io.ReadWriteCloser
	currentIPP      ipproxy.Proxy
)

// Tun2Socks wraps the TUN device identified by fd with an ipproxy server that
// does the following:
//
// 1. dns packets (any UDP packets to port 53) are routed to dnsGrabAddr
// 2. All other udp packets are routed directly to their destination
// 3. All TCP traffic is routed through the Lantern proxy at the given socksAddr.
//
func Tun2Socks(fd int, socksAddr, dnsGrabAddr string, mtu int, wrappedSession Session) error {
	runtime.LockOSThread()

	// perform geo lookup after establishing the VPN connection, prior to running tun2socks
	go geoLookup(&panickingSessionImpl{wrappedSession})

	log.Debugf("Starting tun2socks connecting to socks at %v", socksAddr)
	dev := os.NewFile(uintptr(fd), "tun")
	defer dev.Close()

	socksDialer, err := proxy.SOCKS5("tcp", socksAddr, nil, nil)
	if err != nil {
		return errors.New("Unable to get SOCKS5 dialer: %v", err)
	}

	ipp, err := ipproxy.New(dev, &ipproxy.Opts{
		DnsGrabAddress:      dnsGrabAddr,
		DnsGrabServer:       getDNSGrab(context.Background()),
		IdleTimeout:         70 * time.Second,
		StatsInterval:       15 * time.Second,
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
	})
	if err != nil {
		return errors.New("Unable to create ipproxy: %v", err)
	}

	currentDeviceMx.Lock()
	currentDevice = dev
	currentIPP = ipp
	currentDeviceMx.Unlock()

	err = ipp.Serve()
	if err != io.EOF {
		return log.Errorf("unexpected error serving TUN traffic: %v", err)
	}
	return nil
}

// StopTun2Socks stops the current tun device.
func StopTun2Socks() {
	defer func() {
		p := recover()
		if p != nil {
			log.Errorf("Panic while stopping: %v", p)
		}
	}()

	currentDeviceMx.Lock()
	ipp := currentIPP
	currentDevice = nil
	currentIPP = nil
	currentDeviceMx.Unlock()
	if ipp != nil {
		go func() {
			log.Debug("Closing ipproxy")
			if err := ipp.Close(); err != nil {
				log.Errorf("Error closing ipproxy: %v", err)
			}
			log.Debug("Closed ipproxy")
		}()
	}
}
