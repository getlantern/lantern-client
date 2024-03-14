package internalsdk

import (
	"net"
	"path/filepath"
	"strconv"
	"time"

	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/logging"
)

type LanternService struct {
	sessionModel *SessionModel
}

func NewService(sessionModel *SessionModel) *LanternService {
	return &LanternService{
		sessionModel,
	}
}

func (s *LanternService) Start(configDir string, locale string, settings Settings) {
	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
	session := &panickingSessionImpl{s.sessionModel}
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
