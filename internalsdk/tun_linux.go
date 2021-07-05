package internalsdk

import (
	"context"
	"io"
	"net"
	"os"
	"runtime"
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
	currentDevice   io.ReadWriteCloser
	currentIPP      ipproxy.Proxy
)

// Tun2Socks wraps the TUN device identified by fd with an ipproxy server that
// does the following:
//
// 1. dns packets bound for dnsAddr are rerouted to dnsgrab at dnsGrabAddr
// 2. All other udp packets are routed directly to their destination
// 3. All TCP traffic is routed through the Lantern proxy at the given socksAddr.
//
func Tun2Socks(fd int, socksAddr, dnsAddr, dnsGrabAddr string, mtu int) error {
	runtime.LockOSThread()

	log.Debugf("Starting tun2socks connecting to socks at %v with dns %v", socksAddr, dnsAddr)
	dev := os.NewFile(uintptr(fd), "tun")
	defer dev.Close()

	socksDialer, err := proxy.SOCKS5("tcp", socksAddr, nil, nil)
	if err != nil {
		return errors.New("Unable to get SOCKS5 dialer: %v", err)
	}

	ipp, err := ipproxy.New(dev, &ipproxy.Opts{
		IdleTimeout:         70 * time.Second,
		StatsInterval:       15 * time.Second,
		MTU:                 mtu,
		OutboundBufferDepth: 10000,
		TCPConnectBacklog:   100,
		DialTCP: func(ctx context.Context, network, addr string) (net.Conn, error) {
			return socksDialer.Dial(network, addr)
		},
		DialUDP: func(ctx context.Context, network, addr string) (net.Conn, error) {
			isDNS := addr == dnsAddr
			if isDNS {
				// reroute DNS requests to dnsgrab
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
	if err != nil {
		return errors.New("Unable to create ipproxy: %v", err)
	}

	currentDeviceMx.Lock()
	currentDevice = dev
	currentIPP = ipp
	currentDeviceMx.Unlock()

	err = ipp.Serve()
	if err != io.EOF {
		return err
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
	dev := currentDevice
	ipp := currentIPP
	currentDevice = nil
	currentIPP = nil
	currentDeviceMx.Unlock()
	if dev != nil {
		log.Debug("Closing TUN device")
		if err := dev.Close(); err != nil {
			log.Errorf("Error closing TUN device: %v", err)
		}
		log.Debug("Closed TUN device")
	}
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
