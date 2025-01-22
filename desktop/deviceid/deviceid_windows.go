//go:build windows
// +build windows

package deviceid

import (
	"strings"

	"github.com/google/uuid"
	"golang.org/x/sys/windows/registry"
)

const (
	keyPath = `Sofware\\Lantern`
)

// Get returns a unique identifier for this device. The identifier is a random UUID that's stored in the registry
// at HKEY_CURRENT_USERS\Software\Lantern\deviceid. If unable to read/write to the registry, this defaults to the
// old-style device ID derived from MAC address.
func Get() string {
	return get(keyPath)
}

func get(keyPath string) string {
	key, _, err := registry.CreateKey(registry.CURRENT_USER, keyPath, registry.QUERY_VALUE|registry.SET_VALUE|registry.WRITE)
	if err != nil {
		log.Errorf("Unable to create registry entry to store deviceID, defaulting to old-style device ID: %v", err)
		return OldStyleDeviceID()
	}

	existing, _, err := key.GetStringValue("deviceid")
	if err != nil {
		if err != registry.ErrNotExist {
			log.Errorf("Unexpected error reading deviceID, default to old-style device ID: %v", err)
			return OldStyleDeviceID()
		}
		log.Debug("Storing new deviceID")
		_deviceID, err := uuid.NewRandom()
		if err != nil {
			log.Errorf("Error generating new deviceID, defaulting to old-style device ID: %v", err)
			return OldStyleDeviceID()
		}
		deviceID := _deviceID.String()
		err = key.SetStringValue("deviceid", deviceID)
		if err != nil {
			log.Errorf("Error storing new deviceID, defaulting to old-style device ID: %v", err)
			return OldStyleDeviceID()
		}
		return deviceID
	}

	return strings.TrimSpace(existing)
}
