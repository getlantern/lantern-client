package common

import (
	"os"
	"strconv"
	"strings"

	fcommon "github.com/getlantern/flashlight/v7/common"
)

// Environment represents different environments Lantern may be running in
type Environment int

const (
	Development Environment = iota
	Production
	Staging
)

var (
	// EnvMapping is a mapping for the Environment enum
	EnvMapping = map[string]Environment{
		Development.String(): Development,
		Production.String():  Production,
		Staging.String():     Staging,
	}

	// DisablePort is a boolean flag that corresponds with the DISABLE_PORT_RANDOMIZATION env var
	DisablePort bool

	// Environment is the environment flashlight is currently running in
	env Environment
)

func init() {
	DisablePort, _ = strconv.ParseBool(os.Getenv("DISABLE_PORT_RANDOMIZATION"))
	envVar := strings.ToLower(os.Getenv("ENVIRONMENT"))
	env = EnvMapping[envVar]
}

func (e Environment) String() string {
	switch e {
	case Development:
		return "development"
	case Staging:
		return "staging"
	default:
		return "production"
	}
}

// IsDevelopment checks if flashlight is currently being run in dev mode
func (e Environment) IsDevelopment() bool {
	return e == Development
}

// IsStaging checks if flashlight is currently being run in staging mode
func (e Environment) IsStaging() bool {
	return e == Staging
}

// IsDevEnvironment checks if flashlight is currently being run in development mode
func IsDevEnvironment() bool {
	return DisablePort && env.IsDevelopment()
}

// IsDevEnvironment checks if flashlight is currently being run in staging mode
func IsStagingEnvironment() bool {
	return fcommon.Staging || env.IsStaging()
}
