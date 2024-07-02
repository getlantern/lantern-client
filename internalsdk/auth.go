package internalsdk

import (
	"context"
	"fmt"
	"net/http"

	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
)

type AuthClient interface {
	Login(username, password string) (string, error)
	SignOut() (string, error)
	SignUp(username, password string) (string, error)
	StartRecoveryByEmail(email string) (string, error)
	CompleteRecoveryByEmail(email, password, code string) (string, error)
}

type authClient struct {
	client     auth.AuthClient
	userConfig common.UserConfig
}

func userConfigFromSession(wrappedSession Session) *UserConfig {
	return NewUserConfig(&panickingSessionImpl{wrappedSession})
}

func (c *authClient) Login(username, password string) (string, error) {
	log.Debug("Received sign in request")
	resp, _, err := c.client.Login(c.userConfig, username, password)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *authClient) SignUp(username, password string) (string, error) {
	log.Debug("Received sign up request")
	resp, err := c.client.SignUp(username, password)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *authClient) SignOut() (string, error) {
	log.Debug("Received sign out request")
	resp, err := c.client.SignOut(context.Background(), c.userConfig)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *authClient) StartRecoveryByEmail(email string) (string, error) {
	log.Debug("Received start recovery by email request")
	resp, err := c.client.StartRecoveryByEmail(context.Background(), &protos.StartRecoveryByEmailRequest{
		Email: email,
	})
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *authClient) CompleteRecoveryByEmail(email, password, code string) (string, error) {
	log.Debug("Received complete recovery by email request")
	resp, err := c.client.CompleteRecoveryByEmail(context.Background(), &protos.CompleteRecoveryByEmailRequest{
		Email: email,
		Code:  code,
	})
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func NewAuthClient(wrappedSession Session) AuthClient {
	return &authClient{
		client: auth.NewClient(fmt.Sprintf("https://%s", common.V1BaseUrl), &webclient.Opts{
			UserConfig: func() common.UserConfig {
				return userConfigFromSession(wrappedSession)
			},
			HttpClient: &http.Client{
				Transport: proxied.Fronted(dialTimeout),
				Timeout:   dialTimeout,
			},
		}),
		userConfig: userConfigFromSession(wrappedSession),
	}
}
