package common

import (
	"runtime/debug"
	"strings"

	"github.com/blang/semver"
)

var (
	// ApplicationVersion is set at compile-time by application production builds
	ApplicationVersion string = "9999.99.99"

	// LibraryVersion is determined at runtime based on the version of the lantern library that's been included.
	LibraryVersion = ""

	// This gets set at build time
	RevisionDate = ""

	// This gets set at build time
	BuildDate = ""
)

func init() {
	buildInfo, ok := debug.ReadBuildInfo()
	if !ok {
		panic("Unable to read build info")
	}

versionLoop:
	for _, dep := range buildInfo.Deps {
		if strings.HasPrefix(dep.Path, "github.com/getlantern/flashlight") && strings.HasPrefix(dep.Version, "v") {
			version := dep.Version[1:]
			log.Debugf("Flashlight version is %v", version)
			_, parseErr := semver.Parse(version)
			if parseErr == nil {
				log.Debugf("Setting LibraryVersion to %v", version)
				LibraryVersion = version
				break versionLoop
			}
		}
	}
}
