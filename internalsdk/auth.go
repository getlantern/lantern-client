package internalsdk

import (
	"errors"
	"net/http"
	"net/http/cookiejar"
	"time"

	authclient "github.com/getlantern/auth-server/client"
	"github.com/getlantern/auth-server/models"
	"github.com/getlantern/flashlight/proxied"
	"golang.org/x/net/publicsuffix"
)

var (
	ErrRegistrationFailed = errors.New("Registration failed")
)

type AuthClient struct {
	client   authclient.AuthClient
	username string
	password string
}

func NewAuthClient(serverURL, username, password string) (*AuthClient, error) {
	httpClient, err := createHTTPClient()
	if err != nil {
		return nil, err
	}
	client := authclient.New(serverURL, httpClient)
	return &AuthClient{
		client:   client,
		username: username,
		password: password,
	}, nil
}

func (ac *AuthClient) Register(lanternUserID int) error {
	resp, err := ac.client.Register(&models.UserParams{
		Username:      ac.username,
		LanternUserID: int64(lanternUserID),
	}, ac.password)
	if err != nil {
		return log.Error(err)
	}
	if !resp.Response.Success {
		return log.Errorf("%v: %v", ErrRegistrationFailed, resp.Response.Error)
	}
	return nil
}

// createHTTPClient creates a chained-then-fronted configured HTTP client
// to be used by multiple UI handlers
func createHTTPClient() (*http.Client, error) {
	rt := proxied.ChainedThenFrontedWith("")
	rt.SetMasqueradeTimeout(30 * time.Second)
	jar, err := cookiejar.New(&cookiejar.Options{PublicSuffixList: publicsuffix.List})
	if err != nil {
		log.Errorf("Error creating HTTP client: %v", err)
		return nil, err
	}

	client := &http.Client{
		Jar:       jar,
		Transport: rt,
	}
	return client, nil
}
