package ios

import (
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/ios/logger"
)

var (
	log      = golog.LoggerFor("ios")
	statsLog = golog.LoggerFor("ios.stats")
	swiftLog = golog.LoggerFor("ios.swift")
)

// ConfigureFileLogging configures logging to log to files at the given fullLogFilePath
// and capture heap and goroutine profiles at the given profile path.
func ConfigureFileLogging(fullLogFilePath string, profilePath string) error {
	SetProfilePath(profilePath)
	return logger.ConfigureFileLogging(fullLogFilePath)
}

// LogDebug logs the given msg to the swift logger at debug level
func LogDebug(msg string) {
	swiftLog.Debug(msg)
}

// LogError logs the given msg to the swift logger at error level
func LogError(msg string) {
	swiftLog.Error(msg)
}
