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
		Transport: proxied.ParallelPreferChained(),
		Timeout:   dialTimeout,
	}

	surveyUrl     = "https://raw.githubusercontent.com/getlantern/loconf/master/messages.json"
	noSurveyError = errors.New("Survey is not available for the user")
	jsonResponse  = `{
   "defaultLocale":"en-US",
   "surveys":{
      "IN": {
	 "enabled": true, 
	 "probability": 0.5,
	 "campaign": "",
	 "url": "https://lantern.surveysparrow.com/s/uae---monthly-quality-check/tt-x8w5Nwc8Ar5DMTJPSh3uP8",
	 "message": "Fill out the following survey to review Lantern's performance!",
	 "thanks": "",
	 "button": "Take Survey"
      }
   }
}`
)

type SurveyResponse struct {
	DefaultLocale *string           `json:"defaultLocale,omitempty"`
	Surveys       map[string]Survey `json:"surveys,omitempty"`
}

type Survey struct {
	Enabled         bool    `json:"enabled"`
	Probability     float64 `json:"probability"`
	Campaign        string  `json:"campaign"`
	URL             string  `json:"url"`
	Message         string  `json:"message"`
	Thanks          string  `json:"thanks"`
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
		log.Debugf("Failed to fetch survey response %v", err)
		return err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(body, &surveysResponse); err != nil {
		return log.Errorf("failed to unmarshal response body: %w", err)
	}
	// Lower case the keys of the survey map
	tempSurvey := make(map[string]Survey)
	for key, value := range surveysResponse.Surveys {
		lowerKey := strings.ToLower(key)
		tempSurvey[lowerKey] = value
	}
	surveysResponse.Surveys = tempSurvey
	// log.Debugf("Survey response fetched successfully %+v", surveysResponse.Surveys)
	return nil
}

// IsSurveyAvalible checks if the survey is available for the user.
func (s *SurveyModel) IsSurveyAvalible() (*Survey, error) {
	if surveysResponse == nil {
		return nil, errors.New("Survey response is nil or survey response is not fetched")
	}
	countryCode, err := s.SessionModel.GetCountryCode()
	if err != nil {
		return nil, err
	}
	// log.Debugf("Checking survey availability for the country code: %s and survey %v", countryCode, surveysResponse.Surveys)
	survey, exists := surveysResponse.Surveys[strings.ToLower(countryCode)]
	// Survey not found for the country code
	// Survey is not enabled
	if !exists || !survey.Enabled {
		return nil, noSurveyError
	}
	// probability check
	random := rand.Float64()
	if random > survey.Probability {
		log.Errorf("probability check failed for the survey %v", survey)
		return nil, noSurveyError
	}
	log.Debugf("Survey is available for the country code: %s and url is %s", countryCode, survey.URL)
	return &survey, nil

}
