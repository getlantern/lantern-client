package pro

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient/defaultwebclient"
	"github.com/getlantern/lantern-client/internalsdk/protos"

	"github.com/go-resty/resty/v2"
	"github.com/shirou/gopsutil/host"
)

var (
	log        = golog.LoggerFor("webclient")
	httpClient = &http.Client{
		Transport: proxied.ParallelForIdempotent(),
		Timeout:   30 * time.Second,
	}
)

type proClient struct {
	userConfig UserConfig
	webclient  webclient.RESTClient
}

type ProClient interface {
	EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error)
	LinkCodeRequest(ctx context.Context) (*LinkCodeResponse, error)
	PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error)
	PaymentRedirect(ctx context.Context, params map[string]interface{}) (*PaymentRedirectResponse, error)
	Plans(ctx context.Context) (*PlansResponse, error)
	UserData(ctx context.Context) (*UserDataResponse, error)
}

type UserConfig interface {
	GetDeviceID() string
	GetLanguage() string
	GetToken() string
	GetUserID() int64
}

// NewProClient creates a new instance of ProClient
func NewProClient(uc UserConfig) ProClient {
	url := fmt.Sprintf("https://%s", common.ProAPIHost)
	client := webclient.NewRESTClient(defaultwebclient.SendToURL(httpClient, url, setUserHeaders(uc), nil))
	return &proClient{uc, client}
}

func setUserHeaders(uc UserConfig) func(client *resty.Client, req *resty.Request) error {
	return func(client *resty.Client, req *resty.Request) error {
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
	params := map[string]interface{}{
		"locale": c.userConfig.GetLanguage(),
	}
	return params
}

func (c *proClient) EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	params := map[string]interface{}{
		"email": email,
	}
	err := c.webclient.GetJSON(ctx, "/email-exists", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) PaymentRedirect(ctx context.Context, params map[string]interface{}) (*PaymentRedirectResponse, error) {
	var resp PaymentRedirectResponse
	err := c.webclient.GetJSON(ctx, "/payment-redirect", params, &resp)
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

func (c *proClient) UserData(ctx context.Context) (*UserDataResponse, error) {
	var resp UserDataResponse
	err := c.webclient.GetJSON(ctx, "/user-data", nil, &resp)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	return &resp, nil
}

func (c *proClient) LinkCodeRequest(ctx context.Context) (*LinkCodeResponse, error) {
	var resp LinkCodeResponse
	info, _ := host.Info()
	params := map[string]interface{}{
		"deviceName": info.Hostname,
		"locale":     c.userConfig.GetLanguage(),
	}
	err := c.webclient.PostFormReadingJSON(ctx, "/link-code-request", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}
