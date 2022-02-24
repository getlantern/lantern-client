package internalsdk

import (
	"context"
	"io"
	"os"
	"runtime"
	"sync"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/chained"

	tun2socks "github.com/eycorsican/go-tun2socks/core"
)

var (
	currentIPStackMx sync.Mutex
	currentIPStack   tun2socks.LWIPStack
)

// Tun2Socks wraps the TUN device identified by fd and does the following:
//
// 1. captured dns packets (any UDP packets to port 53) are routed to dnsGrabAddr
// 2. All other udp packets are routed directly to their destination
// 3. All TCP traffic is routed tgit sthrough Lantern.
//
// Despite the name, this doesn't use Lantern's SOCKS proxy, traffic enters the proxying
// layer directly.
//
// This function blocks until StopTun2Socks() is called. It also locks itself to
// the current OS thread so that the thread stays alive as long as Tun2Socks is running.
func Tun2Socks(fd int, dnsGrabAddr string, mtu int) error {
	runtime.LockOSThread()

	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Minute)
	defer cancel()
	dg := getDNSGrab(ctx)
	if dg == nil {
		return errors.New("unable to find dns grabber")
	}
	log.Debugf("Directing TUN traffic to Lantern with mtu %d", mtu)
	dev := os.NewFile(uintptr(fd), "tun")
	defer dev.Close()

	ipStack := tun2socks.NewLWIPStack()
	udpHandler, err := newDirectUDPHandler(dg, dnsGrabAddr, chained.IdleTimeout)
	if err != nil {
		return err
	}
	var writeMx sync.Mutex
	tun2socks.RegisterOutputFn(func(b []byte) (int, error) {
		// It's unclear why it's necessary to single-thread writes to the TUN device, but without this,
		// user agents will periodically hang.
		writeMx.Lock()
		defer writeMx.Unlock()
		return dev.Write(b)
	})
	tun2socks.RegisterTCPConnHandler(newDirectTCPHandler(mtu))
	tun2socks.RegisterUDPConnHandler(udpHandler)

	currentIPStackMx.Lock()
	danglingIPStack := currentIPStack
	currentIPStack = ipStack
	currentIPStackMx.Unlock()

	if danglingIPStack != nil {
		go func() {
			log.Debug("Closing dangling ip stack")
			if err := danglingIPStack.Close(); err != nil {
				log.Errorf("error closing dangling ip stack: %v", err)
			}
		}()
	}
	_, err = io.CopyBuffer(ipStack, dev, make([]byte, mtu))
	return err
}

// StopTun2Socks stops the current tun device.
func StopTun2Socks() {
	defer func() {
		p := recover()
		if p != nil {
			log.Errorf("panic while stopping: %v", p)
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
				log.Errorf("error closing ipStack: %v", err)
			}
			log.Debug("Closed ipStack")
		}()
	}
}
