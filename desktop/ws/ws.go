package ws

import (
	"io"
	"net/http"
	"sync"

	"github.com/getlantern/golog"
	"github.com/gorilla/websocket"
)

const (
	// MaxMessageSize determines the chunking size of messages used by gorilla
	MaxMessageSize = 1024
)

var (
	log      = golog.LoggerFor("lantern-desktop.ws")
	upgrader = &websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: MaxMessageSize,
		CheckOrigin:     func(r *http.Request) bool { return true }, // I need this to test Lantern UI from a different host.
	}
)

type ConnectFunc func(out chan<- []byte)

// clientChannels represents a data channel to/from the UI. UIChannel will have one
// underlying websocket connection for each connected browser window. All
// messages from any browser window are available via In and all messages sent
// to Out will be published to all browser windows.
type clientChannels struct {
	In  <-chan []byte
	Out chan<- []byte

	in  chan []byte
	out chan []byte

	muConns       sync.Mutex
	nextId        int
	conns         map[int]*wsconn
	connsToRemove chan *wsconn

	onConnect ConnectFunc
}

// newClients establishes a new channel acts as an http.Handler. When the UI
// connects to the handler, we will establish a websocket to the UI to carry
// messages for this UIChannel. The given onConnect function is called anytime
// that the UI connects.
func newClients(onConnect ConnectFunc) *clientChannels {
	if onConnect == nil {
		onConnect = func(chan<- []byte) {}
	}

	in := make(chan []byte, 100)
	out := make(chan []byte)
	c := &clientChannels{
		In:            in,
		in:            in,
		Out:           out,
		out:           out,
		nextId:        0,
		conns:         make(map[int]*wsconn),
		connsToRemove: make(chan *wsconn, 100),
		onConnect:     onConnect,
	}

	return c
}

func (c *clientChannels) ServeHTTP(resp http.ResponseWriter, req *http.Request) {
	log.Debugf("Got connection to the UI channel")
	var err error

	if req.Method != "GET" {
		http.Error(resp, "Method not allowed", 405)
		return
	}
	// Upgrade with a HTTP request returns a websocket connection
	ws, err := upgrader.Upgrade(resp, req, nil)
	if err != nil {
		log.Errorf("Unable to upgrade to websocket: %v", err)
		return
	}

	log.Debugf("Upgraded to websocket")
	defer func() {
		if err := ws.Close(); err != nil {
			log.Debugf("Error closing WebSockets connection: %s", err)
		}
	}()

	c.muConns.Lock()
	c.nextId++
	conn := &wsconn{
		id:         c.nextId,
		c:          c,
		ws:         ws,
		connectOut: make(chan []byte, 1000),
		out:        make(chan []byte, 1000),
	}
	c.conns[conn.id] = conn
	c.muConns.Unlock()

	c.onConnect(conn.connectOut)
	go conn.write()

	log.Tracef("About to read from websocket connection")
	conn.read()
}

func (c *clientChannels) writeAll() {
	defer func() {
		log.Debugf("Closing all websockets")
		c.muConns.Lock()
		for _, conn := range c.conns {
			c.doRemoveConn(conn)
		}
		c.muConns.Unlock()
	}()

	for {
		select {
		case msg, ok := <-c.out:
			if !ok {
				// channel closed, we're done sending
				return
			}
			for _, conn := range c.clonedConns() {
				select {
				case conn.out <- msg:
				default:
					log.Errorf("Failed to send message %v to websocket connection", msg)
				}
			}
		case conn := <-c.connsToRemove:
			log.Debugf("Removing single conn")
			c.lockedRemoveConn(conn)
		}
	}
}

func (c *clientChannels) clonedConns() map[int]*wsconn {
	c.muConns.Lock()
	defer c.muConns.Unlock()
	clone := make(map[int]*wsconn)
	for k, v := range c.conns {
		clone[k] = v
	}
	return clone
}

func (c *clientChannels) lockedRemoveConn(conn *wsconn) {
	c.muConns.Lock()
	defer c.muConns.Unlock()
	conn = c.conns[conn.id]
	if conn != nil {
		c.doRemoveConn(conn)
	}
}

func (c *clientChannels) doRemoveConn(conn *wsconn) {
	if err := conn.ws.Close(); err != nil {
		log.Debugf("Error closing WebSockets connection: %v", err)
	}
	close(conn.out)
	delete(c.conns, conn.id)
}

// wsconn ties a websocket.Conn to a clientChannels
type wsconn struct {
	id         int
	c          *clientChannels
	ws         *websocket.Conn
	connectOut chan []byte
	out        chan []byte
}

func (c *wsconn) read() {
	for {
		_, b, err := c.ws.ReadMessage()
		log.Tracef("Read message: %q", b)
		if err != nil {
			if err != io.EOF {
				log.Debugf("Error reading from UI: %v", err)
			}
			return
		}
		log.Tracef("Sending to channel...")
		c.c.in <- b
	}
}

func (c *wsconn) write() {
	for {
		select {
		case msg := <-c.connectOut:
			if !c.doWrite(msg) {
				return
			}
		case msg, ok := <-c.out:
			if !ok {
				return
			}
			if !c.doWrite(msg) {
				return
			}
		}
	}
}

func (c *wsconn) doWrite(msg []byte) bool {
	err := c.ws.WriteMessage(websocket.TextMessage, msg)
	if err != nil {
		log.Debugf("Error writing to WebSocket, closing: %v", err)
		c.c.connsToRemove <- c
		return false
	}
	return true
}
