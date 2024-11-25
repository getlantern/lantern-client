package app

import (
	"net/http"
	"os"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/sentry"
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

// startPprof starts a pprof server at the given address
func startPprof(addr string) {
	log.Debugf("Starting pprof server at %s (http://%s/debug/pprof)", addr)
	srv := &http.Server{Addr: addr}
	if err := srv.ListenAndServe(); err != nil {
		log.Errorf("Error starting pprof server: %v", err)
	}
}

// initLogging is used to setup application logging
func initLogging(configDir string) {
	_, err := logging.RotatedLogsUnder(configDir, appdir.Logs(configDir))
	if err != nil {
		log.Error(err)
	}

	// This init needs to be called before the panicwrapper fork so that it has been
	// defined in the parent process
	if ShouldReportToSentry() {
		sentry.InitSentry(sentry.Opts{
			DSN:             common.SentryDSN,
			MaxMessageChars: common.SentryMaxMessageChars,
		})
	}
	golog.SetPrepender(logging.Timestamped)
}
