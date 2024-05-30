package pro

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient/defaultwebclient"
	"github.com/getlantern/lantern-client/internalsdk/protos"

	"github.com/go-resty/resty/v2"
	"github.com/leekchan/accounting"
	"github.com/shopspring/decimal"
	"google.golang.org/protobuf/encoding/protojson"
)

var (
	log                  = golog.LoggerFor("webclient")
	errMissingDeviceName = errors.New("Missing device name")
)

const (
	// publicBaseUrl = "https://api.iantem.io/v1"
	// userGroup     = publicBaseUrl + "/users"
	saltUrl = "/users/salt"
)

type proClient struct {
	userConfig func() common.UserConfig
	webclient  webclient.RESTClient
}

type Opts struct {
	// HttpClient represents an http.Client that should be used by the resty client
	HttpClient *http.Client
	// UserConfig is a function that returns the user config associated with the Lantern user
	UserConfig func() common.UserConfig
}

type ProClient interface {
	AuthClient
	EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error)
	PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error)
	PaymentMethodsV4(ctx context.Context) (*PaymentMethodsResponse, error)
	PaymentRedirect(ctx context.Context, req *protos.PaymentRedirectRequest) (*PaymentRedirectResponse, error)
	Plans(ctx context.Context) (*PlansResponse, error)
	RedeemResellerCode(ctx context.Context, req *protos.RedeemResellerCodeRequest) (*protos.BaseResponse, error)
	UserCreate(ctx context.Context) (*UserDataResponse, error)
	UserData(ctx context.Context) (*UserDataResponse, error)
	PurchaseRequest(ctx context.Context, data map[string]interface{}) (*PurchaseResponse, error)
	//Device Linking
	LinkCodeApprove(ctx context.Context, code string) (*protos.BaseResponse, error)
	LinkCodeRequest(ctx context.Context, deviceName string) (*LinkCodeResponse, error)
	UserLinkCodeRequest(ctx context.Context, deviceId string) (bool, error)
	UserLinkValidate(ctx context.Context, code string) (*UserRecovery, error)
	DeviceRemove(ctx context.Context, deviceId string) (*LinkResponse, error)
}

type AuthClient interface {
	GetSalt(ctx context.Context, email string) (*protos.GetSaltResponse, error)
	SignUp(ctx context.Context, signupData *protos.SignupRequest) (bool, error)
	SignupEmailResendCode(ctx context.Context, data *protos.SignupEmailResendRequest) (bool, error)
	SignupEmailConfirmation(ctx context.Context, data *protos.ConfirmSignupRequest) (bool, error)
	LoginPrepare(ctx context.Context, loginData *protos.PrepareRequest) (*protos.PrepareResponse, error)
	Login(ctx context.Context, loginData *protos.LoginRequest) (*protos.LoginResponse, error)
	StartRecoveryByEmail(ctx context.Context, loginData *protos.StartRecoveryByEmailRequest) (bool, error)
	CompleteRecoveryByEmail(ctx context.Context, loginData *protos.CompleteRecoveryByEmailRequest) (bool, error)
	ValidateEmailRecoveryCode(ctx context.Context, loginData *protos.ValidateRecoveryCodeRequest) (*protos.ValidateRecoveryCodeResponse, error)
	ChangeEmail(ctx context.Context, loginData *protos.ChangeEmailRequest) (bool, error)
	CompleteChangeEmail(ctx context.Context, loginData *protos.CompleteChangeEmailRequest) (bool, error)
	DeleteAccount(ctc context.Context, loginData *protos.DeleteUserRequest) (bool, error)
}

// NewClient creates a new instance of ProClient
func NewClient(baseURL string, opts *Opts) ProClient {
	httpClient := opts.HttpClient
	if httpClient == nil {
		httpClient = &http.Client{}
	}
	client := &proClient{
		userConfig: opts.UserConfig,
	}
	client.webclient = webclient.NewRESTClient(defaultwebclient.SendToURL(httpClient, baseURL, client.setUserHeaders(), nil))
	return client
}

func (c *proClient) setUserHeaders() func(client *resty.Client, req *resty.Request) error {
	return func(client *resty.Client, req *resty.Request) error {

		uc := c.userConfig()

		//req.Header.Set("Referer", "http://localhost:37457/")
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
	err := c.webclient.GetJSON(ctx, "/email-exists", map[string]interface{}{
		"email": email,
	}, &resp)
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
	err := c.webclient.GetJSON(ctx, "/payment-redirect", params, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// PaymentMethods returns a list of plans along with payment providers and available payment methods
// This methods has been deparacted in flavor of PaymentMethodsV4
func (c *proClient) PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.webclient.GetJSON(ctx, "/plans-v3", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	b, _ := json.Marshal(resp)
	log.Debugf("PaymentMethods response is %v", string(b))
	return &resp, nil
}

// PaymentMethods returns a list of plans, payment providers and logo available payment methods
func (c *proClient) PaymentMethodsV4(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.webclient.GetJSON(ctx, "/plans-v4", c.defaultParams(), &resp)
	if err != nil {
		return nil, err
	}
	if resp.BaseResponse != nil && resp.BaseResponse.Error != "" {
		return nil, errors.New("error received from server: %v", resp.BaseResponse.Error)
	}
	log.Debugf("PaymentMethods-V4 plans is %v", resp.Plans)
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

// Plans is used to hit the legacy /plans endpoint. Deprecated.
func (c *proClient) Plans(ctx context.Context) (*PlansResponse, error) {
	var resp PlansResponse
	err := c.webclient.GetJSON(ctx, "/plans", c.defaultParams(), &resp)
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
	err := c.webclient.PostFormReadingJSON(ctx, "/user-create", nil, &resp)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	log.Debugf("UserCreate response is %v", resp)
	return &resp, nil
}

// UserData returns data associated with a user
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
	if err := c.webclient.PostFormReadingJSON(ctx, "/purchase", req, &resp); err != nil {
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
	err := c.webclient.PostJSONReadingJSON(ctx, "/user-link-remove", params, nil, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// LinkCodeApprove is used to approve a code to link a device to an existing Pro account
func (c *proClient) LinkCodeApprove(ctx context.Context, code string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	params := c.defaultParams()
	params["code"] = code
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-approve", params, nil, &resp)
	if err != nil {
		return nil, err
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
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-request", map[string]interface{}{
		"deviceName": deviceName,
		"locale":     uc.GetLanguage(),
	}, nil, &resp)
	if err != nil {
		return nil, err
	}
	b, _ := json.Marshal(resp)
	log.Debugf("LinkCodeResponse is %s", string(b))
	return &resp, nil
}

// UserLinkCodeRequest returns a code to email register pro account email that can be used to link device to an existing Pro account
func (c *proClient) UserLinkCodeRequest(ctx context.Context, deviceId string) (bool, error) {
	if deviceId == "" {
		return false, errMissingDeviceName
	}
	var resp LinkCodeResponse
	uc := c.userConfig()
	err := c.webclient.PostJSONReadingJSON(ctx, "/user-link-request", map[string]interface{}{
		"deviceName": deviceId,
		"locale":     uc.GetLanguage(),
	}, nil, &resp)
	if err != nil {
		return false, err
	}

	return true, nil
}

// UserLinkCodeRequest returns a code to email register pro account email that can be used to link device to an existing Pro account
func (c *proClient) UserLinkValidate(ctx context.Context, code string) (*UserRecovery, error) {
	var resp UserRecovery
	uc := c.userConfig()
	err := c.webclient.PostJSONReadingJSON(ctx, "/user-link-validate", map[string]interface{}{
		"code":   code,
		"locale": uc.GetLanguage(),
	}, nil, &resp)
	if err != nil {
		return nil, err
	}

	return &resp, nil
}

// PurchaseRequest is used to request a purchase of a Pro plan is will be used for all most all the payment providers
func (c *proClient) PurchaseRequest(ctx context.Context, data map[string]interface{}) (*PurchaseResponse, error) {
	var resp PurchaseResponse
	err := c.webclient.PostJSONReadingJSON(ctx, "/purchase", data, nil, &resp)
	if err != nil {
		return nil, err
	}
	log.Debugf("PurchaseRequest is %+v", &resp)
	return &resp, nil
}

// Auth APIS

func (c *proClient) GetSalt(ctx context.Context, email string) (*protos.GetSaltResponse, error) {
	var resp protos.GetSaltResponse
	log.Debugf("Getting salt for email %v", email)
	err := c.webclient.GetPROTOC(ctx, "/users/salt", map[string]interface{}{
		"email": email,
	}, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// Sign up API
func (c *proClient) SignUp(ctx context.Context, signupData *protos.SignupRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup", nil, signupData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) SignupEmailResendCode(ctx context.Context, data *protos.SignupEmailResendRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup/resend/email", nil, data, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) SignupEmailConfirmation(ctx context.Context, data *protos.ConfirmSignupRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup/complete/email", nil, data, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) LoginPrepare(ctx context.Context, loginData *protos.PrepareRequest) (*protos.PrepareResponse, error) {
	var resp protos.PrepareResponse
	err := c.webclient.PostPROTOC(ctx, "/prepare", nil, loginData, &resp)
	if err != nil {
		return nil, err
	}
	return nil, nil
}

func (c *proClient) Login(ctx context.Context, loginData *protos.LoginRequest) (*protos.LoginResponse, error) {
	var resp protos.LoginResponse
	err := c.webclient.PostPROTOC(ctx, "/login", nil, loginData, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) StartRecoveryByEmail(ctx context.Context, loginData *protos.StartRecoveryByEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/recovery/start/email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) CompleteRecoveryByEmail(ctx context.Context, loginData *protos.CompleteRecoveryByEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/recovery/complete/email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) ValidateEmailRecoveryCode(ctx context.Context, loginData *protos.ValidateRecoveryCodeRequest) (*protos.ValidateRecoveryCodeResponse, error) {
	var resp protos.ValidateRecoveryCodeResponse
	err := c.webclient.PostPROTOC(ctx, "/recovery/complete/email", nil, loginData, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *proClient) ChangeEmail(ctx context.Context, loginData *protos.ChangeEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/change_email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) CompleteChangeEmail(ctx context.Context, loginData *protos.CompleteChangeEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/change_email/complete/email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (c *proClient) DeleteAccount(ctx context.Context, accountData *protos.DeleteUserRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/change_email/complete/email", nil, accountData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}
