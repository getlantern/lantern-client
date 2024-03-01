//go:build !windows && !darwin
// +build !windows,!darwin

package logger

import (
	"github.com/getlantern/errors"
)

func ConfigureFileLogging(fullLogFilePath string) error {
	return errors.New("ConfigureFileLogging is only supported on darwin")
}
