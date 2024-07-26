package internalsdk

import (
	"encoding/json"
	"io"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/getlantern/errors"
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

type SurveyResponse struct {
	DefaultLocale *string           `json:"defaultLocale,omitempty"`
	Surveys       map[string]Survey `json:"surveys,omitempty"`
}

type Survey struct {
	Enabled         bool    `json:"enabled"`
	Probability     float64 `json:"probability"`
	Campaign        *string `json:"campaign,omitempty"`
	URL             string  `json:"url"`
	Message         string  `json:"message"`
	Thanks          *string `json:"thanks,omitempty"`
	Button          string  `json:"button"`
	ShowPlansScreen *bool   `json:"showPlansScreen,omitempty"`
}

type SurveyModel struct {
	*SessionModel
}

var surveysResponse *SurveyResponse

// SurveyModel is a custom model derived from the baseModel.
func NewSurveyModel(session SessionModel) (*SurveyModel, error) {
	model := &SurveyModel{SessionModel: &session}
	return model, model.fetchSurvey()
}

func (s *SurveyModel) fetchSurvey() error {
	resp, err := httpClient.Get(surveyUrl)
	if err != nil {
		return err
	}
	log.Debugf("Survey response fetched successfully %v", resp)
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(body, &surveysResponse); err != nil {
		return log.Errorf("failed to unmarshal response body: %w", err)
	}
	log.Debugf("Survey response fetched successfully %v", surveysResponse)
	return nil
}

func (sr *SurveyResponse) UnmarshalJSON(data []byte) error {
	type Alias SurveyResponse
	aux := &struct {
		Surveys map[string]Survey `json:"surveys,omitempty"`
		*Alias
	}{
		Alias: (*Alias)(sr),
	}
	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	// Convert keys in Surveys map to lowercase
	for key, value := range aux.Surveys {
		lowerKey := strings.ToLower(key)
		sr.Surveys[lowerKey] = value
	}
	return nil
}

func (s *SurveyModel) IsSurveyAvalible() (*Survey, error) {
	if surveysResponse == nil {
		return nil, errors.New("Survey response is nil or survey response is not fetched")
	}
	countryCode, err := s.SessionModel.GetCountryCode()
	if err != nil {
		return nil, err
	}

	survey, exists := surveysResponse.Surveys[strings.ToLower(countryCode)]
	// Survey not found for the country code
	// Survey is not enabled
	if !exists || !survey.Enabled {
		return nil, nil
	}
	// probability check
	random := rand.Float64()
	if random > survey.Probability {
		return nil, nil
	}
	log.Debugf("Survey is available for the country code: %s and url is ", countryCode, survey.URL)
	return &survey, nil

}
