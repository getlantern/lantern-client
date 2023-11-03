package apimodels

import (
	"bytes"
	"encoding/json"
	"net/http"

	"github.com/getlantern/golog"
)

var session SessionModel

const (
	baseUrl       = "https://api.getiantem.org"
	userDetailUrl = baseUrl + "/user-data"
	userCreateUrl = baseUrl + "/user-create"
	plansV3Url    = baseUrl + "/plans-v3"
)

const (
	headerDeviceId = "X-Lantern-Device-Id"
	headerUserId   = "X-Lantern-User-Id"
	headerProToken = "X-Lantern-Pro-Token"
)

var (
	log = golog.LoggerFor("lantern-internalsdk-http")
	// proHtttpClient = pro.GetHTTPClient()
)

func FechUserDetail(deviceId string, userId string, token string) (*UserDetailResponse, error) {
	// Create a new request
	req, err := http.NewRequest("GET", userDetailUrl, nil)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
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
	req.Header.Set(headerDeviceId, deviceId)
	log.Debugf("Headers set")
	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
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

func PlansV3(deviceId string, userId string, local string, token string, countryCode string) (*PlansResponse, error) {
	req, err := http.NewRequest("GET", plansV3Url, nil)
	if err != nil {
		log.Errorf("Error creating plans request: %v", err)
		return nil, err
	}
	//Add query params
	q := req.URL.Query()
	q.Add("locale", local)
	q.Add("countrycode", countryCode)
	req.URL.RawQuery = q.Encode()

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
	log.Debugf("Plans Headers set")
	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("Error sending plans request: %v", err)
		return nil, err
	}

	defer resp.Body.Close()

	var plans PlansResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&plans); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &plans, nil
}

// func PurchaseRequest(planId string, email string, token string, paymentProvider string, deviceName string) error {
func PurchaseRequest(session *SessionModel, paymentProvider string) error {
	base := session.baseModel
	// data := map[string]interface{}{
	// 	"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
	// 	"provider":       paymentProvider,
	// 	"email":          email,
	// 	"plan":           planId,
	// 	"currency":       "usd",
	// 	"deviceName":     deviceName,
	// }

	// switch paymentProvider {
	// case PaymentProviderResellerCode:
	// 	data["resellerCode"] = resellerCode

	// }

	// body, err := createJsonBody(data)
	// if err != nil {
	// 	log.Errorf("Error while creating json body")
	// 	return err
	// }
	return nil
}

// Utils methods convert json body
func createJsonBody(data map[string]interface{}) (*bytes.Buffer, error) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	return bytes.NewBuffer(jsonData), nil
}
