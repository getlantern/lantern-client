package internalsdk

import (
	"path/filepath"

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

func (s *LanternService) start(configDir string, locale string, settings Settings) {
	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
	session := &panickingSessionImpl{s.sessionModel}
	startOnce.Do(func() {
		go run(configDir, locale, settings, session)
	})
}
