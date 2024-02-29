package features

import (
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/getlantern/flashlight/v7/config"
)

var (
	// EnableReplicaFeatures enables replica related features via the REPLICA
	// build time variable.
	EnableReplicaFeatures = "false"

	// EnableReplica is true when we should force replica to be enabled
	// regardless of other configuration.
	EnableReplica = false

	// EnableTrafficlogFeatures is true when the traffic log should be enabled regardless of other
	// config. This can be set at build-time using -ldflags. For example,
	//   go build -ldflags "-X github.com/getlantern/flashlight/common.EnableTrafficlogFeatures=true"
	// More commonly you'd enable this via the TRAFFICLOG build time variable.
	EnableTrafficlogFeatures = "false"

	// EnableTrafficlog is true when the traffic log should be enabled regardless of
	// other config. This can be set at build-time; see EnableTrafficlogFeatures
	EnableTrafficlog = false

	// ForcedTrafficLogOptions contains the traffic log options that should be used if the
	// traffic log is force enabled at build time.
	ForcedTrafficLogOptions = &config.TrafficLogOptions{
		CaptureBytes:               10 * 1024 * 1024,
		SaveBytes:                  10 * 1024 * 1024,
		CaptureSaveDuration:        5 * time.Minute,
		Reinstall:                  true,
		WaitTimeSinceFailedInstall: 24 * time.Hour,
		UserDenialThreshold:        3,
		TimeBeforeDenialReset:      24 * time.Hour,
		FailuresThreshold:          3,
		TimeBeforeFailureReset:     24 * time.Hour,
	}

	// EnabledFeatures is a map of features to their
	// current enabled status
	EnabledFeatures map[Feature]bool
)

// Feature represents different types of Lantern "features" that can be enabled
// with build time variables or environment variables
type Feature int

const (
	Replica Feature = iota
	Auth
	Trafficlog
)

func (f Feature) String() string {
	switch f {
	case Replica:
		return "replica"
	case Auth:
		return "auth"
	case Trafficlog:
		return "trafficlog"
	}
	return ""
}

// isFeatureEnabled checks if a feature is enabled via a build time variable
// OR environment variable
func isFeatureEnabled(buildTimeVar string, feature Feature) bool {
	buildTimeEnable, _ := strconv.ParseBool(buildTimeVar)
	envVar := strings.ToUpper(feature.String())
	envVarEnable, _ := strconv.ParseBool(os.Getenv(envVar))
	return buildTimeEnable || envVarEnable
}

func init() {
	EnabledFeatures = map[Feature]bool{
		Replica:    isFeatureEnabled(EnableReplicaFeatures, Replica),
		Trafficlog: isFeatureEnabled(EnableTrafficlogFeatures, Trafficlog),
	}
}
