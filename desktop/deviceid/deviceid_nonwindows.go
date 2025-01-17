//go:build !windows
// +build !windows

package deviceid

import (
	"os"
	"path/filepath"
	"strings"

	"github.com/getlantern/appdir"
	"github.com/google/uuid"
)

// Get returns a unique identifier for this device. The identifier is a random UUID that's stored on
// disk at $HOME/.lanternsecrets/.deviceid. If unable to read/write to that location, this defaults to the
// old-style device ID derived from MAC address.
func Get() string {
	return get(appdir.InHomeDir(".lanternsecrets"))
}

func get(path string) string {
	if err := os.Mkdir(path, 0755); err != nil && !os.IsExist(err) {
		log.Errorf("Unable to create folder to store deviceID, defaulting to old-style device ID: %v", err)
		return OldStyleDeviceID()
	}
	filename := filepath.Join(path, ".deviceid")
	// Try reading the existing device ID from file.
	existing, err := os.ReadFile(filename)
	if err == nil {
		return strings.TrimSpace(string(existing))
	}
	log.Debug("Storing new deviceID")
	_deviceID, err := uuid.NewRandom()
	if err != nil {
		log.Errorf("Error generating new deviceID, defaulting to old-style device ID: %v", err)
		return OldStyleDeviceID()
	}
	deviceID := _deviceID.String()
	err = os.WriteFile(filename, []byte(deviceID), 0644)
	if err != nil {
		log.Errorf("Error storing new deviceID, defaulting to old-style device ID: %v", err)
		return OldStyleDeviceID()
	}
	return deviceID
}
