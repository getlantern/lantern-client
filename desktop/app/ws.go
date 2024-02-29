package app

import (
	"fmt"
	"net"
	"net/http"
	"net/url"
	"strconv"
)

func (app *App) serveWebsocket() {
	mux := http.NewServeMux()
	mux.Handle("/data", app.ws.Handler())
	mux.Handle("/sysproxy", app.ws.Handler())

	server := &http.Server{
		Handler:  mux,
		ErrorLog: log.AsStdLogger(),
	}
	l, _ := net.Listen("tcp", "127.0.0.1:0")

	port := l.Addr().(*net.TCPAddr).Port
	go server.Serve(l)

	u := url.URL{Scheme: "ws", Host: "127.0.0.1:" + strconv.Itoa(port), Path: "/data"}
	log.Debugf("serving websocket connections at %s", u.String())
	app.setWebsocketAddr(fmt.Sprintf("127.0.0.1:%d", port))
}

func (app *App) setWebsocketAddr(addr string) {
	app.mu.Lock()
	defer app.mu.Unlock()
	app.websocketAddr = addr
}

func (app *App) WebsocketAddr() string {
	return app.websocketAddr
}

func (app *App) setWebsocketServer(server *http.Server) {
	app.mu.Lock()
	defer app.mu.Unlock()
	app.websocketServer = server
}