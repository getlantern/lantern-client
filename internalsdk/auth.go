package internalsdk

import (
	"fmt"
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

var (
	handler *authHandler
)

//AuthClient is an interface defined for making
// client requests to the auth server
type AuthClient interface {
	SignIn(string, string) *api.AuthResponse
	Register(int64, string, string) *api.AuthResponse
}

// authHandler is an implementation of the AuthClient
// interface and handles authentication requests
type authHandler struct {
	authClient client.AuthClient
	httpClient *http.Client
}

// NewAuthClient creates a new auth client for Android
// It expects the auth server address as input
func NewAuthClient(authAddr string) error {
	log.Debugf("Creating new auth client with proxy addr %s", authAddr)
	httpClient, err := createHTTPClient()
	if err != nil {
		return err
	}
	authClient := client.New(authAddr, httpClient)
	handler = &authHandler{authClient, httpClient}
	return nil
}

// checkInit returns nil if the auth client has
// been initialized; otherwise, it returns the error response
func checkInit() *api.AuthResponse {
	if handler == nil {
		err := fmt.Errorf("Auth client hasn't been initialized")
		// return error auth response
		return api.NewAuthResponse(http.StatusBadRequest, err)
	}
	return nil
}

func (h *authHandler) signIn(username, password string) *api.AuthResponse {
	params := &models.UserParams{
		Username: username,
		Password: password,
	}
	resp, err := h.authClient.SignIn(params)
	if err != nil {
		log.Errorf("Sign in error: %v", err)
	}
	return resp
}

func (h *authHandler) register(lanternUserID int64, username, password string) *api.AuthResponse {
	params := &models.UserParams{
		LanternUserID: lanternUserID,
		Username:      username,
		Password:      password,
	}
	resp, err := h.authClient.Register(params)
	if err != nil {
		log.Errorf("Create account error: %v", err)
	}
	return resp
}

// SignIn authenticates Lantern users with the authentication server
func SignIn(username, password string) *api.AuthResponse {
	resp := checkInit()
	if resp != nil {
		return resp
	}
	return handler.signIn(username, password)
}

// Register sends a new Lantern user create account request to the authentication server
func Register(lanternUserID int64, username, password string) *api.AuthResponse {
	resp := checkInit()
	if resp != nil {
		return resp
	}
	return handler.register(lanternUserID, username, password)
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
