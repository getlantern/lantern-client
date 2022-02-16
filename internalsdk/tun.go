package internalsdk

import (
	"io"
	"os"
	"runtime"
	"sync"
	"time"

	"github.com/getlantern/dnsgrab"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/chained"

	tun2socks "github.com/eycorsican/go-tun2socks/core"
)

var (
	currentIPStackMx sync.Mutex
	currentIPStack   tun2socks.LWIPStack
)

// Tun2Socks wraps the TUN device identified by fd with tun2socks proxy that
// does the following:
//
// 1. captured dns packets (any UDP packets to capturedDNSAddr) are routed to dnsGrabAddr
// 2. All other udp packets are routed directly to their destination
// 3. All TCP traffic is routed through the Lantern proxy at the given socksAddr.
//
func Tun2Socks(fd int, socksAddr, dnsGrabAddr string, mtu int) error {
	runtime.LockOSThread()

	grabber, found := dnsGrabEventual.Get(1 * time.Minute)
	if !found {
		return errors.New("Unable to find dns grabber")
	}
	log.Debugf("Starting tun2socks connecting to socks at %v", socksAddr)
	dev := os.NewFile(uintptr(fd), "tun")
	defer dev.Close()

	ipStack := tun2socks.NewLWIPStack()
	udpHandler, err := newDirectUDPHandler(grabber.(dnsgrab.Server), dnsGrabAddr, chained.IdleTimeout)
	if err != nil {
		return err
	}
	tun2socks.RegisterOutputFn(dev.Write)
	tun2socks.RegisterTCPConnHandler(newSOCKSTCPHandler(socksAddr))
	tun2socks.RegisterUDPConnHandler(udpHandler)

	currentIPStackMx.Lock()
	currentIPStack = ipStack
	currentIPStackMx.Unlock()

	_, err = io.CopyBuffer(ipStack, dev, make([]byte, mtu))
	return err
}

// StopTun2Socks stops the current tun device.
func StopTun2Socks() {
	defer func() {
		p := recover()
		if p != nil {
			log.Errorf("Panic while stopping: %v", p)
		}
	}()

	currentIPStackMx.Lock()
	ipStack := currentIPStack
	currentIPStack = nil
	currentIPStackMx.Unlock()
	if ipStack != nil {
		go func() {
			log.Debug("Closing ipStack")
			if err := ipStack.Close(); err != nil {
				log.Errorf("Error closing ipStack: %v", err)
			}
			log.Debug("Closed ipStack")
		}()
	}
}
