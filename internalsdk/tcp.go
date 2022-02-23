package internalsdk

import (
	"net"
	"sync"

	"golang.org/x/net/proxy"

	"github.com/eycorsican/go-tun2socks/core"
	"github.com/getlantern/errors"
	"github.com/getlantern/netx"
)

// Loosely based on https://github.com/eycorsican/go-tun2socks/blob/master/proxy/socks/udp.go
type socksTCPHandler struct {
	sync.Mutex

	proxyAddr string
	mtu       int
}

func newSOCKSTCPHandler(proxyAddr string, mtu int) core.TCPConnHandler {
	log.Debugf("Creating new Socks TCP Handler using proxy at %v", proxyAddr)
	return &socksTCPHandler{
		proxyAddr: proxyAddr,
		mtu:       mtu,
	}
}

func (h *socksTCPHandler) Handle(downstream net.Conn, target *net.TCPAddr) error {
	dialer, err := proxy.SOCKS5("tcp", h.proxyAddr, nil, nil)
	if err != nil {
		return errors.New("unable to connect to SOCKS proxy at %v: %v", h.proxyAddr, err)
	}

	upstream, err := dialer.Dial(target.Network(), target.String())
	if err != nil {
		return errors.New("unable to dial upstream %v via SOCKS proxy at %v: %v", target, h.proxyAddr, err)
	}

	bufOut := make([]byte, h.mtu)
	bufIn := make([]byte, h.mtu)

	go netx.BidiCopy(upstream, downstream, bufOut, bufIn)

	return nil
}
