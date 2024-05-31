package pro

import (
	"context"
	"net/http"
	"testing"

	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/stretchr/testify/assert"
)

func TestClient(t *testing.T) {
	log := golog.LoggerFor("pro-http-test")
	client := NewClient("https://api.getiantem.org", &Opts{
		// Just use the default transport since otherwise test setup is difficult.
		// This means it does not actually touch the proxying code, but that should
		// be tested separately.
		HttpClient: &http.Client{},
		UserConfig: func() common.UserConfig {
			return common.NewUserConfig(
				"Lantern",
				"device123", // deviceID
				123,         // userID
				"token",     // token
				nil,
				"en", // language
			)
		},
	})
	res, e := client.Plans(context.Background())
	if !assert.NoError(t, e) {
		return
	}
	log.Debugf("Got response: %v", res)
	assert.NotNil(t, res)
}

func TestLinkValidate(t *testing.T) {
	log := golog.LoggerFor("pro-http-test")
	client := NewClient("https://api.getiantem.org", &Opts{
		// Just use the default transport since otherwise test setup is difficult.
		// This means it does not actually touch the proxying code, but that should
		// be tested separately.
		HttpClient: &http.Client{},
		UserConfig: func() common.UserConfig {
			return common.NewUserConfig(
				"Lantern",
				"device123", // deviceID
				123,         // userID
				"token",     // token
				nil,
				"en", // language
			)
		},
	})
	prepareRequestBody := &protos.ValidateRecoveryCodeRequest{
		Email: "jigar@getlanern.org",
		Code:  "123456",
	}
	res, e := client.ValidateEmailRecoveryCode(context.Background(), prepareRequestBody)
	if !assert.NoError(t, e) {
		return
	}
	log.Debugf("Got response: %v", res)
	assert.NotNil(t, res)
}
