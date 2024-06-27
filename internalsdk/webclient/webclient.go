package webclient

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

var (
	log = golog.LoggerFor("webclient")
)

type RESTClient interface {
	// Gets a JSON document from the given path with the given querystring parameters, reading the result into target.
	GetJSON(ctx context.Context, path string, params, target any) error

	// Post the given parameters as form data and reads the result JSON into target.
	PostFormReadingJSON(ctx context.Context, path string, params, target any) error

	// Post the given body as JSON with the given querystring parameters and reads the result JSON into target.
	PostJSONReadingJSON(ctx context.Context, path string, params, body, target any) error

	// Get data from server and parse to protoc file
	GetPROTOC(ctx context.Context, path string, params any, target protoreflect.ProtoMessage) error

	// PostPROTOC sends a POST request with protoc file and parse the response to protoc file
	PostPROTOC(ctx context.Context, path string, params, body protoreflect.ProtoMessage, target protoreflect.ProtoMessage) error
}

// A function that can send RESTful requests and receive response bodies.
// If specified, params should be encoded as query params for GET requests and as form data for POST and PUT requests.
// If specified, the body bytes should be sent as the body for POST and PUT requests.
// Returns the response body as bytes.
type SendRequest func(ctx context.Context, method string, path string, params any, body []byte) ([]byte, error)

// Opts are common Opts that instances of RESTClient may be configured with
type Opts struct {
	// HttpClient represents an http.Client that should be used by the resty client
	HttpClient *http.Client
	// UserConfig is a function that returns the user config associated with a Lantern user
	UserConfig func() common.UserConfig
}

type restClient struct {
	send SendRequest
}

// Construct a REST client using the given SendRequest function
func NewRESTClient(send SendRequest) RESTClient {
	return &restClient{send}
}

func (c *restClient) GetJSON(ctx context.Context, path string, params, target any) error {
	b, err := c.send(ctx, http.MethodGet, path, params, nil)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) GetPROTOC(ctx context.Context, path string, params any, target protoreflect.ProtoMessage) error {
	body, err := c.send(ctx, http.MethodGet, path, params, nil)
	if err != nil {
		return err
	}
	err1 := proto.Unmarshal(body, target)
	if err1 != nil {
		return err1
	}
	return nil

}

func (c *restClient) PostFormReadingJSON(ctx context.Context, path string, params, target any) error {
	b, err := c.send(ctx, http.MethodPost, path, params, nil)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) PostJSONReadingJSON(ctx context.Context, path string, params, body, target any) error {
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return err
	}
	b, err := c.send(ctx, http.MethodPost, path, params, bodyBytes)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) PostPROTOC(ctx context.Context, path string, params, body protoreflect.ProtoMessage, target protoreflect.ProtoMessage) error {
	bodyBytes, err := proto.Marshal(body)
	if err != nil {
		return err
	}
	bo, err := c.send(ctx, http.MethodPost, path, params, bodyBytes)
	if err != nil {
		log.Debugf("Error in sending request: %v", err)
		return err
	}
	err1 := proto.Unmarshal(bo, target)
	if err1 != nil {
		return err1
	}
	return nil
}

func unmarshalJSON(path string, b []byte, target any) error {
	err := json.Unmarshal(b, target)
	if err != nil {
		log.Errorf("Error unmarshalling JSON from %v: %v\n\n", path, err, string(b))
	}
	return err
}
