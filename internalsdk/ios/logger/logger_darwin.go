package logger

// #include <os/log.h>
//
// void log_debug(const char *msg)
// {
//   os_log_debug(OS_LOG_DEFAULT, "%{public}s", msg);
// }
//
// void log_error(const char *msg)
// {
//   os_log_error(OS_LOG_DEFAULT, "%{public}s", msg);
// }
import "C"

import (
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/golog"
)

func init() {
	golog.SetOutputs(defaultLoggers())
}

// ConfigureFileLogging configures file logging to use the lantern.log file at
// the given path. It is required that the file, as well as files lantern.log.1
// through lantern.log.5 already exist so that they are writeable from the Go
// side.
func ConfigureFileLogging(fullLogFilePath string) error {
	logFileDirectory, filename := filepath.Split(fullLogFilePath)
	appName := strings.Split(filename, ".")[0]
	werr, wout := defaultLoggers()
	return logging.EnableFileLoggingWith(werr, wout, appName, logFileDirectory, 10, 10)
}

func defaultLoggers() (io.WriteCloser, io.WriteCloser) {
	return &dualWriter{os.Stderr, loggerWith(func(msg string) {
			C.log_error(C.CString(msg))
		})},
		&dualWriter{os.Stdout, loggerWith(func(msg string) {
			C.log_debug(C.CString(msg))
		})}
}

type dualWriter struct {
	w1 io.Writer
	w2 io.WriteCloser
}

func (dw *dualWriter) Write(b []byte) (int, error) {
	n, err := dw.w1.Write(b)
	n2, err2 := dw.w2.Write(b)
	if n2 < n {
		n = n2
	}
	if err == nil {
		err = err2
	}
	return n, err
}

func (dw *dualWriter) Close() error {
	return dw.w2.Close()
}

func loggerWith(fn func(string)) io.WriteCloser {
	return &loggerFn{fn}
}

type loggerFn struct {
	log func(string)
}

func (lf *loggerFn) Write(msg []byte) (int, error) {
	lf.log(string(msg))
	return len(msg), nil
}

func (lf *loggerFn) Close() error {
	return nil
}
