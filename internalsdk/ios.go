package internalsdk

import (
	"net"
	"strconv"
	"time"

	"github.com/getlantern/flashlight/v7/client"
)

func StartService(s *SessionModel, configDir string, locale string, settings Settings) {
	session := &panickingSessionImpl{s}
	startOnce.Do(func() {
		go run(configDir, locale, settings, session)
	})
}

func HTTPProxyPort() int {
	if addr, ok := client.Addr(6 * time.Second); ok {
		if _, p, err := net.SplitHostPort(addr.(string)); err == nil {
			port, _ := strconv.Atoi(p)
			return port
		}
	}
	log.Errorf("Couldn't retrieve HTTP proxy addr in time")
	return 0
}
