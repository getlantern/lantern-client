package auth

import (
	"context"

	"net/http"
	"strings"

	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"

	"github.com/getlantern/lantern-client/internalsdk/webclient/defaultwebclient"
	"github.com/go-resty/resty/v2"
)

var (
	log = golog.LoggerFor("authclient")
)

type authClient struct {
	webclient  webclient.RESTClient
	userConfig func() common.UserConfig
}

type AuthClient interface {
	//Sign up methods
	SignUp(email string, password string) ([]byte, error)
	SignupEmailResendCode(ctx context.Context, data *protos.SignupEmailResendRequest) (bool, error)
	SignupEmailConfirmation(ctx context.Context, data *protos.ConfirmSignupRequest) (bool, error)

	//Login methods
	GetSalt(ctx context.Context, email string) (*protos.GetSaltResponse, error)
	LoginPrepare(ctx context.Context, loginData *protos.PrepareRequest) (*protos.PrepareResponse, error)
	Login(email string, password string, deviceId string) (*protos.LoginResponse, []byte, error)
	// Recovery methods
	StartRecoveryByEmail(ctx context.Context, loginData *protos.StartRecoveryByEmailRequest) (bool, error)
	CompleteRecoveryByEmail(ctx context.Context, loginData *protos.CompleteRecoveryByEmailRequest) (bool, error)
	ValidateEmailRecoveryCode(ctx context.Context, loginData *protos.ValidateRecoveryCodeRequest) (*protos.ValidateRecoveryCodeResponse, error)
	// Change email methods
	ChangeEmail(ctx context.Context, loginData *protos.ChangeEmailRequest) (bool, error)
	// Complete change email methods
	CompleteChangeEmail(ctx context.Context, loginData *protos.CompleteChangeEmailRequest) (bool, error)
	DeleteAccount(ctc context.Context, loginData *protos.DeleteUserRequest) (bool, error)

	//Logout
	SignOut(ctx context.Context, logoutData *protos.LogoutRequest) (bool, error)
}

// NewClient creates a new instance of AuthClient
func NewClient(baseURL string, opts *webclient.Opts) AuthClient {
	httpClient := opts.HttpClient
	if httpClient == nil {
		httpClient = &http.Client{}
	}
	authClient := &authClient{
		userConfig: opts.UserConfig,
	}
	authClient.webclient = webclient.NewRESTClient(defaultwebclient.SendToURL(httpClient, baseURL, prepareUserRequest(opts.UserConfig), nil))
	return authClient
}

func prepareUserRequest(userConfig func() common.UserConfig) func(client *resty.Client, req *http.Request) error {
	return func(client *resty.Client, req *http.Request) error {
		req.Header.Set(common.ContentType, "application/x-protobuf")
		req.Header.Set("Access-Control-Allow-Headers", strings.Join([]string{
			common.DeviceIdHeader,
			common.ProTokenHeader,
			common.UserIdHeader,
		}, ", "))
		uc := userConfig()
		if req.URL != nil && strings.HasSuffix(req.URL.Path, "/users/signup") {
			// for the /users/signup endpoint, we do need to pass all default headers
			common.AddCommonHeadersWithOptions(uc, req, false)
		} else {
			common.AddCommonNonUserHeaders(uc, req)
		}
		return nil
	}
}

// Auth APIS
// GetSalt is used to get the salt for a given email address
func (c *authClient) GetSalt(ctx context.Context, email string) (*protos.GetSaltResponse, error) {
	var resp protos.GetSaltResponse
	err := c.webclient.GetPROTOC(ctx, "/users/salt", map[string]interface{}{
		"email": email,
	}, &resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// Sign up API
// SignUp is used to sign up a new user with the SignupRequest
func (c *authClient) signUp(ctx context.Context, signupData *protos.SignupRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup", nil, signupData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// SignupEmailResendCode is used to resend the email confirmation code
// Params: ctx context.Context, data *protos.SignupEmailResendRequest
func (c *authClient) SignupEmailResendCode(ctx context.Context, data *protos.SignupEmailResendRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup/resend/email", nil, data, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// SignupEmailConfirmation is used to confirm the email address once user enter code
// Params: ctx context.Context, data *protos.ConfirmSignupRequest
func (c *authClient) SignupEmailConfirmation(ctx context.Context, data *protos.ConfirmSignupRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/signup/complete/email", nil, data, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// LoginPrepare does the initial login preparation with come make sure the user exists and match user salt
func (c *authClient) LoginPrepare(ctx context.Context, loginData *protos.PrepareRequest) (*protos.PrepareResponse, error) {
	var model protos.PrepareResponse
	err := c.webclient.PostPROTOC(ctx, "/users/prepare", nil, loginData, &model)
	if err != nil {
		// Send custom error to show error on client side
		return nil, log.Errorf("user_not_found %v", err)
	}
	return &model, nil
}

// Login is used to login a user with the LoginRequest
func (c *authClient) login(ctx context.Context, loginData *protos.LoginRequest) (*protos.LoginResponse, error) {
	var resp protos.LoginResponse
	err := c.webclient.PostPROTOC(ctx, "/users/login", nil, loginData, &resp)
	if err != nil {
		return nil, err
	}

	return &resp, nil
}

// StartRecoveryByEmail is used to start the recovery process by sending a recovery code to the user's email
func (c *authClient) StartRecoveryByEmail(ctx context.Context, loginData *protos.StartRecoveryByEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/recovery/start/email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// CompleteRecoveryByEmail is used to complete the recovery process by validating the recovery code
func (c *authClient) CompleteRecoveryByEmail(ctx context.Context, loginData *protos.CompleteRecoveryByEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/recovery/complete/email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// // ValidateEmailRecoveryCode is used to validate the recovery code
func (c *authClient) ValidateEmailRecoveryCode(ctx context.Context, recoveryData *protos.ValidateRecoveryCodeRequest) (*protos.ValidateRecoveryCodeResponse, error) {
	var resp protos.ValidateRecoveryCodeResponse
	log.Debugf("ValidateEmailRecoveryCode request is %v", recoveryData)
	err := c.webclient.PostPROTOC(ctx, "/users/recovery/validate/email", nil, recoveryData, &resp)
	if err != nil {
		return nil, err
	}
	if !resp.Valid {
		return nil, log.Errorf("invalid_code Error decoding response body: %v", err)
	}
	return &resp, nil
}

// ChangeEmail is used to change the email address of a user
func (c *authClient) ChangeEmail(ctx context.Context, loginData *protos.ChangeEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/change_email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// CompleteChangeEmail is used to complete the email change process
func (c *authClient) CompleteChangeEmail(ctx context.Context, loginData *protos.CompleteChangeEmailRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/change_email/complete/email", nil, loginData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// DeleteAccount is used to delete the account of a user
// Once account is delete make sure to create new account
func (c *authClient) DeleteAccount(ctx context.Context, accountData *protos.DeleteUserRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/delete", nil, accountData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}

// DeleteAccount is used to delete the account of a user
// Once account is delete make sure to create new account
func (c *authClient) SignOut(ctx context.Context, logoutData *protos.LogoutRequest) (bool, error) {
	var resp protos.EmptyResponse
	err := c.webclient.PostPROTOC(ctx, "/users/logout", nil, logoutData, &resp)
	if err != nil {
		return false, err
	}
	return true, nil
}
