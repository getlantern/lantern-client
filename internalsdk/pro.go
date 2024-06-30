package internalsdk

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

type proClient struct {
	pro.ProClient
}

// ProClient is a simplified version of pro.ProClient that can be used on Android
type ProClient interface {
	CurrenciesList() (string, error)
	PaymentMethods() (string, error)
	UserCreate() (string, error)
	UserData() (string, error)
	LinkCodeRequest(string) (string, error)
	LinkCodeApprove(string) (string, error)
	LinkCodeRedeem(string, string) (string, error)
	DeviceRemove(string) (string, error)
	UserLinkValidate(string) (string, error)
	PaymentRedirect(string, string, string) (string, error)
	Purchase(string) (string, error)
	UserLinkCodeRequest(string) (bool, error)
}

// NewProClient creates a new instance of ProClient
func NewProClient(wrappedSession Session) ProClient {
	session := &panickingSessionImpl{wrappedSession}
	uc := NewUserConfig(session)
	client := pro.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), &webclient.Opts{
		HttpClient: &http.Client{
			Transport: proxied.ParallelForIdempotent(),
			Timeout:   30 * time.Second,
		},
		UserConfig: func() common.UserConfig {
			return uc
		},
	})
	return &proClient{client}
}

func protoMarshal[T protoreflect.ProtoMessage](resp T) string {
	b, err := proto.Marshal(resp)
	if err != nil {
		return ""
	}
	return string(b)
}

func jsonMarshal(resp any) string {
	b, _ := json.Marshal(resp)
	return string(b)
}

// TODO: We should be able to consolidate these changes and re-use the same code on
// desktop and Android

// UserCreate is used to create a new user
func (c *proClient) UserCreate() (string, error) {
	resp, err := c.ProClient.UserCreate(context.Background())
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp.User), nil
}

// UpdatePaymentMethods is used to update the payment methods and plans that are shown to a user
func (c *proClient) PaymentMethods() (string, error) {
	resp, err := c.ProClient.PaymentMethods(context.Background())
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *proClient) LinkCodeRequest(deviceName string) (string, error) {
	resp, err := c.ProClient.LinkCodeRequest(context.Background(), deviceName)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *proClient) LinkCodeRedeem(deviceName, code string) (string, error) {
	resp, err := c.ProClient.LinkCodeRedeem(context.Background(), deviceName, code)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

// LinkCodeApprove is used to approve a code to link a device to an existing Pro account
func (c *proClient) LinkCodeApprove(code string) (string, error) {
	resp, err := c.ProClient.LinkCodeApprove(context.Background(), code)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

// DeviceRemove removes the device with the given ID from a user's Pro account
func (c *proClient) DeviceRemove(deviceId string) (string, error) {
	resp, err := c.ProClient.DeviceRemove(context.Background(), deviceId)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *proClient) UserLinkValidate(code string) (string, error) {
	resp, err := c.ProClient.UserLinkValidate(context.Background(), code)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

// UserLinkCodeRequest returns a code to email register pro account email that can be used to link device to an existing Pro account
func (c *proClient) UserLinkCodeRequest(deviceId string) (bool, error) {
	return c.ProClient.UserLinkCodeRequest(context.Background(), deviceId)
}

// PaymentRedirect is used to select a payment provider to redirect a user to
func (c *proClient) PaymentRedirect(email, planID, provider string) (string, error) {
	resp, err := c.ProClient.PaymentRedirect(context.Background(), &protos.PaymentRedirectRequest{
		Email:    email,
		Plan:     planID,
		Provider: provider,
	})
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

func (c *proClient) Purchase(b string) (string, error) {
	data := map[string]interface{}{}
	err := json.Unmarshal([]byte(b), &data)
	if err != nil {
		return "", err
	}
	resp, err := c.ProClient.PurchaseRequest(context.Background(), data)
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp), nil
}

// UpdatePaymentMethods is used to update the payment methods and plans that are shown to a user
func (c *proClient) CurrenciesList() (string, error) {
	resp, err := c.ProClient.SupportedCurrencies(context.Background())
	if err != nil {
		return "", err
	}
	var currencies []string
	for _, currency := range resp.Currencies {
		currencies = append(currencies, strings.ToLower(currency))
	}
	return jsonMarshal(currencies), nil
}

// UserData returns data associated with a user
func (c *proClient) UserData() (string, error) {
	resp, err := c.ProClient.UserData(context.Background())
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp.User), nil
}
