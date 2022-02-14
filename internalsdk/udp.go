package internalsdk

import (
	"errors"
	"fmt"
	"net"
	"sync"
	"time"

	"github.com/eycorsican/go-tun2socks/core"
	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/netx"
)

// directdirectUDPHandler implements UDPConnHandler from go-tun2socks by sending UDP traffic directly to
// the origin. It is loosely based on https://github.com/eycorsican/go-tun2socks/blob/master/proxy/socks/udp.go
type directUDPHandler struct {
	sync.Mutex

	timeout        time.Duration
	udpConns       map[core.UDPConn]*net.UDPConn
	udpTargetAddrs map[core.UDPConn]*net.UDPAddr
	grabber        dnsgrab.Server
	dnsGrabAddr    string
	dnsGrabUDPAddr *net.UDPAddr
}

func newDirectUDPHandler(grabber dnsgrab.Server, dnsGrabAddr string, timeout time.Duration) (core.UDPConnHandler, error) {
	dnsGrabUDPAddr, err := netx.ResolveUDPAddr("udp", dnsGrabAddr)
	if err != nil {
		return nil, log.Errorf("Unable to resolve dnsGrabAddr")
	}

	return &directUDPHandler{
		timeout:        timeout,
		udpConns:       make(map[core.UDPConn]*net.UDPConn, 8),
		udpTargetAddrs: make(map[core.UDPConn]*net.UDPAddr, 8),
		grabber:        grabber,
		dnsGrabAddr:    dnsGrabAddr,
		dnsGrabUDPAddr: dnsGrabUDPAddr,
	}, nil
}

func (h *directUDPHandler) fetchUDPInput(conn core.UDPConn, pc *net.UDPConn) {
	buf := core.NewBytes(core.BufSize)

	defer func() {
		h.Close(conn)
		core.FreeBytes(buf)
	}()

	for {
		pc.SetDeadline(time.Now().Add(h.timeout))
		n, addr, err := pc.ReadFromUDP(buf)
		if err != nil {
			return
		}

		_, err = conn.WriteFrom(buf[:n], addr)
		if err != nil {
			log.Debugf("failed to write UDP data to TUN")
			return
		}
	}
}

func (h *directUDPHandler) Connect(conn core.UDPConn, target *net.UDPAddr) error {
	if target.Port == 53 {
		if target.String() != h.dnsGrabAddr {
			// reroute all DNS traffic to dnsgrab
			target = h.dnsGrabUDPAddr
		}
	}

	host, found := h.grabber.ReverseLookup(target.IP)
	if !found {
		return log.Errorf("Unknown IP %v, not connecting", target.IP)
	}
	if found {
		resolvedAddr, err := netx.ResolveUDPAddr(target.Network(), fmt.Sprintf("%v:%d", host, target.Port))
		if err != nil {
			return log.Errorf("Unable to resolve address for %v, not connecting: %v", host, err)
		}
		target = resolvedAddr
	}

	bindAddr := &net.UDPAddr{IP: nil, Port: 0}
	pc, err := netx.ListenUDP("udp", bindAddr)
	if err != nil {
		log.Errorf("failed to bind udp address")
		return err
	}
	h.Lock()
	h.udpTargetAddrs[conn] = target
	h.udpConns[conn] = pc
	h.Unlock()
	go h.fetchUDPInput(conn, pc)
	log.Debugf("new proxy connection for target: %s:%s", target.Network(), target.String())
	return nil
}

func (h *directUDPHandler) ReceiveTo(conn core.UDPConn, data []byte, addr *net.UDPAddr) error {
	h.Lock()
	pc, ok1 := h.udpConns[conn]
	tgtAddr, ok2 := h.udpTargetAddrs[conn]
	h.Unlock()

	if ok1 && ok2 {
		_, err := pc.WriteToUDP(data, tgtAddr)
		if err != nil {
			log.Debugf("failed to write UDP payload to SOCKS5 server: %v", err)
			return errors.New("failed to write UDP data")
		}
		return nil
	} else {
		return log.Errorf("proxy connection %v->%v does not exists", conn.LocalAddr(), addr)
	}
}

func (h *directUDPHandler) Close(conn core.UDPConn) {
	conn.Close()

	h.Lock()
	defer h.Unlock()

	delete(h.udpTargetAddrs, conn)
	if pc, ok := h.udpConns[conn]; ok {
		pc.Close()
		delete(h.udpConns, conn)
	}
}
