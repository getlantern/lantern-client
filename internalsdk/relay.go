package internalsdk

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"time"

	"nhooyr.io/websocket"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/client"
)

const (
	relayServer = "wss://relay.lantern.io"
)

// relay.go contains logic for relaying TCP connections between a client and peer,
// similar to what is done by TURN  (RFC 5766). For privacy and blocking resistance,
// we currently relay all traffic via proxies. Our proxies don't currently support UDP
// and unfortunately, libwebrtc (which we use in the UI) doesn't support TCP connections
// (RFC 6062). Furthermore, current Go-based TURN clients don't support TCP either, so
// using TURN would require updating our client and proxies to support UDP over TCP.

// Since WebRTC does support TCP for local connections, what we do is use the TCP ICE candidate
// at 127.0.0.1 and relay traffic to that using our custom relay mechanism. It works like this.

// 1. When call initiator gets a local TCP ICE candidate at 127.0.0.1, it calls AllocateRelayAddress
//    with that local address.
// 2. AllocateRelayAddress opens a websocket to relay.lantern.io to request an allocation,
//    receiving an address like `wss://relay.lantern.io/relay?id=<allocation id>`.
// 3. The call initiator modifies its local ICE candidate, replacing 127.0.0.1 with the relay address
//    and sends the ICE candidate to the peer via signaling
// 4. Upon receiving this ICE candidate, the peer calls RelayTo with the relay address
// 5. RelayTo opens a TCP listener on 127.0.0.1 which accepts one connection and starts relaying via
//    the relay address once it receives that connection. It returns this local address.
// 6. The peer modifies the address in its ICE candidate to point to the local address and then
//    registers that ICE candidate with WebRTC

// At this point, the initiating client and peer's WebRTC layers both think that they're successfully
// connecting via localhost addresses, which under the covers are in fact relaying via relay.lantern.io,
// connected via proxies.

// AllocateRelay allocates a relay location at which peers can relay WebRTC traffic to us.
// If successful, it starts relaying traffic to/from the localAddr and returns the URL at which
// peers should connect in order to start relaying.
func AllocateRelayAddress(localAddr string) (string, error) {
	// connect ot the local WebRTC candidate's address
	downstream, err := net.DialTimeout("tcp", localAddr, 5*time.Second)
	if err != nil {
		return "", errors.New("unable to connect to local addr %v: %v", localAddr, err)
	}

	// open a relay connection via our proxy
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	upstream, _, err := websocket.Dial(ctx, fmt.Sprintf("%v/allocate", relayServer), relayDialOptions())
	if err != nil {
		downstream.Close()
		return "", err
	}

	// read the relayAddr that was allocated by the relay
	_, relayAddr, err := upstream.Read(ctx)
	if err != nil {
		downstream.Close()
		upstream.Close(websocket.StatusNormalClosure, "")
		return "", err
	}

	go copyFromUpstream(downstream, upstream)
	go copyToUpstream(downstream, upstream)

	strRelayAddr := string(relayAddr)
	log.Debugf("Allocated relay address %v for %v", strRelayAddr, localAddr)

	return strRelayAddr, nil
}

func RelayTo(relayAddr string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	upstream, _, err := websocket.Dial(ctx, relayAddr, relayDialOptions())
	if err != nil {
		return "", err
	}

	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		upstream.Close(websocket.StatusNormalClosure, "")
		return "", err
	}

	downstreamCh := make(chan net.Conn)

	go func() {
		downstream, err := l.Accept()
		if err != nil {
			log.Debugf("error accepting from downstream: %v", err)
			close(downstreamCh)
		} else {
			downstreamCh <- downstream
		}
	}()

	go func() {
		select {
		case downstream, ok := <-downstreamCh:
			if !ok {
				return
			}
			go copyFromUpstream(downstream, upstream)
			copyToUpstream(downstream, upstream)
			return
		case <-time.After(60 * time.Second):
			upstream.Close(websocket.StatusNormalClosure, "")
			return
		}
	}()

	var addr = l.Addr().String()
	log.Debugf("Relaying %v to %v", addr, relayAddr)
	return addr, nil
}

func relayDialOptions() *websocket.DialOptions {
	return &websocket.DialOptions{
		HTTPClient: &http.Client{
			Transport: &http.Transport{
				Proxy: func(_ *http.Request) (*url.URL, error) {
					addr, found := client.Addr(5 * time.Second)
					if !found {
						return nil, errors.New("unable to find proxy addr")
					}
					return &url.URL{
						Scheme: "http",
						Host:   addr.(string),
					}, nil
				},
			},
		},
	}
}

func copyToUpstream(downstream net.Conn, upstream *websocket.Conn) {
	defer downstream.Close()

	b := make([]byte, 2048)
	for {
		n, err := downstream.Read(b)
		if err != nil {
			upstream.Close(websocket.StatusNormalClosure, "")
			return
		}
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		err = upstream.Write(ctx, websocket.MessageBinary, b[:n])
		cancel()
		if err != nil {
			return
		}
	}
}

func copyFromUpstream(downstream net.Conn, upstream *websocket.Conn) {
	defer upstream.Close(websocket.StatusNormalClosure, "")

	for {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		_, b, err := upstream.Read(ctx)
		cancel()
		if err != nil {
			downstream.Close()
			return
		}
		_, err = downstream.Write(b)
		if err != nil {
			return
		}
	}
}
