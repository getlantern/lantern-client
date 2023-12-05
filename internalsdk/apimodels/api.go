package apimodels

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math/big"
	"net/http"
	"net/http/httputil"
	"strings"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
)

// https://api.iantem.io/v1/users/salt
const (
	publicBaseUrl = "https://api.iantem.io/v1"
	baseUrl       = "https://api.getiantem.org"
	userGroup     = publicBaseUrl + "/users"
	userDetailUrl = baseUrl + "/user-data"
	userCreateUrl = baseUrl + "/user-create"
	//Sign up urls
	signUpUrl         = userGroup + "/signup"
	signUpCompleteUrl = userGroup + "/signup/complete/email"
	//Login up urls
	prepareUrl = userGroup + "/prepare"
	loginUrl   = userGroup + "/login"
	saltUrl    = userGroup + "/salt"
	//Recovery urls
	recoveryCompleteUrl = userGroup + "/recovery/complete/email"
	recoveryStartUrl    = userGroup + "/recovery/start/email"
	// Other Auth urls
	deleteUrl      = userGroup + "/delete"
	changeEmailUrl = userGroup + "/change_email"
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

func Signup(signupBody map[string]interface{}, userId string, token string) (*UserDetailResponse, error) {
	// Marshal the map to JSON
	requestBody, err := json.Marshal(signupBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return nil, err
	}

	req, err := http.NewRequest("POST", signUpUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating signup request: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set("X-Lantern-User-Id", userId)
	req.Header.Set("X-Lantern-Pro-Token", token)
	log.Debugf("Headers set")

	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
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

func GetSalt(userName string) (*[]int, error) {
	fullUrl := saltUrl + "?username=" + userName
	// Marshal the map to JSON

	req, err := http.NewRequest("GET", fullUrl, nil)
	if err != nil {
		log.Errorf("Error getting user salt: %v", err)
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return nil, err
	}

	bodyStr := strings.TrimSpace(string(body))
	log.Debugf("Response body:GetSalt-> %s", bodyStr)
	salt, err := StringToIntSlice(bodyStr)
	if err != nil {
		return nil, err
	}
	return &salt, nil
}

func LoginPrepare(prepareBody map[string]interface{}) (*big.Int, error) {
	// Marshal the map to JSON
	requestBody, err := json.Marshal(prepareBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return nil, err
	}
	log.Debugf("Request body:LoginPrepare-> %s", requestBody)
	req, err := http.NewRequest("POST", prepareUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating signup request: %v", err)
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("Error sending login prepare request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()
	// Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return nil, err
	}
	// Print the response body
	bodyStr := strings.TrimSpace(string(body))
	log.Debugf("Response body:LoginPrepare-> %s", bodyStr)

	var srpB SrpB
	if err := json.NewDecoder(resp.Body).Decode(&srpB); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &srpB.SrpB, nil
}

func Login(loginBody map[string]interface{}) (*big.Int, error) {
	// Marshal the map to JSON
	requestBody, err := json.Marshal(loginBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return nil, err
	}

	req, err := http.NewRequest("POST", loginUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating login request: %v", err)
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("Error sending login prepare request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	var srpB SrpB
	if err := json.NewDecoder(resp.Body).Decode(&srpB); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &srpB.SrpB, nil
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
