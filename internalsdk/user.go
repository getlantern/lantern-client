package internalsdk

import (
	"encoding/json"

	"github.com/getlantern/lantern-client/internalsdk/common"
)

type userConfig struct {
	session PanickingSession
}

func (uc *userConfig) GetAppName() string              { return common.DefaultAppName }
func (uc *userConfig) GetDeviceID() string             { return uc.session.GetDeviceID() }
func (uc *userConfig) GetUserID() int64                { return uc.session.GetUserID() }
func (uc *userConfig) GetToken() string                { return uc.session.GetToken() }
func (uc *userConfig) GetEnabledExperiments() []string { return nil }
func (uc *userConfig) Locale() string                  { return uc.session.Locale() }
func (uc *userConfig) GetLanguage() string             { return uc.session.Locale() }
func (uc *userConfig) GetTimeZone() (string, error)    { return uc.session.GetTimeZone(), nil }
func (uc *userConfig) GetInternalHeaders() map[string]string {
	h := make(map[string]string)

	var f interface{}
	if err := json.Unmarshal([]byte(uc.session.SerializedInternalHeaders()), &f); err != nil {
		return h
	}
	m, ok := f.(map[string]interface{})
	if !ok {
		return h
	}

	for k, v := range m {
		vv, ok := v.(string)
		if ok {
			h[k] = vv
		}
	}
	return h
}
