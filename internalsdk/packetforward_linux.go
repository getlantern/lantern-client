package internalsdk

import (
	"context"
	"io"
	"net"
	"os"
	"runtime"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/packetforward"
)

// Tun2PacketForward wraps the TUN device identified by fd with packet forwarding.
func Tun2PacketForward(fd int, mtu int) error {
	runtime.LockOSThread()

	log.Debugf("Starting tun2packetforward")
	dev := os.NewFile(uintptr(fd), "tun")
	defer dev.Close()

	bal := GetBalancer(30 * time.Second)
	if bal == nil {
		return errors.New("Unable to get balancer within 30 seconds")
	}

	w := packetforward.Client(dev, 30*time.Second, func(ctx context.Context) (net.Conn, error) {
		return bal.DialContext(ctx, "connect", "127.0.0.1:3000")
	})

	currentDeviceMx.Lock()
	currentDevice = dev
	currentDeviceMx.Unlock()

	for {
		b := make([]byte, mtu)
		n, readErr := dev.Read(b)
		if n > 0 {
			_, writeErr := w.Write(b[:n])
			if writeErr != nil {
				return log.Errorf("unexpected error writing to packetforward: %v", writeErr)
			}
		}
		if readErr != nil {
			if readErr == io.EOF {
				return nil
			}
			return log.Errorf("unexpected error reading from TUN device: %v", readErr)
		}
	}
}

// StopTun2PacketForward stops the current tun device.
func StopTun2PacketForward() {
	currentDeviceMx.Lock()
	dev := currentDevice
	currentDevice = nil
	currentDeviceMx.Unlock()
	if dev != nil {
		log.Debug("Closing TUN device")
		if err := dev.Close(); err != nil {
			log.Errorf("Error closing TUN device: %v", err)
		}
		log.Debug("Closed TUN device")
	}
}
