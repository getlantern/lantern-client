package internalsdk

import (
	"io"
	"net"
	"sync"

	"golang.org/x/net/proxy"

	"github.com/eycorsican/go-tun2socks/core"
)

// Copied and lightly modified from https://github.com/eycorsican/go-tun2socks/blob/master/proxy/socks/udp.go
type socksTCPHandler struct {
	sync.Mutex

	proxyAddr string
}

func newSOCKSTCPHandler(proxyAddr string) core.TCPConnHandler {
	log.Debugf("Creating new Socks TCP Handler using proxy at %v", proxyAddr)
	return &socksTCPHandler{
		proxyAddr: proxyAddr,
	}
}

type direction byte

const (
	dirUplink direction = iota
	dirDownlink
)

type duplexConn interface {
	net.Conn
	CloseRead() error
	CloseWrite() error
}

func (h *socksTCPHandler) relay(lhs, rhs net.Conn) {
	upCh := make(chan struct{})

	cls := func(dir direction, interrupt bool) {
		lhsDConn, lhsOk := lhs.(duplexConn)
		rhsDConn, rhsOk := rhs.(duplexConn)
		if !interrupt && lhsOk && rhsOk {
			switch dir {
			case dirUplink:
				lhsDConn.CloseRead()
				rhsDConn.CloseWrite()
			case dirDownlink:
				lhsDConn.CloseWrite()
				rhsDConn.CloseRead()
			default:
				panic("unexpected direction")
			}
		} else {
			lhs.Close()
			rhs.Close()
		}
	}

	// Uplink
	go func() {
		var err error
		_, err = io.Copy(rhs, lhs)
		if err != nil {
			cls(dirUplink, true) // interrupt the conn if the error is not nil (not EOF)
		} else {
			cls(dirUplink, false) // half close uplink direction of the TCP conn if possible
		}
		upCh <- struct{}{}
	}()

	// Downlink
	var err error
	_, err = io.Copy(lhs, rhs)
	if err != nil {
		cls(dirDownlink, true)
	} else {
		cls(dirDownlink, false)
	}

	<-upCh // Wait for uplink done.
}

func (h *socksTCPHandler) Handle(conn net.Conn, target *net.TCPAddr) error {
	dialer, err := proxy.SOCKS5("tcp", h.proxyAddr, nil, nil)
	if err != nil {
		return err
	}

	c, err := dialer.Dial(target.Network(), target.String())
	if err != nil {
		return err
	}

	go h.relay(conn, c)

	return nil
}
