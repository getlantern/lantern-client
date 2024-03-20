package pro

import (
	"context"
	"fmt"
	"strconv"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/pro/client"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient/defaultwebclient"

	"github.com/go-resty/resty/v2"
	"github.com/shirou/gopsutil/host"
)

var (
	log = golog.LoggerFor("webclient")
)

type proClient struct {
	userConfig UserConfig
	webclient  webclient.RESTClient
}

type ProClient interface {
	EmailExists(ctx context.Context, email string) (*client.BaseResponse, error)
	LinkCodeRequest(ctx context.Context) (*client.LinkCodeResponse, error)
	PaymentMethods(ctx context.Context) (*client.PaymentMethodsResponse, error)
	PaymentRedirect(ctx context.Context, params map[string]interface{}) (*client.PaymentRedirectResponse, error)
	Plans(ctx context.Context) (*client.PlansResponse, error)
	UserData(ctx context.Context) (*client.UserDataResponse, error)
}

type UserConfig interface {
	GetDeviceID() string
	GetLanguage() string
	GetToken() string
	GetUserID() int64
}

// Construct a REST client using the given SendRequest function
func NewProClient(uc UserConfig) ProClient {
	url := fmt.Sprintf("https://%s", common.ProAPIHost)
	client := webclient.NewRESTClient(defaultwebclient.SendToURL(url, func(client *resty.Client, req *resty.Request) error {
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
	}, nil))
	return &proClient{uc, client}
}

func (c *proClient) defaultParams() map[string]interface{} {
	params := map[string]interface{}{
		"locale": c.userConfig.GetLanguage(),
	}
	return params
}

func (c *proClient) EmailExists(ctx context.Context, email string) (*client.BaseResponse, error) {
	var resp client.BaseResponse
	params := map[string]interface{}{
		"email": email,
	}
	err := c.webclient.GetJSON(ctx, "/email-exists", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) PaymentRedirect(ctx context.Context, params map[string]interface{}) (*client.PaymentRedirectResponse, error) {
	var resp client.PaymentRedirectResponse
	err := c.webclient.GetJSON(ctx, "/payment-redirect", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) PaymentMethods(ctx context.Context) (*client.PaymentMethodsResponse, error) {
	var resp client.PaymentMethodsResponse
	err := c.webclient.GetJSON(ctx, "/plans-v3", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) Plans(ctx context.Context) (*client.PlansResponse, error) {
	var resp client.PlansResponse
	err := c.webclient.GetJSON(ctx, "/plans", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) UserData(ctx context.Context) (*client.UserDataResponse, error) {
	var resp client.UserDataResponse
	err := c.webclient.GetJSON(ctx, "/user-data", nil, &resp)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	return &resp, nil
}

func (c *proClient) LinkCodeRequest(ctx context.Context) (*client.LinkCodeResponse, error) {
	var resp client.LinkCodeResponse
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
