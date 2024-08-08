package app

import "net/http"

func startDebugServer() {
	addr := "localhost:6060"
	go func() {
		log.Debugf("Starting pprof page at http://%s/debug/pprof", addr)
		srv := &http.Server{
			Addr: addr,
		}
		if err := srv.ListenAndServe(); err != nil {
			log.Error(err)
		}
	}()
}
