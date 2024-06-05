package pro

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient/defaultwebclient"
	"github.com/getlantern/lantern-client/internalsdk/protos"

	"github.com/leekchan/accounting"
	"github.com/shopspring/decimal"
	"google.golang.org/protobuf/encoding/protojson"
)

var (
	log                  = golog.LoggerFor("webclient")
	errMissingDeviceName = errors.New("Missing device name")
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
	LinkCodeRedeem(ctx context.Context, deviceName string, deviceCode string) (*LinkCodeRedeemResponse, error)
	UserLinkCodeRequest(ctx context.Context, deviceId string) (bool, error)
	UserLinkValidate(ctx context.Context, code string) (*UserRecovery, error)
	DeviceRemove(ctx context.Context, deviceId string) (*LinkResponse, error)
	DeviceAdd(ctx context.Context, deviceName string) (bool, error)
}

type AuthClient interface {
	//Sign up methods
	SignUp(ctx context.Context, signupData *protos.SignupRequest) (bool, error)
	SignupEmailResendCode(ctx context.Context, data *protos.SignupEmailResendRequest) (bool, error)
	SignupEmailConfirmation(ctx context.Context, data *protos.ConfirmSignupRequest) (bool, error)

	//Login methods
	GetSalt(ctx context.Context, email string) (*protos.GetSaltResponse, error)
	LoginPrepare(ctx context.Context, loginData *protos.PrepareRequest) (*protos.PrepareResponse, error)
	Login(ctx context.Context, loginData *protos.LoginRequest) (*protos.LoginResponse, error)
	// Recovery methods
	StartRecoveryByEmail(ctx context.Context, loginData *protos.StartRecoveryByEmailRequest) (bool, error)
	CompleteRecoveryByEmail(ctx context.Context, loginData *protos.CompleteRecoveryByEmailRequest) (bool, error)
	ValidateEmailRecoveryCode(ctx context.Context, loginData *protos.ValidateRecoveryCodeRequest) (*protos.ValidateRecoveryCodeResponse, error)
	// Change email methods
	ChangeEmail(ctx context.Context, loginData *protos.ChangeEmailRequest) (bool, error)
	// Complete change email methods
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
	client.webclient = webclient.NewRESTClient(defaultwebclient.SendToURL(httpClient, baseURL, nil, nil, opts.UserConfig()))
	return client
}

func (c *proClient) defaultParams() map[string]interface{} {
	uc := c.userConfig()
	params := map[string]interface{}{
		"locale": uc.GetLanguage(),
	}
	return params
}

func (c *proClient) defaultHeader() map[string]string {
	uc := c.userConfig()
	params := map[string]string{}
	if deviceID := uc.GetDeviceID(); deviceID != "" {
		params[common.DeviceIdHeader] = deviceID
	}
	if userID := strconv.FormatInt(uc.GetUserID(), 10); userID != "" {
		params[common.UserIdHeader] = userID
	}
	if token := uc.GetToken(); token != "" {
		params[common.ProTokenHeader] = token
	}
	params[common.ContentType] = "application/json"
	return params
}

// EmailExists is used to check if an email address belongs to an existing Pro account
// XXX Deprecated: See https://github.com/getlantern/lantern-internal/issues/4377
func (c *proClient) EmailExists(ctx context.Context, email string) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	err := c.webclient.GetJSON(ctx, "/email-exists", map[string]interface{}{
		"email": email,
	}, &resp, c.defaultHeader())
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
	err := c.webclient.GetJSON(ctx, "/payment-redirect", params, &resp, c.defaultHeader())
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// PaymentMethods returns a list of plans along with payment providers and available payment methods
// This methods has been deparacted in flavor of PaymentMethodsV4
func (c *proClient) PaymentMethods(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.webclient.GetJSON(ctx, "/plans-v3", c.defaultParams(), &resp, c.defaultHeader())
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// PaymentMethods returns a list of plans, payment providers and logo available payment methods
func (c *proClient) PaymentMethodsV4(ctx context.Context) (*PaymentMethodsResponse, error) {
	var resp PaymentMethodsResponse
	err := c.webclient.GetJSON(ctx, "/plans-v4", c.defaultParams(), &resp, c.defaultHeader())
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
		yearAmount := decimal.NewFromInt(yearlyPrice)
		resp.Plans[i].OneMonthCost = ac.FormatMoneyDecimal(amount)
		resp.Plans[i].TotalCost = ac.FormatMoneyDecimal(yearAmount)
		resp.Plans[i].TotalCostBilledOneTime = fmt.Sprintf("%v billed one time", ac.FormatMoneyDecimal(yearAmount))
	}
	return &resp, nil
}

// Plans is used to hit the legacy /plans endpoint. Deprecated.
func (c *proClient) Plans(ctx context.Context) (*PlansResponse, error) {
	var resp PlansResponse
	err := c.webclient.GetJSON(ctx, "/plans", c.defaultParams(), &resp, c.defaultHeader())
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
	log.Debugf("UserCreate header is %v", c.defaultHeader())
	err := c.webclient.PostFormReadingJSON(ctx, "/user-create", nil, &resp, c.defaultHeader())
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
	err := c.webclient.GetJSON(ctx, "/user-data", nil, &resp, c.defaultHeader())
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	}
	return &resp, nil
}

// RedeemResellerCode redeems a reseller code for the given user
func (c *proClient) RedeemResellerCode(ctx context.Context, req *protos.RedeemResellerCodeRequest) (*protos.BaseResponse, error) {
	var resp protos.BaseResponse
	if err := c.webclient.PostFormReadingJSON(ctx, "/purchase", req, &resp, c.defaultHeader()); err != nil {
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
	err := c.webclient.PostJSONReadingJSON(ctx, "/user-link-remove", params, nil, &resp, c.defaultHeader())
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
	err := c.webclient.PostJSONReadingJSON(ctx, "/device-add", params, nil, &resp, c.defaultHeader())
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
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-approve", params, nil, &resp, c.defaultHeader())
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
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-request", map[string]interface{}{
		"deviceName": deviceName,
		"locale":     uc.GetLanguage(),
	}, nil, &resp, c.defaultHeader())
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// LinkCodeRequest returns a code that can be used to link a device to an existing Pro account
func (c *proClient) LinkCodeRedeem(ctx context.Context, deviceName string, deviceCode string) (*LinkCodeRedeemResponse, error) {
	var resp LinkCodeRedeemResponse
	err := c.webclient.PostJSONReadingJSON(ctx, "/link-code-redeem", map[string]interface{}{
		"deviceName": deviceName,
		"code":       deviceCode,
	}, nil, &resp, c.defaultHeader())
	if err != nil {
		return nil, err
	}
	if resp.Error != "" && resp.Status != "ok" {
		return nil, errors.New("%v redeeming link code: %v", resp.ErrorId, resp.Error)
	}
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
	}, nil, &resp, c.defaultHeader())
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
	}, nil, &resp, c.defaultHeader())
	if err != nil {
		return nil, err
	}

	return &resp, nil
}

// PurchaseRequest is used to request a purchase of a Pro plan is will be used for all most all the payment providers
func (c *proClient) PurchaseRequest(ctx context.Context, data map[string]interface{}) (*PurchaseResponse, error) {
	var resp PurchaseResponse
	err := c.webclient.PostJSONReadingJSON(ctx, "/purchase", data, nil, &resp, c.defaultHeader())
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// Auth APIS
// GetSalt is used to get the salt for a given email address
func (c *proClient) GetSalt(ctx context.Context, email string) (*protos.GetSaltResponse, error) {
	var resp protos.GetSaltResponse
	err := c.webclient.GetPROTOC(ctx, "/users/salt", map[string]interface{}{
		"email": email,
	}, &resp, nil)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// Sign up API
// SignUp is used to sign up a new user with the SignupRequest
func (c *proClient) SignUp(ctx context.Context, signupData *protos.SignupRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup", nil, signupData, &resp, c.defaultHeader())
	if err != nil {
		return false, log.Errorf("error while sign up %v", err)
	}
	return true, nil
}

// SignupEmailResendCode is used to resend the email confirmation code
// Params: ctx context.Context, data *protos.SignupEmailResendRequest
func (c *proClient) SignupEmailResendCode(ctx context.Context, data *protos.SignupEmailResendRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup/resend/email", nil, data, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}

// SignupEmailConfirmation is used to confirm the email address once user enter code
// Params: ctx context.Context, data *protos.ConfirmSignupRequest
func (c *proClient) SignupEmailConfirmation(ctx context.Context, data *protos.ConfirmSignupRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup/complete/email", nil, data, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}

// LoginPrepare does the initial login preparation with come make sure the user exists and match user salt
func (c *proClient) LoginPrepare(ctx context.Context, loginData *protos.PrepareRequest) (*protos.PrepareResponse, error) {
	var model protos.PrepareResponse
	err := c.webclient.PostPROTOC(ctx, "/users/prepare", nil, loginData, &model, nil)
	if err != nil {
		// Send custom error to show error on client side
		return nil, log.Errorf("user_not_found %v", err)
	}
	return &model, nil
}

// Login is used to login a user with the LoginRequest
func (c *proClient) Login(ctx context.Context, loginData *protos.LoginRequest) (*protos.LoginResponse, error) {
	var resp protos.LoginResponse
	err := c.webclient.PostPROTOC(ctx, "/users/login", nil, loginData, &resp, nil)
	if err != nil {
		return nil, err
	}

	return &resp, nil
}

// StartRecoveryByEmail is used to start the recovery process by sending a recovery code to the user's email
func (c *proClient) StartRecoveryByEmail(ctx context.Context, loginData *protos.StartRecoveryByEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/recovery/start/email", nil, loginData, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}

// CompleteRecoveryByEmail is used to complete the recovery process by validating the recovery code
func (c *proClient) CompleteRecoveryByEmail(ctx context.Context, loginData *protos.CompleteRecoveryByEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/recovery/complete/email", nil, loginData, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}

// // ValidateEmailRecoveryCode is used to validate the recovery code
func (c *proClient) ValidateEmailRecoveryCode(ctx context.Context, recoveryData *protos.ValidateRecoveryCodeRequest) (*protos.ValidateRecoveryCodeResponse, error) {
	var resp protos.ValidateRecoveryCodeResponse
	log.Debugf("ValidateEmailRecoveryCode request is %v", recoveryData)
	err := c.webclient.PostPROTOC(ctx, "/users/recovery/validate/email", nil, recoveryData, &resp, nil)
	if err != nil {
		return nil, err
	}
	if !resp.Valid {
		return nil, log.Errorf("invalid_code Error decoding response body: %v", err)
	}
	return &resp, nil
}

// ChangeEmail is used to change the email address of a user
func (c *proClient) ChangeEmail(ctx context.Context, loginData *protos.ChangeEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/change_email", nil, loginData, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}

// CompleteChangeEmail is used to complete the email change process
func (c *proClient) CompleteChangeEmail(ctx context.Context, loginData *protos.CompleteChangeEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/change_email/complete/email", nil, loginData, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}

// DeleteAccount is used to delete the account of a user
// Once account is delete make sure to create new account
func (c *proClient) DeleteAccount(ctx context.Context, accountData *protos.DeleteUserRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/delete", nil, accountData, &resp, nil)
	if err != nil {
		return false, err
	}
	return true, nil
}
