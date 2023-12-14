package apimodels

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"time"

	"net/http"
	"net/http/httputil"
	"time"

	"github.com/getlantern/android-lantern/internalsdk/protos"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
	"google.golang.org/protobuf/proto"
)

const (
	publicBaseUrl = "https://api.iantem.io/v1"
	baseUrl       = "https://api.getiantem.org"
	userGroup     = publicBaseUrl + "/users"
	userDetailUrl = baseUrl + "/user-data"
	userCreateUrl = baseUrl + "/user-create"
	plansV3Url    = baseUrl + "/plans-v3"
	purchaseUrl   = baseUrl + "/purchase"
	//Sign up urls
	signUpUrl         = userGroup + "/signup"
	signUpCompleteUrl = userGroup + "/signup/complete/email"
	signUpResendUrl   = userGroup + "/signup/resend/email"
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
	confirmedUrl   = userGroup + "/confirmed"
)

const (
	headerDeviceId    = "X-Lantern-Device-Id"
	headerUserId      = "X-Lantern-User-Id"
	headerProToken    = "X-Lantern-Pro-Token"
	headerContentType = "Content-Type"
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
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
	req.Header.Set(headerContentType, "application/json")

	curl, _ := RequestToCurl(req)
	log.Debugf("Curl command: %s", curl)

	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	log.Debugf("User details response %v with status code %d", string(bodyStr), resp.StatusCode)
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
	requestBody, err := createJsonBody(requestBodyMap)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return nil, err
	}

	// Create a new request
	req, err := http.NewRequest("POST", userCreateUrl, requestBody)
	if err != nil {
		log.Errorf("Error creating new request: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
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

	// Send the request
	resp, err := httpClient.Do(req)
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

func PurchaseRequest(data map[string]string, deviceId string, userId string, token string) (*PurchaseResponse, error) {
	log.Debugf("purchase request body %v", data)
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return nil, err
	}

	log.Debugf("Encoded body %v", body)
	// Create a new request
	req, err := http.NewRequest("POST", purchaseUrl, body)
	if err != nil {
		log.Errorf("Error creating new request: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending puchase request: %v", err)
		return nil, err
	}

	defer resp.Body.Close()

	var purchase PurchaseResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&purchase); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &purchase, nil
}

func IsEmailVerified(email string, token string) (bool, error) {
	fullUrl := confirmedUrl + "?email=" + email + "&token=" + token
	// Marshal the map to JSON

	req, err := http.NewRequest("GET", fullUrl, nil)
	if err != nil {
		log.Errorf("Error getting user salt: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return false, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}

	log.Debugf("Signup response %v with status code %d", string(body), resp.StatusCode)
	if resp.StatusCode != http.StatusOK {
		return false, nil
	}
	return true, nil
}

///Signup APIS

func Signup(signupBody *protos.SignupRequest, userId string, token string) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(signupBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", signUpUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating signup request: %v", err)
		return false, err
	}

	// Add headers
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
	req.Header.Set(headerContentType, "application/x-protobuf")
	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return false, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}

	log.Debugf("Signup response %v with status code %d", string(body), resp.StatusCode)
	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while sign up %v", err)
	}
	return true, nil
}

func SignupEmailResendCode(signupEmailResendBody *protos.SignupEmailResendRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(signupEmailResendBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}
	log.Debugf("Request body:SignupEmailResendCode-> %s", requestBody)

	req, err := http.NewRequest("POST", signUpResendUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error email resend request request: %v", err)
		return false, err
	}

	// Add headers
	req.Header.Set(headerContentType, "application/x-protobuf")

	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return false, err
	}
	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("Signup email resend response %v with status code %d", string(bodyStr), resp.StatusCode)

	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while email resend %v", err)
	}
	return true, nil
}

func SignupEmailConfirmation(signupEmailResendBody *protos.ConfirmSignupRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(signupEmailResendBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", signUpCompleteUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating signup request: %v", err)
		return false, err
	}

	// Add headers
	req.Header.Set(headerContentType, "application/x-protobuf")
	log.Debugf("Headers set")

	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return false, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while sign up %v", err)
	}
	return true, nil
}

func GetSalt(email string) (*protos.GetSaltResponse, error) {
	fullUrl := saltUrl + "?email=" + email
	// Marshal the map to JSON

	req, err := http.NewRequest("GET", fullUrl, nil)
	if err != nil {
		log.Errorf("Error getting user salt: %v", err)
		return nil, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	// Send the request
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return nil, err
	}
	log.Debugf("Salt response %v with status code %d", string(body), resp.StatusCode)

	var slatResponse protos.GetSaltResponse
	if err := proto.Unmarshal(body, &slatResponse); err != nil {
		log.Errorf("Error unmarshalling response: ", err)
	}
	return &slatResponse, nil
}

// Login APIS
func LoginPrepare(prepareBody *protos.PrepareRequest) (*protos.PrepareResponse, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(prepareBody)
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
	req.Header.Set(headerContentType, "application/x-protobuf")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending login prepare request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()
	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return nil, err
	}
	log.Debugf("Login prepare response %v with status code %d", string(body), resp.StatusCode)

	//Todo change message for StatusServiceUnavailable
	if resp.StatusCode == http.StatusForbidden || resp.StatusCode == http.StatusServiceUnavailable {
		return nil, log.Errorf("user_not_found %v", err)
	}

	var prepareResponse protos.PrepareResponse
	if err := proto.Unmarshal(body, &prepareResponse); err != nil {
		log.Errorf("Error unmarshalling response: ", err)
	}
	return &prepareResponse, nil
}

func Login(loginBody *protos.LoginRequest) (*protos.LoginResponse, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(loginBody)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return nil, err
	}

	req, err := http.NewRequest("POST", loginUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating login request: %v", err)
		return nil, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending login prepare request: %v", err)
		return nil, err
	}
	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return nil, err
	}

	defer resp.Body.Close()

	var loginResponse protos.LoginResponse
	if err := proto.Unmarshal(body, &loginResponse); err != nil {
		log.Errorf("Error unmarshalling response: ", err)
	}

	return &loginResponse, nil
}

// Utils methods convert json body
func createJsonBody(data map[string]string) (*bytes.Buffer, error) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	return bytes.NewBuffer(jsonData), nil
}
