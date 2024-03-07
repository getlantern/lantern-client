package apimodels

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"time"

	"net/http"
	"net/url"

	"github.com/getlantern/android-lantern/internalsdk/protos"
	"github.com/getlantern/golog"
	"github.com/moul/http2curl"
	"google.golang.org/protobuf/proto"
)

const (
	publicBaseUrl  = "https://api.iantem.io/v1"
	baseUrl        = "https://api.getiantem.org"
	userGroup      = publicBaseUrl + "/users"
	userDetailUrl  = baseUrl + "/user-data"
	userCreateUrl  = baseUrl + "/user-create"
	userRecoverUrl = baseUrl + "/user-recover"
	plansV3Url     = baseUrl + "/plans-v3"
	purchaseUrl    = baseUrl + "/purchase"
	//Sign up urls
	signUpUrl         = userGroup + "/signup"
	signUpCompleteUrl = userGroup + "/signup/complete/email"
	signUpResendUrl   = userGroup + "/signup/resend/email"
	//Login up urls
	prepareUrl = userGroup + "/prepare"
	loginUrl   = userGroup + "/login"
	saltUrl    = userGroup + "/salt"
	//Recovery urls
	recoveryCompleteUrl       = userGroup + "/recovery/complete/email"
	recoveryStartUrl          = userGroup + "/recovery/start/email"
	recoveryValidateEmailtUrl = userGroup + "/recovery/validate/email"
	// Other Auth urls
	deleteUrl    = userGroup + "/delete"
	confirmedUrl = userGroup + "/confirmed"
	//Change Email
	changeEmailUrl         = userGroup + "/change_email"
	completeChangeEmailUrl = userGroup + "/change_email/complete/email"
	//Device Linking
	linkCodeRequestUrl  = baseUrl + "/link-code-request"
	linkCodeApproveUrl  = baseUrl + "/link-code-approve"
	userLinkRemoveUrl   = baseUrl + "/user-link-remove"
	userLinkRequestUrl  = baseUrl + "/user-link-request"
	userLinkValidateUrl = baseUrl + "/user-link-validate"
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
		Timeout: 15 * time.Second,
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

	curl, _ := http2curl.GetCurlCommand(req)
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
	err = json.Unmarshal(bodyStr, &userDetail)
	if err != nil {
		log.Errorf("Error decoding user details response body: %v", err)
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
	req.Header.Set(headerContentType, "application/json")
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
	log.Debugf("Purchase response %v with status code %d", resp.Body, resp.StatusCode)
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
	// Create URL values
	params := url.Values{}
	params.Add("email", email)
	encodedUrl := saltUrl + "?" + params.Encode()
	// Marshal the map to JSON
	req, err := http.NewRequest("GET", encodedUrl, nil)
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
	log.Debugf("Login response %v with status code %d", string(body), resp.StatusCode)

	defer resp.Body.Close()
	var loginResponse protos.LoginResponse
	if err := proto.Unmarshal(body, &loginResponse); err != nil {
		log.Errorf("Error unmarshalling response: ", err)
	}
	return &loginResponse, nil
}

//Recovery APIS

func StartRecoveryByEmail(body *protos.StartRecoveryByEmailRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(body)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", recoveryStartUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating recovery email request: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending recovery email request: %v", err)
		return false, err
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while sending recovery email %v", err)
	}

	return true, nil
}

func CompleteRecoveryByEmail(body *protos.CompleteRecoveryByEmailRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(body)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", recoveryCompleteUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating recovery email request: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending recovery email request: %v", err)
		return false, err
	}
	defer resp.Body.Close()
	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("Complete recovery email response %v with status code %d", string(bodyStr), resp.StatusCode)
	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("invalid_code error while sending recovery email %v", err)
	}
	return true, nil
}

func ValidateEmailRecovery(body *protos.ValidateRecoveryCodeRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(body)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", recoveryValidateEmailtUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating recovery email request: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")
	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending recovery email request: %v", err)
		return false, err
	}
	defer resp.Body.Close()
	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}

	log.Debugf("Validate recovery email response %v with status code %d", string(bodyStr), resp.StatusCode)
	var validateRecoveryCodeResponse protos.ValidateRecoveryCodeResponse
	if err := proto.Unmarshal(bodyStr, &validateRecoveryCodeResponse); err != nil {
		log.Errorf("Error unmarshalling response: ", err)
	}

	if !validateRecoveryCodeResponse.Valid {
		return false, log.Errorf("invalid_code error while sending recovery email %v", err)
	}
	return true, nil
}

// Chnage Email APIS
func ChangeEmail(body *protos.ChangeEmailRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(body)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", changeEmailUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating change email request: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending recovery email request: %v", err)
		return false, err
	}

	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("change email response %v with status code %d", string(bodyStr), resp.StatusCode)

	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while sending recovery email %v", err)
	}

	return true, nil
}
func CompleteChangeEmail(body *protos.CompleteChangeEmailRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(body)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", completeChangeEmailUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error complete change email request: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending recovery email request: %v", err)
		return false, err
	}

	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("complete change email response %v with status code %d", string(bodyStr), resp.StatusCode)

	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while sending recovery email %v", err)
	}
	return true, nil
}

// Other Auth APIS
func DeleteAccount(body *protos.DeleteUserRequest) (bool, error) {
	// Marshal the map to JSON
	requestBody, err := proto.Marshal(body)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return false, err
	}

	req, err := http.NewRequest("POST", deleteUrl, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating delete account request: %v", err)
		return false, err
	}
	req.Header.Set(headerContentType, "application/x-protobuf")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error sending delete account request: %v", err)
		return false, err
	}

	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("Delete Account response %v with status code %d", string(bodyStr), resp.StatusCode)

	if resp.StatusCode != http.StatusOK {
		return false, log.Errorf("error while sending recovery email %v", err)
	}
	return true, nil
}

//Deivce Linking

func LinkCodeRequest(data map[string]string, deviceId string, userId string, token string) (*LinkRequestResult, error) {
	log.Debugf("LinkCodeRequest body %v", data)
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return nil, err
	}

	log.Debugf("Encoded body %v", body)
	// Create a new request
	req, err := http.NewRequest("POST", linkCodeRequestUrl, body)
	if err != nil {
		log.Errorf("Error creating new LinkCodeRequest: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error while linkCode request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()
	log.Debugf("LinkCodeRequest response %v with status code %d", resp.Body, resp.StatusCode)
	var linkResponse LinkRequestResult
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&linkResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &linkResponse, nil
}

func UserRecover(data map[string]string, deviceId string) (*UserRecovery, error) {
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return nil, err
	}
	log.Debugf("User Recovery body %v", body)
	// Create a new request
	req, err := http.NewRequest("POST", userRecoverUrl, body)
	if err != nil {
		log.Errorf("Error creating new User Recovery: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error while UserRecovery request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()
	var userRecovery UserRecovery
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userRecovery); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	if userRecovery.Status != "ok" {
		return nil, log.Errorf("recovery_not_found %v", err)
	}
	return &userRecovery, nil
}

func LinkCodeApprove(data map[string]string, userId string, token string) (bool, error) {
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return false, err
	}
	req, err := http.NewRequest("POST", linkCodeApproveUrl, body)
	if err != nil {
		log.Errorf("Error creating linkcode approve request: %v", err)
		return false, err
	}

	// Add headers
	req.Header.Set(headerProToken, token)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error while UserRecovery request: %v", err)
		return false, err
	}
	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("LinkCode Arppove response %v with status code %d", string(bodyStr), resp.StatusCode)
	var apiResponse ApiResponse
	err = json.Unmarshal(bodyStr, &apiResponse)
	if err != nil {
		return false, log.Errorf("error unmarshaling response: %v", err)
	}
	if apiResponse.ErrorId != "" {
		return false, log.Errorf("%v", apiResponse.ErrorId)
	}
	return true, nil
}

func DeviceUnlink(data map[string]string, userId string, deviceId string, token string) (bool, error) {
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return false, err
	}
	req, err := http.NewRequest("POST", userLinkRemoveUrl, body)
	if err != nil {
		log.Errorf("Error creating linkcode approve request: %v", err)
		return false, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerUserId, userId)
	req.Header.Set(headerProToken, token)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error while UserRecovery request: %v", err)
		return false, err
	}
	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("LinkCode Arppove response %v with status code %d", string(bodyStr), resp.StatusCode)
	var apiResponse ApiResponse
	err = json.Unmarshal(bodyStr, &apiResponse)
	if err != nil {
		return false, log.Errorf("error unmarshaling response: %v", err)
	}
	if apiResponse.ErrorId != "" {
		return false, log.Errorf("%v", apiResponse.ErrorId)
	}
	return true, nil
}

// RequestRecoveryEmail requests an account recovery email for linking to an existing pro account
func UserLinkRequest(data map[string]string, deviceId string) (bool, error) {
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return false, err
	}
	req, err := http.NewRequest("POST", userLinkRequestUrl, body)
	if err != nil {
		log.Errorf("Error creating userlink request approve request: %v", err)
		return false, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error while UserLinkRequest request: %v", err)
		return false, err
	}
	defer resp.Body.Close()

	bodyStr, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err
	}
	log.Debugf("UserLinkRequest response %v with status code %d", string(bodyStr), resp.StatusCode)
	var apiResponse ApiResponse
	err = json.Unmarshal(bodyStr, &apiResponse)
	if err != nil {
		return false, log.Errorf("error unmarshaling response: %v", err)
	}
	if apiResponse.ErrorId != "" {
		return false, log.Errorf("%v", apiResponse.ErrorId)
	}
	return true, nil
}

// ValidateRecoveryCode validates the given recovery code and finishes linking the device, returning the user_id and pro_token for the account.
func UserLinkValidate(data map[string]string, deviceId string) (*UserRecovery, error) {
	body, err := createJsonBody(data)
	if err != nil {
		log.Errorf("Error while creating json body")
		return nil, err
	}
	log.Debugf("User Link validate body %v", body)
	// Create a new request
	req, err := http.NewRequest("POST", userLinkValidateUrl, body)
	if err != nil {
		log.Errorf("Error creating User Link validate: %v", err)
		return nil, err
	}

	// Add headers
	req.Header.Set(headerDeviceId, deviceId)
	req.Header.Set(headerContentType, "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Errorf("Error while UserLinkValiate request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()
	var userRecovery UserRecovery
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userRecovery); err != nil {
		log.Errorf("invalid_code Error decoding response body: %v", err)
		return nil, err
	}
	if userRecovery.Status != "ok" {
		return nil, log.Errorf("recovery_not_found %v", err)
	}
	return &userRecovery, nil
}

// Utils methods convert json body
func createJsonBody(data map[string]string) (*bytes.Buffer, error) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	return bytes.NewBuffer(jsonData), nil
}
