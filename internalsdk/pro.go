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
