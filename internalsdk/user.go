package internalsdk

import (
	"context"
	"encoding/json"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
)

// ClientSession includes information needed to create a new client session
type ClientSession interface {
	GetDeviceID() (string, error)
	GetUserID() (int64, error)
	GetToken() (string, error)
	Locale() (string, error)
	SetUserIdAndToken(int64, string) error
}

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

func newUserConfig(session ClientSession, platform string) func() common.UserConfig {
	return func() common.UserConfig {
		internalHeaders := map[string]string{
			common.PlatformHeader:   platform,
			common.AppVersionHeader: common.ApplicationVersion,
		}
		deviceID, _ := session.GetDeviceID()
		userID, _ := session.GetUserID()
		token, _ := session.GetToken()
		lang, _ := session.Locale()
		return common.NewUserConfig(
			common.DefaultAppName,
			deviceID,
			userID,
			token,
			internalHeaders,
			lang,
		)
	}
}

func createUser(ctx context.Context, proClient pro.ProClient, session ClientSession) error {
	resp, err := proClient.UserCreate(ctx)
	if err != nil {
		log.Errorf("Error sending request: %v", err)
		return err
	}
	user := resp.User
	if user == nil || user.UserId == 0 {
		log.Errorf("User not found in response")
		return errors.New("User not found in response")
	}

	// Save user id and token
	session.SetUserIdAndToken(int64(user.UserId), user.Token)
	log.Debugf("Created new Lantern user: %+v", user)
	return nil
}

// retryCreateUser is used to retry creating a user with an exponential backoff strategy
func retryCreateUser(ctx context.Context, session ClientSession) {
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 3 * time.Second
	expBackoff.MaxInterval = 1 * time.Minute
	expBackoff.MaxElapsedTime = 10 * time.Minute
	expBackoff.RandomizationFactor = 0.5 // Add jitter to backoff interval
	proClient := createProClient(session, "android")
	// Start retrying with exponential backoff
	err := backoff.Retry(func() error {
		err := createUser(ctx, proClient, session)
		if err != nil {
			return log.Errorf("Unable to create Lantern user: %v", err)
		}
		log.Debug("Successfully created user")
		return nil
	}, backoff.WithContext(expBackoff, ctx))
	if err != nil {
		log.Fatal("Unable to create Lantern user after max retries")
	}
}
