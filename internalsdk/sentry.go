package internalsdk

import (
	"fmt"
	"runtime/debug"

	"github.com/getlantern/flashlight/common"
	"github.com/getlantern/hidden"
	"github.com/getlantern/ops"
	"github.com/getsentry/sentry-go"
)

var (
	// these are contextual properties that we're comfortable sending to Sentry
	whitelistedContext = []string{"op", "root_op", "geo_country", "is_data_capped", "is_pro", "locale_country", "locale_language"}
)

func init() {
	err := sentry.Init(sentry.ClientOptions{
		Dsn:              "https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353",
		AttachStacktrace: true,
		Release:          common.Version,
	})
	if err != nil {
		log.Errorf("Unable to initialize sentry: %v", err)
	}
}

func configureSentryScope(session panickingSession) {
	// configure global scope to include global ops context
	sentry.ConfigureScope(func(scope *sentry.Scope) {
		opsCtx := ops.AsMap(nil, true)
		for key, value := range opsCtx {
			if value != nil {
				// include global Ops context in Go scope
				scope.SetExtra(key, value)
				// include global Ops context in Java scope
				session.SetSentryExtra(key, fmt.Sprintf("%v", value))
			}
		}
	})
}

// sentryRecover recovers from a panic, logs it to Sentry, and then continues to panic.
// if a Session is provided, this will add some information to the session's scope for
// use on the Java side.
func sentryRecover(session Session) {
	sentryPanicIfNecessary(session, recover())
}

// sentryPanicIfNecessary will log an error to Sentry and then panic iff err is not nil
// it also adds an op to the global scope and includes the Go stacktrace in Java's scope
func sentryPanicIfNecessary(session Session, err interface{}) {
	if err == nil {
		return
	}

	log.Errorf("Sending panic to Sentry: %v", err)
	sentry.WithScope(func(scope *sentry.Scope) {
		// include whitelisted context
		opsContext := ops.AsMap(nil, true)
		for _, prop := range whitelistedContext {
			val, found := opsContext[prop]
			if found {
				stringVal := fmt.Sprintf("%v", val)
				scope.SetExtra(prop, stringVal)
				if session != nil {
					session.SetSentryExtra(prop, stringVal)
				}
			}
		}
		session.SetSentryExtra("gostack", string(debug.Stack()))
		scope.SetLevel(sentry.LevelFatal)
		sentry.CaptureMessage(hidden.Clean(fmt.Sprintf("%v", err)))
	})

	if result := sentry.Flush(common.SentryTimeout); !result {
		log.Error("Flushing to Sentry timed out")
	}

	panic(err)
}

// panicLoggingSession is a wrapper for Session that logs panics to Sentry
type panicLoggingSession struct {
	wrapped Session
}

func (s *panicLoggingSession) GetDeviceID() string {
	result, err := s.wrapped.GetDeviceID()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) GetUserID() int64 {
	result, err := s.wrapped.GetUserID()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) GetToken() string {
	result, err := s.wrapped.GetToken()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) SetCountry(country string) {
	sentryPanicIfNecessary(s.wrapped, s.wrapped.SetCountry(country))
}

func (s *panicLoggingSession) UpdateAdSettings(settings AdSettings) {
	sentryPanicIfNecessary(s.wrapped, s.wrapped.UpdateAdSettings(settings))
}

func (s *panicLoggingSession) UpdateStats(city, country, countryCode string, httpsUpgrades, adsBlocked int) {
	sentryPanicIfNecessary(s.wrapped, s.wrapped.UpdateStats(city, country, countryCode, httpsUpgrades, adsBlocked))
}

func (s *panicLoggingSession) SetStaging(staging bool) {
	sentryPanicIfNecessary(s.wrapped, s.wrapped.SetStaging(staging))
}

func (s *panicLoggingSession) ProxyAll() bool {
	result, err := s.wrapped.ProxyAll()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) BandwidthUpdate(percent, remaining, allowed, ttlSeconds int) {
	sentryPanicIfNecessary(s.wrapped, s.wrapped.BandwidthUpdate(percent, remaining, allowed, ttlSeconds))
}

func (s *panicLoggingSession) Locale() string {
	result, err := s.wrapped.Locale()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) GetTimeZone() string {
	result, err := s.wrapped.GetTimeZone()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) Code() string {
	result, err := s.wrapped.Code()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) GetCountryCode() string {
	result, err := s.wrapped.GetCountryCode()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) GetForcedCountryCode() string {
	result, err := s.wrapped.GetForcedCountryCode()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) GetDNSServer() string {
	result, err := s.wrapped.GetDNSServer()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) Provider() string {
	result, err := s.wrapped.Provider()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) AppVersion() string {
	result, err := s.wrapped.AppVersion()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) IsPlayVersion() bool {
	result, err := s.wrapped.IsPlayVersion()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) Email() string {
	result, err := s.wrapped.Email()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) Currency() string {
	result, err := s.wrapped.Currency()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) DeviceOS() string {
	result, err := s.wrapped.DeviceOS()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) IsProUser() bool {
	result, err := s.wrapped.IsProUser()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) SerializedInternalHeaders() string {
	result, err := s.wrapped.SerializedInternalHeaders()
	sentryPanicIfNecessary(s.wrapped, err)
	return result
}

func (s *panicLoggingSession) SetSentryExtra(key, value string) {
	sentryPanicIfNecessary(s.wrapped, s.wrapped.SetSentryExtra(key, value))
}
