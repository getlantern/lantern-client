package app

import (
	"net/http"
	"os"
)

// createDirIfNotExists checks that a directory exists, creating it if necessary
func createDirIfNotExists(dir string, perm os.FileMode) error {
	if _, err := os.Stat(dir); err != nil {
		if os.IsNotExist(err) {
			return os.MkdirAll(dir, perm)
		}
		return err
	}
	return nil
}

// startPprof starts a pprof server at the given address
func startPprof(addr string) {
	log.Debugf("Starting pprof server at %s (http://%s/debug/pprof)", addr)
	srv := &http.Server{Addr: addr}
	if err := srv.ListenAndServe(); err != nil {
		log.Errorf("Error starting pprof server: %v", err)
	}
}
