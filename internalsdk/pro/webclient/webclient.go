package webclient

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/getlantern/golog"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

var (
	log = golog.LoggerFor("webclient")
)

type RESTClient interface {
	// Gets a JSON document from the given path with the given querystring parameters, reading the result into target.
	GetJSON(ctx context.Context, path string, params, target any) error

	GetPROTOC(ctx context.Context, path string, params any, target protoreflect.ProtoMessage) error

	// Post the given parameters as form data and reads the result JSON into target.
	PostFormReadingJSON(ctx context.Context, path string, params, target any) error

	// Post the given body as JSON with the given querystring parameters and reads the result JSON into target.
	PostJSONReadingJSON(ctx context.Context, path string, params, body, target any) error
}

// A function that can send RESTful requests and receive response bodies.
// If specified, params should be encoded as query params for GET requests and as form data for POST and PUT requests.
// If specified, the body bytes should be sent as the body for POST and PUT requests.
// Returns the response body as bytes.
type SendRequest func(ctx context.Context, method string, path string, params any, header any, body []byte) ([]byte, error)

type restClient struct {
	send SendRequest
}

// Construct a REST client using the given SendRequest function
func NewRESTClient(send SendRequest) RESTClient {
	return &restClient{
		send: send,
	}
}

func (c *restClient) GetJSON(ctx context.Context, path string, params, target any) error {
	b, err := c.send(ctx, http.MethodGet, path, params, nil, nil)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) GetPROTOC(ctx context.Context, path string, params any, target protoreflect.ProtoMessage) error {
	header := make(map[string]string)
	header["Content-Type"] = "application/x-protobuf"
	body, err := c.send(ctx, http.MethodGet, path, params, header, nil)
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
	b, err := c.send(ctx, http.MethodPost, path, params, nil, nil)
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
	b, err := c.send(ctx, http.MethodPost, path, params, nil, bodyBytes)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func unmarshalJSON(path string, b []byte, target any) error {
	err := json.Unmarshal(b, target)
	if err != nil {
		log.Errorf("Error unmarshalling JSON from %v: %v\n\n", path, err, string(b))
	}
	return err
}
