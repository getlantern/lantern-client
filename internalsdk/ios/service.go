package ios

import (
	"net"
	"path/filepath"
	"strconv"
	"sync"
	"time"

	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/lantern-client/internalsdk"
	"github.com/getlantern/lantern-client/internalsdk/common"
)

var (
	startOnce sync.Once
)

type LanternService struct {
	memoryAvailable int64
	sessionModel    *internalsdk.SessionModel
}

func NewService(sessionModel *internalsdk.SessionModel) *LanternService {
	return &LanternService{
		sessionModel: sessionModel,
	}
}

func (s *LanternService) Start(configDir string, locale string, settings internalsdk.Settings) {
	optimizeMemoryUsage(&s.memoryAvailable)
	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
	internalsdk.StartService(s.sessionModel, configDir, locale, settings)
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
