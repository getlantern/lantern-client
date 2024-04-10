package pro

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient/defaultwebclient"
	"github.com/getlantern/lantern-client/internalsdk/protos"

	"github.com/go-resty/resty/v2"
	"github.com/shirou/gopsutil/host"
)

var (
	log = golog.LoggerFor("webclient")
)

type proClient struct {
	settings  *settings.Settings
	webclient webclient.RESTClient
}

type Opts struct {
	// HttpClient represents an http.Client that should be used by the resty client
	HttpClient *http.Client
	// Settings are the user settings that the pro client is configured with
	Settings *settings.Settings
}

type ProClient interface {
	DeviceRemove(ctx context.Context, deviceId string) (*LinkResponse, error)
	EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error)
	LinkCodeApprove(ctx context.Context, code string) (*protos.BaseResponse, error)
	LinkCodeRequest(ctx context.Context) (*LinkCodeResponse, error)
	PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error)
	PaymentRedirect(ctx context.Context, req *protos.PaymentRedirectRequest) (*PaymentRedirectResponse, error)
	Plans(ctx context.Context) (*PlansResponse, error)
	RedeemResellerCode(ctx context.Context, req *protos.RedeemResellerCodeRequest) (*protos.BaseResponse, error)
	UserCreate(ctx context.Context) (*UserDataResponse, error)
	UserData(ctx context.Context) (*UserDataResponse, error)
}

// NewClient creates a new instance of ProClient
func NewClient(baseURL string, opts *Opts) ProClient {
	httpClient := opts.HttpClient
	if httpClient == nil {
		httpClient = &http.Client{}
	}

	client := webclient.NewRESTClient(defaultwebclient.SendToURL(httpClient, baseURL, setUserHeaders(opts.Settings), nil))
	return &proClient{opts.Settings, client}
}

func userConfig(settings *settings.Settings) *common.UserConfigData {
	userID, deviceID, token := settings.GetUserID(), settings.GetDeviceID(), settings.GetToken()
	return common.NewUserConfigData(
		common.DefaultAppName,
		deviceID,
		userID,
		token,
		nil,
		settings.GetLanguage(),
	)
}

func setUserHeaders(settings *settings.Settings) func(client *resty.Client, req *resty.Request) error {
	return func(client *resty.Client, req *resty.Request) error {

		uc := userConfig(settings)

		req.Header.Set("Referer", "http://localhost:37457/")
		req.Header.Set("Access-Control-Allow-Headers", strings.Join([]string{
			common.DeviceIdHeader,
			common.ProTokenHeader,
			common.UserIdHeader,
		}, ", "))
		req.Header.Set(common.LocaleHeader, uc.GetLanguage())

		if req.Header.Get(common.DeviceIdHeader) == "" {
			if deviceID := uc.GetDeviceID(); deviceID != "" {
				req.Header.Set(common.DeviceIdHeader, deviceID)
			}
		}

		if req.Header.Get(common.ProTokenHeader) == "" {
			if token := uc.GetToken(); token != "" {
				req.Header.Set(common.ProTokenHeader, token)
			}
		}
		if req.Header.Get(common.UserIdHeader) == "" {
			if userID := uc.GetUserID(); userID != 0 {
				req.Header.Set(common.UserIdHeader, strconv.FormatInt(userID, 10))
			}
		}

		return nil
	}
}

func (c *proClient) defaultParams() map[string]interface{} {
	uc := userConfig(c.settings)
	params := map[string]interface{}{
		"locale": uc.GetLanguage(),
	}
	return params
}

func (c *proClient) EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	err := c.webclient.GetJSON(ctx, "/email-exists", map[string]interface{}{
		"email": email,
	}, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) PaymentRedirect(ctx context.Context, req *protos.PaymentRedirectRequest) (*PaymentRedirectResponse, error) {
	var resp PaymentRedirectResponse
	uc := userConfig(c.settings)
	req.Locale = uc.GetLanguage()
	err := c.webclient.GetJSON(ctx, "/payment-redirect", req, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.webclient.GetJSON(ctx, "/plans-v3", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	b, _ := json.Marshal(resp)
	log.Debugf("Response is %v", string(b))
	return &resp, nil
}

func (c *proClient) Plans(ctx context.Context) (*PlansResponse, error) {
	var resp PlansResponse
	err := c.webclient.GetJSON(ctx, "/plans", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) UserCreate(ctx context.Context) (*UserDataResponse, error) {
	var resp UserDataResponse
	err := c.webclient.PostFormReadingJSON(ctx, "/user-create", nil, &resp)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	return &resp, nil
}

func (c *proClient) UserData(ctx context.Context) (*UserDataResponse, error) {
	var resp UserDataResponse
	err := c.webclient.GetJSON(ctx, "/user-data", nil, &resp)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	return &resp, nil
}

// RedeemResellerCode redeems a reseller code for the given user
func (c *proClient) RedeemResellerCode(ctx context.Context, req *protos.RedeemResellerCodeRequest) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	if err := c.webclient.PostFormReadingJSON(ctx, "/link-code-request", req, &resp); err != nil {
		log.Errorf("Failed to redeem reseller code: %v", err)
		return nil, err
	}

	return &resp, nil
}

// DeviceRemove removes the device with the given ID from a user's Pro account
func (c *proClient) DeviceRemove(ctx context.Context, deviceId string) (*LinkResponse, error) {
	var resp LinkResponse
	params := c.defaultParams()
	params["deviceID"] = deviceId
	err := c.webclient.PostJSONReadingJSON(ctx, "/user-link-remove", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) LinkCodeApprove(ctx context.Context, code string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	params := c.defaultParams()
	params["code"] = code
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-approve", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) LinkCodeRequest(ctx context.Context) (*LinkCodeResponse, error) {
	var resp LinkCodeResponse
	info, _ := host.Info()
	uc := userConfig(c.settings)
	params := map[string]interface{}{
		"deviceName": info.Hostname,
		"locale":     uc.GetLanguage(),
	}
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-request", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}
