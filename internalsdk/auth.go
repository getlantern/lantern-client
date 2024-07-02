package internalsdk

import (
	"context"
	"fmt"
	"net/http"

	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
)

type AuthClient interface {
	Login(username, password string)
	SignOut()
}

type authClient struct {
	client     auth.AuthClient
	userConfig common.UserConfig
}

func userConfigFromSession(wrappedSession Session) *UserConfig {
	return NewUserConfig(&panickingSessionImpl{wrappedSession})
}

func (c *authClient) Login(username, password string) {
	log.Debug("Received sign in request")
	c.client.Login(c.userConfig, username, password)
}

func (c *authClient) SignOut() {
	log.Debug("Received sign out request")
	c.client.SignOut(context.Background(), c.userConfig)
}

func NewAuthClient(wrappedSession Session) AuthClient {
	return &authClient{
		client: auth.NewClient(fmt.Sprintf("https://%s", common.V1BaseUrl), &webclient.Opts{
			HttpClient: &http.Client{
				Transport: proxied.Fronted(dialTimeout),
				Timeout:   dialTimeout,
			},
		}),
		userConfig: userConfigFromSession(wrappedSession),
	}
}
