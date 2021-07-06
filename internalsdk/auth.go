package internalsdk

import (
	"net/http"
	"net/http/cookiejar"
	"time"
	_ "unsafe" // For go:linkname

	"github.com/getlantern/auth-server/api"
	"github.com/getlantern/auth-server/client"
	"github.com/getlantern/auth-server/models"
	"github.com/getlantern/flashlight/proxied"
	"golang.org/x/net/publicsuffix"
)

const (
	authAPIHost        = "auth4.lantern.network"
	authStagingAPIHost = "auth-staging.lantern.network"
)

var (
	handler *authHandler
)

// AuthResponse represents an API response
// from the auth server
type AuthResponse struct {
	StatusCode int
	Error      string
}

//AuthClient is an interface defined for making
// client requests to the auth server
type AuthClient interface {
	SignIn(string, string) AuthResponse
	Register(int, string, string) AuthResponse
}

// authHandler is an implementation of the AuthClient
// interface and handles authentication requests
type authHandler struct {
	authClient client.AuthClient
	httpClient *http.Client
}

// NewAuthClient creates a new auth client for Android
// It expects the auth server address as input
func NewAuthClient(authAddr string) AuthClient {
	log.Debugf("Creating new auth client with proxy addr %s", authAddr)
	httpClient, err := createHTTPClient()
	if err != nil {
		log.Error(err)
		return nil
	}
	authClient := client.New(authAddr, httpClient)
	handler = &authHandler{authClient, httpClient}
	return handler
}

func (h *authHandler) signIn(username, password string) (*api.AuthResponse, error) {
	params := &models.UserParams{
		Username: username,
		Password: password,
	}
	return h.authClient.SignIn(params)
}

func (h *authHandler) register(lanternUserID int, username,
	password string) (*api.AuthResponse, error) {
	params := &models.UserParams{
		LanternUserID: int64(lanternUserID),
		Username:      username,
		Password:      password,
	}
	return h.authClient.Register(params)
}

type authResponse struct {
	response *api.AuthResponse
}

func (ar *authResponse) Error() string {
	if ar != nil && ar.response != nil {
		return ar.response.ApiResponse.Error
	}
	return ""
}

func (ar *authResponse) StatusCode() int {
	if ar != nil && ar.response != nil {
		return ar.response.ApiResponse.StatusCode
	}
	return 0
}

// newAuthResponse conforms an API response type to
// a primitive type AuthResponse with the HTTP response status code
// and error message (if any)
func newAuthResponse(resp *api.AuthResponse) AuthResponse {
	var authResp AuthResponse
	if resp != nil && resp.ApiResponse != nil {
		authResp.StatusCode = resp.ApiResponse.StatusCode
		authResp.Error = resp.ApiResponse.Error
	}
	return authResp
}

// SignIn authenticates Lantern users with the authentication server
func (handler *authHandler) SignIn(username, password string) AuthResponse {
	resp, _ := handler.signIn(username, password)
	return newAuthResponse(resp)
}

// Register sends a new Lantern user create account request to the authentication server
func (handler *authHandler) Register(lanternUserID int, username, password string) AuthResponse {
	resp, _ := handler.register(lanternUserID, username, password)
	return newAuthResponse(resp)
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
