package ws

import (
	"net"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/websocket"
	"github.com/stretchr/testify/assert"
)

type locationData struct {
	Code string `json:"code"`
}

func TestStartServer(t *testing.T) {

	channel := NewUIChannel()
	mux := http.NewServeMux()
	mux.Handle("/data", channel.Handler())

	server := &http.Server{
		Handler:  mux,
		ErrorLog: log.AsStdLogger(),
	}

	l, _ := net.Listen("tcp", "127.0.0.1:0")

	port := l.Addr().(*net.TCPAddr).Port
	go server.Serve(l)

	helloFn := func(write func(interface{})) {
		log.Debugf("Sending message to new client")
		write(locationData{
			Code: "US",
		})
	}
	service, _ := channel.Register("hello", helloFn)
	defer channel.Unregister("hello")

	u := url.URL{Scheme: "ws", Host: "127.0.0.1:" + strconv.Itoa(port), Path: "/data"}
	log.Debugf("connecting to %s", u.String())

	time.Sleep(100 * time.Millisecond)
	c, _, _ := websocket.DefaultDialer.Dial(u.String(), nil)
	defer c.Close()

	done := make(chan struct{})

	defer c.Close()
	defer close(done)
	_, message, err := c.ReadMessage()
	if err != nil {
		log.Debugf("read:", err)
		return
	}
	log.Debugf("recv: %s", message)

	// Just make sure we get the expected message back in response to the
	// connection.
	assert.True(t, strings.Contains(string(message), "US"))

	msgBody := locationData{
		Code: "CN",
	}
	msg, _ := newEnvelope("hello", msgBody)
	err = c.WriteMessage(websocket.TextMessage, msg)
	assert.Nil(t, err)

	received := <-service.in
	log.Debugf("recv: %s", received)
	close(service.in)
	close(service.out)
}
