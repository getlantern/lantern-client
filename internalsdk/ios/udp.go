package ios

import (
	"net"
	"sync"
	"sync/atomic"
	"time"

	"github.com/eycorsican/go-tun2socks/core"

	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/flashlight/v7/chained"
)

// UDPDialer provides a mechanism for dialing outbound UDP connections that bypass the VPN.
// The returned UDPConn is not immediately ready for use, only once the UDPCallbacks receive
// OnDialSuccess is the UDPConn ready for use.
type UDPDialer interface {
	Dial(host string, port int) UDPConn
}

// UDPConn is a UDP connection that bypasses the VPN. It is backed by an NWConnection on the
// Swift side.
//
// See https://developer.apple.com/documentation/network/nwconnection.
type UDPConn interface {
	// RegisterCallbacks registers lifecycle callbacks for the connection. Clients of the UDPConn
	// must call this before trying to use WriteDatagram and ReceiveDatagram.
	RegisterCallbacks(cb *UDPCallbacks)

	// WriteDatagram writes one datagram to the UDPConn. Any resulting error from the right will
	// be reported to UDPCallbacks.OnError.
	WriteDatagram([]byte)

	// ReceiveDatagram requests receipt of the next datagram from the UDPConn. Once the datagram is received,
	// it's sent to UDPCallbacks.OnReceive.
	ReceiveDatagram()

	// Close closes the UDPConn
	Close()
}

type UDPCallbacks struct {
	h             *directUDPHandler
	downstream    core.UDPConn
	upstream      UDPConn
	target        *net.UDPAddr
	dialSucceeded chan interface{}
	dialFailed    chan interface{}
	received      chan interface{}
	wrote         chan interface{}
}

// OnConn is called once a connection is successfully dialed
func (cb *UDPCallbacks) OnDialSucceeded() {
	close(cb.dialSucceeded)
}

func (cb *UDPCallbacks) OnError(err error) {
	log.Errorf("Error communicating with %v: %v", cb.target, err)
}

// OnClose is called when the connection is closed.
func (cb *UDPCallbacks) OnClose() {
	cb.h.Lock()
	delete(cb.h.upstreams, cb.downstream)
	cb.h.Unlock()
	cb.downstream.Close()
}

func (cb *UDPCallbacks) OnReceive(dgram []byte) {
	// Request receive of next datagram
	cb.upstream.ReceiveDatagram()

	// Forward datagram downstream
	_, writeErr := cb.downstream.WriteFrom(dgram, cb.target)
	if writeErr != nil {
		log.Errorf("Unable to write UDP packet downstream: %v", writeErr)
		cb.upstream.Close()
	}

	cb.received <- nil
}

func (cb *UDPCallbacks) OnWritten() {
	cb.wrote <- nil
}

func (cb *UDPCallbacks) idleTiming() {
	t := time.NewTimer(chained.IdleTimeout)
	resetTimer := func() {
		if !t.Stop() {
			<-t.C
		}
		next := time.Duration(chained.IdleTimeout)
		t.Reset(next)
	}

	for {
		select {
		case <-cb.received:
			resetTimer()
		case <-cb.wrote:
			resetTimer()
		case <-t.C:
			log.Debugf("Timing out idle connection to %v", cb.target)
			cb.upstream.Close() // we don't close downstream because that'll happen automatically once upstream finishes closing
			return
		}
	}
}

// directUDPHandler implements UDPConnHandler from go-tun2socks by sending UDP traffic directly to
// the origin. It is loosely based on https://github.com/eycorsican/go-tun2socks/blob/master/proxy/socks/udp.go
type directUDPHandler struct {
	sync.RWMutex

	client          *iosClient
	dialer          UDPDialer
	grabber         dnsgrab.Server
	capturedDNSHost string

	downstreamWriteWorker *worker
	upstreams             map[core.UDPConn]UDPConn
	dialingConns          int64
}

func newDirectUDPHandler(client *iosClient, dialer UDPDialer, grabber dnsgrab.Server, capturedDNSHost string) *directUDPHandler {
	result := &directUDPHandler{
		client:                client,
		dialer:                dialer,
		capturedDNSHost:       capturedDNSHost,
		grabber:               grabber,
		downstreamWriteWorker: newWorker(100),
		upstreams:             make(map[core.UDPConn]UDPConn),
	}
	go result.trackStats()
	return result
}

func (h *directUDPHandler) Connect(downstream core.UDPConn, target *net.UDPAddr) error {
	if target.IP.String() == h.capturedDNSHost && target.Port == 53 {
		// Captured dns, handle internally with dnsgrab
		return nil
	}

	// Since UDP traffic is sent directly, do a reverse lookup of the IP and then resolve the UDP address
	host, found := h.grabber.ReverseLookup(target.IP)
	if !found {
		return log.Errorf("Unknown IP %v, not connecting", target.IP)
	}
	if found {
		ip, err := net.ResolveIPAddr("ip", host)
		if err != nil {
			return log.Errorf("Unable to resolve IP address for %v, not connecting: %v", host, err)
		}
		target.IP = ip.IP
	}

	// Dial
	atomic.AddInt64(&h.dialingConns, 1)
	defer atomic.AddInt64(&h.dialingConns, -1)

	// note - the below convoluted flow is necessary because of limitations in what kind
	// of APIs can be bound to Swift using gomobile.
	upstream := h.dialer.Dial(target.IP.String(), target.Port)

	cb := &UDPCallbacks{
		h: h,
		// MEMORY_OPTIMIZATION - use a threadLimitingUDPConn to limit the number of goroutines that are writing to LWIP
		downstream:    newThreadLimitingUDPConn(downstream, h.downstreamWriteWorker),
		upstream:      upstream,
		target:        target,
		dialSucceeded: make(chan interface{}),
		dialFailed:    make(chan interface{}),
		received:      make(chan interface{}, 10),
		wrote:         make(chan interface{}, 10),
	}

	upstream.RegisterCallbacks(cb)

	select {
	case <-cb.dialFailed:
		return log.Errorf("Failed to dial %v", target)
	case <-cb.dialSucceeded:
		h.Lock()
		h.upstreams[downstream] = upstream
		h.Unlock()

		// Request to receive first datagram
		upstream.ReceiveDatagram()
	case <-time.After(dialTimeout):
		upstream.Close()
		return log.Errorf("Timed out dialing %v", target)
	}

	go cb.idleTiming()

	return nil
}

func (h *directUDPHandler) ReceiveTo(downstream core.UDPConn, data []byte, addr *net.UDPAddr) error {
	h.RLock()
	upstream := h.upstreams[downstream]
	h.RUnlock()

	if upstream == nil {
		// if there's no upstream, that means this is a DNS query
		return h.receiveDNS(downstream, data, addr)
	}

	upstream.WriteDatagram(data)
	return nil
}

func (h *directUDPHandler) receiveDNS(downstream core.UDPConn, data []byte, addr *net.UDPAddr) error {
	response, numAnswers, err := h.grabber.ProcessQuery(data)
	if err != nil {
		return log.Errorf("Unable to process dns query: %v", err)
	}

	if numAnswers == 0 {
		// nothing to write
		return nil
	}

	// MEMORY_OPTIMIZATION - use a threadLimitingUDPConn to limit the number of goroutines that are writing to LWIP
	_, writeErr := newThreadLimitingUDPConn(downstream, h.downstreamWriteWorker).WriteFrom(response, addr)
	return writeErr
}

func (h *directUDPHandler) trackStats() {
	for {
		h.RLock()
		activeConns := len(h.upstreams)
		h.RUnlock()

		statsLog.Debugf("UDP Conns    Active: %d    Dialing: %d", activeConns, atomic.LoadInt64(&h.dialingConns))
		time.Sleep(1 * time.Second)
	}
}
