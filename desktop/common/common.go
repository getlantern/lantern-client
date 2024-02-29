package common

import (
	"os"
	"strconv"
	"strings"

	fcommon "github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/golog"
)

// Environment represents the different
// environment modes Lantern may be running in
type Environment int

const (
	Development Environment = iota
	Production
	Staging
)

// ServerType is a type that represents different Lantern
// back-end services
type ServerType int

const (
	AuthServer ServerType = iota
)

var (
	// EnvMapping is a mapping for the Environment enum
	EnvMapping = map[string]Environment{
		Development.String(): Development,
		Production.String():  Production,
		Staging.String():     Staging,
	}

	// AuthServerAddr is the auth server address to use
	AuthServerAddr = "https://auth4.lantern.network"

	// DisablePort is a boolean flag that corresponds with the DISABLE_PORT_RANDOMIZATION env var
	DisablePort bool

	// Environment is the environment flashlight is currently running in
	env Environment

	// ZipkinEndpoint specifies the URL to which zipkin spans should be sent
	ZipkinEndpoint = "https://zipkin-pro-server-neu.128.network/api/v2/spans"
	// ZipkinAPIKey specifies the API key to use when sending spans to Zipkin, should match https://github.com/getlantern/pro-server-neu-infrastructure-zipkin/blob/main/.codedeploy/default#L30
	ZipkinAPIKey = "38249ee3-ca14-45b7-9c58-3e668c3e6791"

	log = golog.LoggerFor("lantern-desktop.common")
)

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

func (s ServerType) String() string {
	switch s {
	case AuthServer:
		return "auth"
	default:
		return ""
	}
}

func init() {
	DisablePort, _ = strconv.ParseBool(os.Getenv("DISABLE_PORT_RANDOMIZATION"))
	envVar := strings.ToLower(os.Getenv("ENVIRONMENT"))
	env = EnvMapping[envVar]

	if env.IsStaging() {
		AuthServerAddr = "https://auth-staging.lantern.network"
	}
}

// GetAPIAddr returns the API address to use for the given
// server type. If an address is specified with a command line flag
// that value overides the default
func GetAPIAddr(serverType ServerType, flagAddr string) string {
	var defaultAddr string
	switch serverType {
	case AuthServer:
		defaultAddr = AuthServerAddr
	}
	addr := flagAddr
	if addr == "" {
		addr = defaultAddr
	}
	log.Debugf("Using %s server at %s", serverType.String(), addr)
	return addr
}

// IsDevEnvironment checks if flashlight is currently being run in development mode
func IsDevEnvironment() bool {
	return DisablePort && env.IsDevelopment()
}

// IsDevEnvironment checks if flashlight is currently being run in staging mode
func IsStagingEnvironment() bool {
	return fcommon.Staging || env.IsStaging()
}
