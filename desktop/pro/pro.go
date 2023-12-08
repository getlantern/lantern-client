package pro

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strconv"
	"strings"

	"github.com/shirou/gopsutil/v3/host"

	"github.com/getlantern/golog"
	"github.com/getlantern/flashlight/v7/pro"
	"github.com/getlantern/lantern-client/desktop/app"
)

const (
	baseUrl       = "https://api.getiantem.org"
	linkCodeUrl = baseUrl + "/link-code-request"
	paymentMethodsUrl = baseUrl + "/plans-v3"
	plansUrl = baseUrl + "/plans"
	userCreateUrl = baseUrl + "/user-create"
	userDetailsUrl = baseUrl + "/user-data"
)

var (
	log = golog.LoggerFor("lantern-client.desktop")
)

type ProClient struct {
	*http.Client
	settings *app.Settings
}

func New(settings *app.Settings) *ProClient {
	return &ProClient{
		Client: pro.GetHTTPClient(),
		settings: settings,
	}
}

func (pc *ProClient) setHeaders(req *http.Request) {
	deviceID, userID, token := pc.userHeaders()
	// Add headers
	req.Header.Set("X-Lantern-Device-Id", deviceID)
	req.Header.Set("X-Lantern-User-Id", userID)
	req.Header.Set("X-Lantern-Pro-Token", token)
}

func (pc *ProClient) userHeaders() (string, string, string) {
	uID, deviceID, token := pc.settings.GetUserID(), pc.settings.GetDeviceID(), pc.settings.GetToken()
	userID := strconv.FormatInt(uID, 10)
	return deviceID, userID, token
}

func (pc *ProClient) newRequest(method, url string) (*http.Request, error) {
	// Create a new request
	req, err := http.NewRequest(method, url, nil)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return nil, err
	}

	pc.setHeaders(req)
	return req, nil
}

func (pc *ProClient) POST(url string, body io.Reader, isJson bool) (*http.Response, error) {
	// Create a new request
	req, err := http.NewRequest(http.MethodPost, url, body)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return nil, err
	}
	if isJson {
		req.Header.Set("Content-Type", "application/json")
	} else {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}
	pc.setHeaders(req)

	// Send the request
	resp, err := pc.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	return resp, nil
}

func (pc *ProClient) LinkCodeRequest() (*LinkCodeResponse, error) {
	info, _ := host.Info()
	jsonBody := []byte(fmt.Sprintf(`{"deviceName": "%s"}`, info.Hostname))
	resp, err := pc.POST(linkCodeUrl, bytes.NewReader(jsonBody), true)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	// Read the response body
	var linkCodeResponse LinkCodeResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&linkCodeResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}
	return &linkCodeResponse, nil

}

func (pc *ProClient) Plans() (*PlansResponse, error) {
	// Create a new request
	req, err := pc.newRequest("GET", plansUrl)
	if err != nil {
		return nil, err
	}

	// Send the request
	resp, err := pc.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

   	respDump, err := httputil.DumpResponse(resp, true)
    if err != nil {
        return nil, err
    }
    log.Debugf("RESPONSE:%s", string(respDump))

	// Read the response body
	var plansResponse PlansResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&plansResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}

	return &plansResponse, nil
}

func (pc *ProClient) PaymentMethods() (*PaymentMethodsResponse, error) {
	// Create a new request
	req, err := pc.newRequest("GET", paymentMethodsUrl)
	if err != nil {
		return nil, err
	}

	// Send the request
	resp, err := pc.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	// Read the response body
	var paymentMethodsResponse PaymentMethodsResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&paymentMethodsResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}

	b, _ := json.Marshal(&paymentMethodsResponse)

	log.Debugf("Response is %v", string(b))
	return &paymentMethodsResponse, nil
}

func (pc *ProClient) UserCreate(lang string) (*UserDetailsResponse, error) {
	body := strings.NewReader(url.Values{"locale": {lang}}.Encode())
	resp, err := pc.POST(userCreateUrl, body, false)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var userDetailsResponse UserDetailsResponse
	if err := json.NewDecoder(resp.Body).Decode(&userDetailsResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return nil, err
	}

	return &userDetailsResponse, nil
}

func (pc *ProClient) UserData() (*UserDetailsResponse, error) {
	// Create a new request
	req, err := pc.newRequest("GET", userDetailsUrl)
	if err != nil {
		return nil, err
	}

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
