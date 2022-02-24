package internalsdk

import (
	"bufio"
	"context"
	"fmt"
	"net"
	"sync"
	"time"

	"github.com/eycorsican/go-tun2socks/core"
	"github.com/getlantern/errors"
)

type directTCPHandler struct {
	sync.Mutex

	mtu int
}

func newDirectTCPHandler(mtu int) core.TCPConnHandler {
	return &directTCPHandler{
		mtu: mtu,
	}
}

func (h *directTCPHandler) Handle(downstream net.Conn, target *net.TCPAddr) error {
	log.Tracef("New connection to %v", target)
	if target.Port == 853 {
		// This is usually DNS over TLS, we blackhole this to force DNS through dnsgrab.
		return errors.New("blackholing DNS over TLS traffic to %v", target)
	}

	deadline := time.Now().Add(60 * time.Second)
	ctx, cancel := context.WithDeadline(context.Background(), deadline)
	defer cancel()
	cl := getClient(ctx)
	if cl == nil {
		return log.Error("unable to obtain client by deadline")
	}
	dg := getDNSGrab(ctx)
	if dg == nil {
		return log.Error("unable to obtain dnsgrab server by deadline")
	}

	origin := target.String()
	originHost, found := dg.ReverseLookup(target.IP)
	if found {
		log.Tracef("Reverse resolved %v -> %v", target.IP, originHost)
		origin = fmt.Sprintf("%v:%d", originHost, target.Port)
	}

	go func() {
		dialCtx, cancelDialCtx := context.WithDeadline(context.Background(), deadline)
		defer cancelDialCtx()

		log.Tracef("Connecting to %v", origin)
		err := cl.Connect(dialCtx, bufio.NewReader(downstream), downstream, origin)
		if err != nil {
			log.Errorf("error processing traffic to %v: %v", origin, err)
		}
	}()

	return nil
}
