package common

import (
  "time"

  "github.com/getlantern/timezone"
)

type UserConfig interface {
  GetAppName() string
  GetDeviceID() string
  GetUserID() int64
  GetToken() string
  GetLanguage() string
  GetTimeZone() (string, error)
  GetInternalHeaders() map[string]string
  GetEnabledExperiments() []string
}

// an implementation of UserConfig
type UserConfigData struct {
  AppName  string
  DeviceID string
  UserID   int64
  Token    string
  Language string
  Headers  map[string]string
}

func (uc *UserConfigData) GetAppName() string              { return uc.AppName }
func (uc *UserConfigData) GetDeviceID() string             { return uc.DeviceID }
func (uc *UserConfigData) GetUserID() int64                { return uc.UserID }
func (uc *UserConfigData) GetToken() string                { return uc.Token }
func (uc *UserConfigData) GetLanguage() string             { return uc.Language }
func (uc *UserConfigData) GetTimeZone() (string, error)    { return timezone.IANANameForTime(time.Now()) }
func (uc *UserConfigData) GetEnabledExperiments() []string { return nil }
func (uc *UserConfigData) GetInternalHeaders() map[string]string {
  h := make(map[string]string)
  for k, v := range uc.Headers {
    h[k] = v
  }
  return h
}

var _ UserConfig = (*UserConfigData)(nil)

// NewUserConfig constucts a new UserConfigData with the given options.
func NewUserConfig(appName string, deviceID string, userID int64, token string, headers map[string]string,
  lang string) *UserConfigData {
  uc := &UserConfigData{
    AppName:  appName,
    DeviceID: deviceID,
    UserID:   userID,
    Token:    token,
    Language: lang,
    Headers:  make(map[string]string),
  }
  for k, v := range headers {
    uc.Headers[k] = v
  }
  return uc
}
