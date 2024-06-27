package internalsdk

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
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
	//Plans() (*pro.PlansResponse, error)
	//UserCreate() (*pro.UserDataResponse, error)
	//UserData() *pro.UserDataResponse
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

// UserCreate creates a new user
func (c *proClient) UserCreate() (*pro.UserDataResponse, error) {
	return c.ProClient.UserCreate(context.Background())
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

// UserData returns data associated with a user
// TODO: We should be able to consolidate these changes and re-use the same code on
// desktop and Android
func (c *proClient) UserData() (string, error) {
	resp, err := c.ProClient.UserData(context.Background())
	if err != nil {
		return "", err
	}
	return jsonMarshal(resp.User), nil
}
