package pro

import (
	"encoding/json"
	"net/http"

	"github.com/getlantern/golog"
	"github.com/getlantern/flashlight/v7/pro"
)

const (
	baseUrl       = "https://api.getiantem.org"
	plansUrl = baseUrl + "/plans"
	userDetailsUrl = baseUrl + "/user-data"
)

var (
	log = golog.LoggerFor("lantern-client.desktop")
)

type ProClient struct {
	*http.Client
}

func New() *ProClient {
	return &ProClient{
		Client: pro.GetHTTPClient(),
	}
}

func setHeaders(req *http.Request, deviceId, userId, token string) {
	// Add headers
	req.Header.Set("X-Lantern-Device-Id", deviceId)
	req.Header.Set("X-Lantern-User-Id", userId)
	req.Header.Set("X-Lantern-Pro-Token", token)
}

func (pc *ProClient) Plans(deviceId, userId, token string) (*PlansResponse, error) {
		// Create a new request
	req, err := http.NewRequest("GET", plansUrl, nil)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return nil, err
	}

	setHeaders(req, deviceId, userId, token)

	// Send the request
	resp, err := pc.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	// Read the response body
	var plansResponse PlansResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&plansResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}

	return &plansResponse, nil
}

func (pc *ProClient) UserData(deviceId, userId, token string) (*UserDetailsResponse, error) {
		// Create a new request
	req, err := http.NewRequest("GET", userDetailsUrl, nil)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return nil, err
	}

	setHeaders(req, deviceId, userId, token)

	// Send the request
	resp, err := pc.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	// Read the response body
	var userDetailsResponse UserDetailsResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userDetailsResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}

	return &userDetailsResponse, nil
}
