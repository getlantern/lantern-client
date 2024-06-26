package common

import (
	"crypto/rand"
	"math/big"
	"net/http"
	"strconv"
	"strings"

	mrand "math/rand"
)

const (
	AppHeader                           = "X-Lantern-App"
	LibraryVersionHeader                = "X-Lantern-Version"
	AppVersionHeader                    = "X-Lantern-App-Version"
	DeviceIdHeader                      = "X-Lantern-Device-Id"
	SupportedDataCapsHeader             = "X-Lantern-Supported-Data-Caps"
	TimeZoneHeader                      = "X-Lantern-Time-Zone"
	TokenHeader                         = "X-Lantern-Auth-Token"
	UserIdHeader                        = "X-Lantern-User-Id"
	ProTokenHeader                      = "X-Lantern-Pro-Token"
	CfgSvrAuthTokenHeader               = "X-Lantern-Config-Auth-Token"
	CfgSvrClientIPHeader                = "X-Lantern-Config-Client-IP"
	BBRBytesSentHeader                  = "X-BBR-Sent"
	BBRAvailableBandwidthEstimateHeader = "X-BBR-ABE"
	EtagHeader                          = "X-Lantern-Etag"
	KernelArchHeader                    = "X-Lantern-KernelArch"
	IfNoneMatchHeader                   = "X-Lantern-If-None-Match"
	PingHeader                          = "X-Lantern-Ping"
	PlatformHeader                      = "X-Lantern-Platform"
	PlatformVersionHeader               = "X-Lantern-PlatVer"
	ClientCountryHeader                 = "X-Lantern-Client-Country"
	RandomNoiseHeader                   = "X-Lantern-Rand"
	SleepHeader                         = "X-Lantern-Sleep"
	LocaleHeader                        = "X-Lantern-Locale"
	Referer                             = "Referer"
	XBQHeader                           = "XBQ"
	XBQHeaderv2                         = "XBQv2"
	ContentType                         = "Content-Type"
)

var (
	// List of methods the client is allowed to use with cross-domain requests
	corsAllowedMethods = []string{http.MethodGet, http.MethodPost, http.MethodOptions}
)

// AddCommonNonUserHeaders adds all common headers that are not
// user or device specific.
func AddCommonNonUserHeaders(uc UserConfig, req *http.Request) {
	req.Header.Set(AppVersionHeader, ApplicationVersion)
	req.Header.Set(LibraryVersionHeader, LibraryVersion)
	for k, v := range uc.GetInternalHeaders() {
		if v != "" {
			req.Header.Set(k, v)
		}
	}
	if len(uc.GetEnabledExperiments()) > 0 {
		req.Header.Set("x-lantern-dev-experiments", strings.Join(uc.GetEnabledExperiments(), ","))
	}

	req.Header.Set(PlatformHeader, Platform)
	req.Header.Set(AppHeader, uc.GetAppName())
	req.Header.Add(SupportedDataCapsHeader, "monthly")
	req.Header.Add(SupportedDataCapsHeader, "weekly")
	req.Header.Add(SupportedDataCapsHeader, "daily")
	tz, err := uc.GetTimeZone()
	if err != nil {
		log.Debugf("omitting timezone header because: %v", err)
	} else {
		req.Header.Set(TimeZoneHeader, tz)
	}
	// We include a random length string here to make it harder for censors to identify lantern
	// based on consistent packet lengths.
	req.Header.Add(RandomNoiseHeader, randomizedString())
}

// AddCommonHeadersWithOptions sets standard http headers on a request bound
// for an internal service, representing auth and other configuration
// metadata.  The caller may specify overwriteAuth=false to prevent overwriting
// any of the common 'auth' headers (DeviceIdHeader, ProTokenHeader, UserIdHeader)
// that are already present in the given request.
func AddCommonHeadersWithOptions(uc UserConfig, req *http.Request, overwriteAuth bool) {
	AddCommonNonUserHeaders(uc, req)
	if overwriteAuth || req.Header.Get(DeviceIdHeader) == "" {
		if deviceID := uc.GetDeviceID(); deviceID != "" {
			req.Header.Set(DeviceIdHeader, deviceID)
		}
	}
	if overwriteAuth || req.Header.Get(ProTokenHeader) == "" {
		if token := uc.GetToken(); token != "" {
			req.Header.Set(ProTokenHeader, token)
		}
	}
	if overwriteAuth || req.Header.Get(UserIdHeader) == "" {
		if userID := uc.GetUserID(); userID != 0 {
			req.Header.Set(UserIdHeader, strconv.FormatInt(userID, 10))
		}
	}
	req.Header.Set(LocaleHeader, uc.GetLanguage())
}

// AddCommonHeaders sets standard http headers on a request
// bound for an internal service, representing auth and other
// configuration metadata.
func AddCommonHeaders(uc UserConfig, req *http.Request) {
	AddCommonHeadersWithOptions(uc, req, true)
}

// isOriginAllowed checks if the origin is authorized
// for CORS requests. The origin can have include arbitrary
// ports, so we just make sure it's on localhost.
func isOriginAllowed(origin string) bool {
	return strings.HasPrefix(origin, "http://localhost:") ||
		strings.HasPrefix(origin, "http://127.0.0.1:") ||
		strings.HasPrefix(origin, "http://[::1]:")
}

// ProcessCORS processes CORS requests on localhost.
// It returns true if the request is a valid CORS request
// from an allowed origin and false otherwise.
func ProcessCORS(responseHeaders http.Header, r *http.Request) bool {
	origin := r.Header.Get("origin")
	if origin == "" {
		log.Debugf("Request is not a CORS request")
		return false
	}
	// The origin can have include arbitrary ports, so we just make sure
	// it's on localhost.
	if isOriginAllowed(origin) {

		responseHeaders.Set("Access-Control-Allow-Origin", origin)
		responseHeaders.Set("Vary", "Origin")
		responseHeaders.Set("Access-Control-Allow-Credentials", "true")
		for _, method := range corsAllowedMethods {
			responseHeaders.Add("Access-Control-Allow-Methods", method)
		}
		responseHeaders.Set("Access-Control-Allow-Headers", r.Header.Get("Access-Control-Request-Headers"))
		return true
	}
	return false
}

// CORSMiddleware is HTTP middleware used to process CORS requests on localhost
func CORSMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if ok := ProcessCORS(w.Header(), req); ok && req.Method == "OPTIONS" {
			// respond 200 OK to initial CORS request
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, req)
	})
}

// randomizedString returns a random string to avoid consistent packet lengths censors
// may use to detect Lantern.
func randomizedString() string {
	const charset = "abcdefghijklmnopqrstuvwxyz"
	size, err := rand.Int(rand.Reader, big.NewInt(300))
	if err != nil {
		return ""
	}

	bytes := make([]byte, size.Int64())
	for i := range bytes {
		bytes[i] = charset[mrand.Intn(len(charset))]
	}
	return string(bytes)
}
