package app

import (
	"fmt"
	"net"
	"net/http"
)

func (app *App) serveWebsocket() error {
	mux := http.NewServeMux()
	mux.Handle("/data", app.ws.Handler())
	mux.Handle("/sysproxy", app.ws.Handler())

	server := &http.Server{
		Handler:  mux,
		ErrorLog: log.AsStdLogger(),
	}
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return err
	}
	port := l.Addr().(*net.TCPAddr).Port

	websocketAddr := fmt.Sprintf("127.0.0.1:%d", port)

	log.Debugf("serving websocket connections at %s", websocketAddr)
	app.setWebsocket(server, websocketAddr)

	go server.Serve(l)
	return nil
}

func (app *App) setWebsocket(s *http.Server, addr string) {
	app.mu.Lock()
	app.wsServer = s
	app.websocketAddr = addr
	app.mu.Unlock()
}

func (app *App) WebsocketAddr() string {
	app.mu.RLock()
	defer app.mu.RUnlock()
	return app.websocketAddr
}
