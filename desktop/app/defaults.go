//go:build !disableresourcerandomization
// +build !disableresourcerandomization

package app

import (
	"crypto/rand"
	"encoding/hex"

	"github.com/getlantern/lantern-client/desktop/settings"
)

const (
	defaultHTTPProxyAddress  = "127.0.0.1:0"
	defaultSOCKSProxyAddress = "127.0.0.1:0"
)

func randRead(size int) string {
	buf := make([]byte, size)
	if _, err := rand.Read(buf); err != nil {
		log.Fatalf("Failed to get random bytes: %s", err)
	}
	return hex.EncodeToString(buf)
}

// localHTTPToken fetches the local HTTP token from disk if it's there, and
// otherwise creates a new one and stores it.
func localHTTPToken(set *settings.Settings) string {
	tok := set.GetLocalHTTPToken()
	if tok == "" {
		t := randRead(16)
		set.SetLocalHTTPToken(t)
		return t
	}
	return tok
}
