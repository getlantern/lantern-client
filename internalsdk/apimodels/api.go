package apimodels

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httputil"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
)

const (
	baseUrl       = "https://api.getiantem.org"
	userDetailUrl = baseUrl + "/user-data"
	userCreateUrl = baseUrl + "/user-create"
)

var (
	log        = golog.LoggerFor("lantern-internalsdk-http")
	httpClient = &http.Client{
		Transport: proxied.ParallelForIdempotent(),
		Timeout:   30 * time.Second,
	}
)

func FechUserDetail(deviceId string, userId string, token string) (*UserDetailResponse, error) {
	req, err := http.NewRequest("GET", userDetailUrl, nil)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set("X-Lantern-Device-Id", deviceId)
	req.Header.Set("X-Lantern-User-Id", userId)
	req.Header.Set("X-Lantern-Pro-Token", token)
	log.Debugf("Headers set")

	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	// Read the response body
	var userDetail UserDetailResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userDetail); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}

	return &userDetail, nil
}

func UserCreate(deviceId string, local string) (*UserResponse, error) {
	requestBodyMap := map[string]string{
		"locale": local,
	}

	// Marshal the map to JSON
	requestBody, err := json.Marshal(requestBodyMap)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return nil, err
	}

	// Create a new request
	req, err := http.NewRequest("POST", userCreateUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating new request: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set("X-Lantern-Device-Id", deviceId)
	log.Debugf("Headers set")

	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()
	var userResponse UserResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &userResponse, nil
}

// ToCurlCommand converts an http.Request into a cURL command string
func ToCurlCommand(req *http.Request) (string, error) {
	_, err := httputil.DumpRequestOut(req, true)
	if err != nil {
		return "", err
	}

	curl := "curl -X " + req.Method
	for header, values := range req.Header {
		for _, value := range values {
			curl += fmt.Sprintf(" -H '%s: %s'", header, value)
		}
	}

	if req.Body != nil {
		bodyBytes, err := ioutil.ReadAll(req.Body)
		if err != nil {
			return "", err
		}
		// Reset the request body to the original io.Reader
		req.Body = ioutil.NopCloser(bytes.NewBuffer(bodyBytes))

		curl += fmt.Sprintf(" -d '%s'", string(bodyBytes))
	}

	curl += " " + req.URL.String()

	return curl, nil
}
