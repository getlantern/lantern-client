package pro

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"github.com/go-resty/resty/v2"

	"github.com/leekchan/accounting"
	"github.com/shopspring/decimal"
	"google.golang.org/protobuf/encoding/protojson"
)

var (
	log                  = golog.LoggerFor("proclient")
	errMissingDeviceName = errors.New("Missing device name")
)

type proClient struct {
	webclient.RESTClient
	backoffRunner *backoffRunner
	userConfig    func() common.UserConfig
}

type Client interface {
	UpdateUserData(ctx context.Context, session ClientSession) (*protos.User, error)
}

type ProClient interface {
	webclient.RESTClient
	Client
	EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error)
	PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error)
	PaymentMethodsV4(ctx context.Context) (*PaymentMethodsResponse, error)
	PaymentRedirect(ctx context.Context, req *protos.PaymentRedirectRequest) (*PaymentRedirectResponse, error)
	Plans(ctx context.Context) (*PlansResponse, error)
	PollUserData(ctx context.Context, session ClientSession, maxElapsedTime time.Duration, client Client)
	RedeemResellerCode(ctx context.Context, req *protos.RedeemResellerCodeRequest) (*protos.BaseResponse, error)
	RetryCreateUser(ctx context.Context, ss ClientSession, maxElapsedTime time.Duration)
	UserCreate(ctx context.Context) (*UserDataResponse, error)
	UserData(ctx context.Context) (*UserDataResponse, error)
	PurchaseRequest(ctx context.Context, data map[string]interface{}) (*PurchaseResponse, error)
	RestorePurchase(ctx context.Context, req map[string]interface{}) (*OkResponse, error)
	EmailRequest(ctx context.Context, email string) (*OkResponse, error)
	ReferralAttach(ctx context.Context, refCode string) (bool, error)
	//Device Linking
	LinkCodeApprove(ctx context.Context, code string) (*protos.BaseResponse, error)
	LinkCodeRequest(ctx context.Context, deviceName string) (*LinkCodeResponse, error)
	LinkCodeRedeem(ctx context.Context, deviceName string, deviceCode string) (*LinkCodeRedeemResponse, error)
	UserLinkCodeRequest(ctx context.Context, deviceId string, email string) (bool, error)
	UserLinkValidate(ctx context.Context, code string) (*UserRecovery, error)
	DeviceRemove(ctx context.Context, deviceId string) (*LinkResponse, error)
	DeviceAdd(ctx context.Context, deviceName string) (bool, error)
}

// NewClient creates a new instance of ProClient
func NewClient(baseURL string, opts *webclient.Opts) ProClient {
	if opts.HttpClient == nil {
		// The default http.RoundTripper used by the ProClient is ParallelForIdempotent which
		// attempts to send requests through both chained and direct fronted routes in parallel
		// for HEAD and GET requests and ChainedThenFronted for all others.
		opts.HttpClient = NewHTTPClient(proxied.ParallelForIdempotent(), opts.Timeout)
	}
	if opts.OnBeforeRequest == nil {
		opts.OnBeforeRequest = func(client *resty.Client, req *http.Request) error {
			prepareProRequest(req, common.ProAPIHost, opts.UserConfig())
			return nil
		}
	}

	return &proClient{
		userConfig:    opts.UserConfig,
		backoffRunner: &backoffRunner{},
		RESTClient:    webclient.NewRESTClient(opts),
	}
}

// prepareProRequest normalizes requests to the pro server with device ID, user ID, etc set.
func prepareProRequest(r *http.Request, proAPIHost string, userConfig common.UserConfig) {
	if r.URL.Scheme == "" {
		r.URL.Scheme = "http"
	}
	r.URL.Host = proAPIHost
	r.RequestURI = "" // http: Request.RequestURI can't be set in client requests.
	r.Header.Set("Access-Control-Allow-Headers", strings.Join([]string{
		common.DeviceIdHeader,
		common.ProTokenHeader,
		common.UserIdHeader,
	}, ", "))
	common.AddCommonHeadersWithOptions(userConfig, r, false)
}

func (c *proClient) defaultParams() map[string]interface{} {
	uc := c.userConfig()
	params := map[string]interface{}{
		"locale": uc.GetLanguage(),
	}
	return params
}

// EmailExists is used to check if an email address belongs to an existing Pro account
// XXX Deprecated: See https://github.com/getlantern/lantern-internal/issues/4377
func (c *proClient) EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	err := c.GetJSON(ctx, "/email-exists", map[string]interface{}{
		"email": email,
	}, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) EmailRequest(ctx context.Context, email string) (*OkResponse, error) {
	var resp OkResponse
	params := c.defaultParams()
	params["email"] = email
	err := c.PostJSONReadingJSON(ctx, "/user-email-request", params, nil, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// PaymentRedirect returns a checkout/redirect URL to be used to complete a Lantern Pro purchase with a payment provider
func (c *proClient) PaymentRedirect(ctx context.Context, req *protos.PaymentRedirectRequest) (*PaymentRedirectResponse, error) {
	var resp PaymentRedirectResponse
	uc := c.userConfig()
	req.Locale = uc.GetLanguage()
	b, _ := protojson.Marshal(req)
	params := make(map[string]interface{})
	json.Unmarshal(b, &params)
	err := c.GetJSON(ctx, "/payment-redirect", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// PaymentMethods returns a list of plans along with payment providers and available payment methods
// This methods has been deparacted in flavor of PaymentMethodsV4
func (c *proClient) PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.GetJSON(ctx, "/plans-v3", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// PaymentMethods returns a list of plans, payment providers and logo available payment methods
func (c *proClient) PaymentMethodsV4(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.GetJSON(ctx, "/plans-v4", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	if resp.BaseResponse != nil && resp.BaseResponse.Error != "" {
		return nil, errors.New("error received from server: %v", resp.BaseResponse.Error)
	}

	// process plans for currency
	for i, plan := range resp.Plans {
		parts := strings.Split(plan.Id, "-")
		if len(parts) != 3 {
			continue
		}
		cur := parts[1]

		currency1 := accounting.LocaleInfo[strings.ToUpper(cur)]
		ac := accounting.Accounting{Symbol: currency1.ComSymbol, Precision: 2}
		monthlyPrice := plan.ExpectedMonthlyPrice[strings.ToLower(cur)]
		yearlyPrice := plan.Price[strings.ToLower(cur)]

		amount := decimal.NewFromInt(monthlyPrice).Div(decimal.NewFromInt(100))
		yearAmount := decimal.NewFromInt(yearlyPrice).Div(decimal.NewFromInt(100))
		resp.Plans[i].OneMonthCost = ac.FormatMoneyDecimal(amount)
		resp.Plans[i].TotalCost = ac.FormatMoneyDecimal(yearAmount)
		resp.Plans[i].TotalCostBilledOneTime = fmt.Sprintf("%v billed one time", ac.FormatMoneyDecimal(yearAmount))
	}
	return &resp, nil
}

// Plans is used to hit the legacy /plans endpoint. Deprecated.
func (c *proClient) Plans(ctx context.Context) (*PlansResponse, error) {
	var resp PlansResponse
	err := c.GetJSON(ctx, "/plans", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	for i, plan := range resp.Plans {
		parts := strings.Split(plan.Id, "-")
		if len(parts) != 3 {
			continue
		}
		cur := parts[1]
		if currency, ok := accounting.LocaleInfo[strings.ToUpper(cur)]; ok {
			if oneMonthCost, ok2 := plan.ExpectedMonthlyPrice[strings.ToLower(cur)]; ok2 {
				ac := accounting.Accounting{Symbol: currency.ComSymbol, Precision: 2}
				amount := decimal.NewFromInt(oneMonthCost).Div(decimal.NewFromInt(100))
				resp.Plans[i].OneMonthCost = ac.FormatMoneyDecimal(amount)
			}
		}
	}
	return &resp, nil
}

// UserCreate creates a new user
func (c *proClient) UserCreate(ctx context.Context) (*UserDataResponse, error) {
	var resp UserDataResponse
	err := c.PostFormReadingJSON(ctx, "/user-create", nil, &resp)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	if resp.BaseResponse != nil && resp.BaseResponse.Error != "" {
		return nil, errors.New("error received: %v", resp.BaseResponse.Error)
	}
	log.Debugf("UserCreate response is %v", resp)
	return &resp, nil
}

// UserData returns data associated with a user
func (c *proClient) UserData(ctx context.Context) (*UserDataResponse, error) {
	var resp UserDataResponse
	err := c.GetJSON(ctx, "/user-data", nil, &resp)
	if err != nil {
		log.Errorf("Failed to fetch user data: %v", err)
		return nil, errors.New("error fetching user data: %v", err)
	}
	log.Debugf("UserData response is %v", resp)
	return &resp, nil
}

// RedeemResellerCode redeems a reseller code for the given user
func (c *proClient) RedeemResellerCode(ctx context.Context, req *protos.RedeemResellerCodeRequest) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	if err := c.PostFormReadingJSON(ctx, "/purchase", req, &resp); err != nil {
		log.Errorf("Failed to redeem reseller code: %v", err)
		return nil, err
	}
	if resp.Error != "" {
		return nil, errors.New("error redeeming reseller code: %v", resp.Error)
	}
	return &resp, nil
}

// DeviceRemove removes the device with the given ID from a user's Pro account
func (c *proClient) DeviceRemove(ctx context.Context, deviceId string) (*LinkResponse, error) {
	var resp LinkResponse
	params := c.defaultParams()
	params["deviceID"] = deviceId
	err := c.PostJSONReadingJSON(ctx, "/user-link-remove", params, nil, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// DeviceAdd adds a device with the given name to a user's Pro account
// This get calles when user login to attech device
func (c *proClient) DeviceAdd(ctx context.Context, deviceName string) (bool, error) {
	var resp protos.BaseResponse
	params := c.defaultParams()
	params["deviceName"] = deviceName
	err := c.PostJSONReadingJSON(ctx, "/device-add", params, nil, &resp)
	if err != nil {
		return false, err
	}
	if resp.Error != "" && resp.Status != "ok" {
		return false, errors.New("%v adding device: %v", resp.ErrorId, resp.Error)
	}
	return true, nil
}

// LinkCodeApprove is used to approve a code to link a device to an existing Pro account
func (c *proClient) LinkCodeApprove(ctx context.Context, code string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	params := c.defaultParams()
	params["code"] = code
	err := c.PostJSONReadingJSON(ctx, "/link-code-approve", params, nil, &resp)
	if err != nil {
		return nil, err
	}
	if resp.Error != "" && resp.Status != "ok" {
		return nil, errors.New("%v approving link code: %v", resp.ErrorId, resp.Error)
	}

	return &resp, nil
}

// LinkCodeRequest returns a code that can be used to link a device to an existing Pro account
func (c *proClient) LinkCodeRequest(ctx context.Context, deviceName string) (*LinkCodeResponse, error) {
	if deviceName == "" {
		return nil, errMissingDeviceName
	}
	var resp LinkCodeResponse
	uc := c.userConfig()
	err := c.PostJSONReadingJSON(ctx, "/link-code-request", map[string]interface{}{
		"deviceName": deviceName,
		"locale":     uc.GetLanguage(),
	}, nil, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// LinkCodeRequest returns a code that can be used to link a device to an existing Pro account
func (c *proClient) LinkCodeRedeem(ctx context.Context, deviceName string, deviceCode string) (*LinkCodeRedeemResponse, error) {
	var resp LinkCodeRedeemResponse
	err := c.PostJSONReadingJSON(ctx, "/link-code-redeem", map[string]interface{}{
		"deviceName": deviceName,
		"code":       deviceCode,
	}, nil, &resp)
	if err != nil {
		return nil, err
	}
	if resp.BaseResponse != nil && resp.Status != "ok" {
		return nil, errors.New("%v redeeming link code: %v", resp.ErrorId, resp.Error)
	}
	return &resp, nil
}

// UserLinkCodeRequest returns a code to email register pro account email that can be used to link device to an existing Pro account
func (c *proClient) UserLinkCodeRequest(ctx context.Context, deviceId string, email string) (bool, error) {
	if deviceId == "" {
		return false, errMissingDeviceName
	}
	var resp LinkCodeResponse
	uc := c.userConfig()
	err := c.PostJSONReadingJSON(ctx, "/user-link-request", map[string]interface{}{
		"deviceName": deviceId,
		"email":      email,
		"locale":     uc.GetLanguage(),
	}, nil, &resp)
	if err != nil {
		return false, err
	}
	if resp.BaseResponse != nil && resp.Status != "ok" {
		return false, errors.New("error requesting link code: %v", resp.Error)
	}
	return true, nil
}

// UserLinkCodeRequest returns a code to email register pro account email that can be used to link device to an existing Pro account
func (c *proClient) UserLinkValidate(ctx context.Context, code string) (*UserRecovery, error) {
	var resp UserRecovery
	uc := c.userConfig()
	err := c.PostJSONReadingJSON(ctx, "/user-link-validate", map[string]interface{}{
		"code":   code,
		"locale": uc.GetLanguage(),
	}, nil, &resp)
	if err != nil {
		return nil, err
	}
	if resp.Status != "ok" {
		return nil, errors.New("error validating link code: %v", resp.Status)
	}

	return &resp, nil
}

// PurchaseRequest is used to request a purchase of a Pro plan is will be used for all most all the payment providers
func (c *proClient) PurchaseRequest(ctx context.Context, req map[string]interface{}) (*PurchaseResponse, error) {
	var resp PurchaseResponse
	err := c.PostFormReadingJSON(ctx, "/purchase", req, &resp)
	if err != nil {
		return nil, err
	}
	if resp.BaseResponse != nil && resp.Status != "ok" {
		return nil, errors.New("error purchasing pro plan: %v", resp.Error)
	}
	return &resp, nil
}

// RestorePurchase is used to restore a purchase for Google and apple play users
func (c *proClient) RestorePurchase(ctx context.Context, req map[string]interface{}) (*OkResponse, error) {
	var resp OkResponse
	err := c.PostFormReadingJSON(ctx, "/restore-purchase", req, &resp)
	if err != nil {
		return nil, log.Errorf("%v", err)
	}
	if resp.Status != "ok" {
		return nil, errors.New("wrong_seller_code: %v", resp.Status)
	}
	return &resp, nil

}

// PurchaseRequest is used to request a purchase of a Pro plan is will be used for all most all the payment providers
func (c *proClient) ReferralAttach(ctx context.Context, refCode string) (bool, error) {
	var resp protos.BaseResponse
	params := c.defaultParams()
	params["code"] = refCode
	err := c.PostFormReadingJSON(ctx, "/referral-attach", params, &resp)
	if err != nil {
		return false, err
	}
	if resp.Status != "ok" {
		return false, errors.New("error_referral: %v", resp.Status)
	}
	return true, nil
}
