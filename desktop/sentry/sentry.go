package sentry

import (
	"github.com/getlantern/flashlight/v7/util"
	"github.com/getlantern/golog"
	"github.com/getlantern/hidden"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/osversion"
	"github.com/getsentry/sentry-go"
)

var log = golog.LoggerFor("lantern-desktop.sentry")

type Opts struct {
	DSN                string
	MaxMessageChars    int
	ApplicationVersion string
}

func beforeSend(event *sentry.Event, hint *sentry.EventHint, sentryOpts Opts) *sentry.Event {
	for i, exception := range event.Exception {
		event.Exception[i].Value = hidden.Clean(exception.Value)
	}
	//event.Fingerprint = generateFingerprint(event)

	// sentry's sdk has a somewhat undocumented max message length
	// after which it seems it will silently drop/fail to send messages
	// https://github.com/getlantern/flashlight/pull/806
	event.Message = util.TrimStringAsBytes(event.Message, sentryOpts.MaxMessageChars)
	return event
}

// LogPanic sends a fatal-level message to Sentry and flushes the event.
func LogPanic(msg string) {
	sentry.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetLevel(sentry.LevelFatal)
	})

	sentry.CaptureMessage(msg)
	sentryFlush()
}

// OnExit logs a fatal error to Sentry
func OnExit(err error) {
	sentry.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetLevel(sentry.LevelFatal)
	})

	sentry.CaptureException(err)
	sentryFlush()
}

// sentryFlush attempts to send buffered events to Sentry before timeout
func sentryFlush() {
	if result := sentry.Flush(common.SentryTimeout); !result {
		log.Error("Flushing to Sentry timed out")
	}
}

func InitSentry(sentryOpts Opts) {
	sentry.Init(sentry.ClientOptions{
		Dsn:     sentryOpts.DSN,
		Release: sentryOpts.ApplicationVersion,
		BeforeSend: func(event *sentry.Event, hint *sentry.EventHint) *sentry.Event {
			return beforeSend(event, hint, sentryOpts)
		},
	})

	sentry.ConfigureScope(func(scope *sentry.Scope) {
		os_version, err := osversion.GetHumanReadable()
		if err != nil {
			log.Errorf("Unable to get os version: %v", err)
		} else {
			scope.SetTag("os_version", os_version)
		}
	})
}
