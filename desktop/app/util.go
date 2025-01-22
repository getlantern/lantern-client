package app

import (
	"fmt"
	"net/http"
	"os"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/lantern-client/internalsdk/common"
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

// configDir sets the config directory from flashlight Flags or default application directory
// and creates the directory if it doesn't exist
func configDir(flags flashlight.Flags) (string, error) {
	configDir := flags.ConfigDir
	if configDir == "" {
		log.Debug("Config directory is empty, using default location")
		configDir = appdir.General(common.DefaultAppName)
	}

	if err := createDirIfNotExists(configDir, defaultConfigDirPerm); err != nil {
		return "", fmt.Errorf("unable to create config directory %s: %v", configDir, err)
	}
	return configDir, nil
}

// startPprof starts a pprof server at the given address
func startPprof(addr string) {
	log.Debugf("Starting pprof server at %s (http://%s/debug/pprof)", addr)
	srv := &http.Server{Addr: addr}
	if err := srv.ListenAndServe(); err != nil {
		log.Errorf("Error starting pprof server: %v", err)
	}
}
