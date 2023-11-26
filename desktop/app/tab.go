package app

import (
	"errors"
	"strings"
)

var (
	ErrMissingTab         = errors.New("missing tab")
	AccountTab = Tab("account")
	DeveloperTab = Tab("developer")
	VPNTab = Tab("vpn")
	UnknownTab = Tab("")
)

// Identifies a specific tab in the desktop app
type Tab string

// Parse the given string into a Tab
func ParseTab(s string) (Tab, error) {
	normalized := strings.ToLower(strings.TrimSpace(s))
	if normalized == "" {
		// leave currency empty
		return UnknownTab, ErrMissingTab
	}
	return Tab(normalized), nil
}