package internalsdk

import (
	"fmt"
	"net"
	"strings"
	"sync"
	"time"

	"github.com/eycorsican/go-tun2socks/core"

	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/errors"
	"github.com/getlantern/netx"
)

// directUDPHandler implements UDPConnHandler from go-tun2socks by sending UDP traffic directly to
// the origin. It is loosely based on https://github.com/eycorsican/go-tun2socks/blob/master/proxy/socks/udp.go
type directUDPHandler struct {
	sync.Mutex

	timeout        time.Duration
	udpConns       map[core.UDPConn]*net.UDPConn
	udpTargetAddrs map[core.UDPConn]*net.UDPAddr
	grabber        dnsgrab.Server
	dnsGrabUDPAddr *net.UDPAddr
}

func newDirectUDPHandler(grabber dnsgrab.Server, dnsGrabAddr string, timeout time.Duration) (core.UDPConnHandler, error) {
	dnsGrabUDPAddr, err := netx.ResolveUDPAddr("udp", dnsGrabAddr)
	if err != nil {
		return nil, log.Errorf("unable to resolve dnsGrabAddr")
	}

	return &directUDPHandler{
		timeout:        timeout,
		udpConns:       make(map[core.UDPConn]*net.UDPConn),
		udpTargetAddrs: make(map[core.UDPConn]*net.UDPAddr),
		grabber:        grabber,
		dnsGrabUDPAddr: dnsGrabUDPAddr,
	}, nil
}

func (h *directUDPHandler) fetchUDPInput(conn core.UDPConn, pc *net.UDPConn, target *net.UDPAddr) {
	buf := core.NewBytes(core.BufSize)

	defer func() {
		h.Close(conn)
		core.FreeBytes(buf)
	}()

	for {
		pc.SetDeadline(time.Now().Add(h.timeout))
		n, _, err := pc.ReadFromUDP(buf)
		if err != nil {
			return
		}

		_, err = conn.WriteFrom(buf[:n], target)
		if err != nil {
			log.Debugf("failed to write UDP data to TUN")
			return
		}
	}
}

func (h *directUDPHandler) ReceiveTo(conn core.UDPConn, data []byte, addr *net.UDPAddr) error {
	h.Lock()
	pc, ok1 := h.udpConns[conn]
	tgtAddr, ok2 := h.udpTargetAddrs[conn]
	h.Unlock()

	if ok1 && ok2 {
		_, err := pc.WriteToUDP(data, tgtAddr)
		if err != nil {
			return log.Errorf("failed to write UDP payload to target: %v", err)
		}
		return nil
	} else {
		// This can happen, especially with QUIC traffic, don't bother logging it
		return errors.New("proxy connection %v->%v does not exists", conn.LocalAddr(), addr)
	}
}

func (h *directUDPHandler) Connect(conn core.UDPConn, target *net.UDPAddr) error {
	var originalTarget = target
	targetAddr := target.String()
	if strings.HasSuffix(targetAddr, ":53") {
		// reroute all DNS traffic to dnsgrab
		log.Tracef("Rerouting DNS traffic bound for %v to %v", target, h.dnsGrabUDPAddr)
		target = h.dnsGrabUDPAddr
	} else if strings.HasSuffix(targetAddr, ":853") {
		// This is usually DNS over DTLS, we blackhole this to force DNS through dnsgrab.
		return errors.New("blackholing DNS over TLS traffic to %v", targetAddr)
	} else if strings.HasSuffix(targetAddr, ":443") {
		// This is likely QUIC traffic. This should really be proxied, but since we don't proxy UDP,
		// we blackhole this traffic.
		return errors.New("blackholing QUIC UDP traffic to %v", targetAddr)
	}

	host, found := h.grabber.ReverseLookup(target.IP)
	if !found {
		return log.Errorf("unknown IP %v, not connecting", target.IP)
	}
	resolvedAddr, err := netx.ResolveUDPAddr(target.Network(), fmt.Sprintf("%v:%d", host, target.Port))
	if err != nil {
		return log.Errorf("unable to resolve address for %v, not connecting: %v", host, err)
	}
	target = resolvedAddr

	bindAddr := &net.UDPAddr{IP: nil, Port: 0}
	isIPv6 := target.IP.To4() == nil
	protocol := "udp4"
	if isIPv6 {
		protocol = "udp6"
	}
	pc, err := netx.ListenUDP(protocol, bindAddr)
	if err != nil {
		log.Errorf("failed to bind udp address")
		return err
	}
	h.Lock()
	h.udpTargetAddrs[conn] = target
	h.udpConns[conn] = pc
	numConns := len(h.udpConns)
	h.Unlock()
	log.Debugf("%d conns", numConns)
	go h.fetchUDPInput(conn, pc, originalTarget)
	return nil
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
