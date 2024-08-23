package sentry

import (
  "github.com/getlantern/flashlight/v7/util"
  "github.com/getlantern/golog"
  "github.com/getlantern/hidden"
  "github.com/getlantern/osversion"
  sentrySDK "github.com/getsentry/sentry-go"
)

var log = golog.LoggerFor("lantern-desktop.sentry")

type Opts struct {
  DSN                string
  MaxMessageChars    int
  ApplicationVersion string
}

func beforeSend(event *sentrySDK.Event, hint *sentrySDK.EventHint, sentryOpts Opts) *sentrySDK.Event {
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

func InitSentry(sentryOpts Opts) {
  sentrySDK.Init(sentrySDK.ClientOptions{
    Dsn:     sentryOpts.DSN,
    Release: sentryOpts.ApplicationVersion,
    BeforeSend: func(event *sentrySDK.Event, hint *sentrySDK.EventHint) *sentrySDK.Event {
      return beforeSend(event, hint, sentryOpts)
    },
  })

  sentrySDK.ConfigureScope(func(scope *sentrySDK.Scope) {
    os_version, err := osversion.GetHumanReadable()
    if err != nil {
      log.Errorf("Unable to get os version: %v", err)
    } else {
      scope.SetTag("os_version", os_version)
    }
  })
}
