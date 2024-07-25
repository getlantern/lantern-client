package internalsdk

import (
	"net/http"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
)

var (
	dialTimeout = 30 * time.Second
	httpClient  = &http.Client{
		Transport: proxied.Fronted(dialTimeout),
		Timeout:   dialTimeout,
	}
	surveyUrl = "https://raw.githubusercontent.com/getlantern/loconf/master/messages.json"
)

type SurveyModel struct {
	*SessionModel
}

// SurveyModel is a custom model derived from the baseModel.
func NewSurveyModel(session SessionModel) *SurveyModel {
	model := &SurveyModel{SessionModel: &session}
	return model
}

// func (s *SurveyModel) fetchSurvey() error {

// }
