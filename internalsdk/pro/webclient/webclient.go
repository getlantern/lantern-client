package webclient

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/getlantern/golog"
	"github.com/go-resty/resty/v2"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

var (
	log = golog.LoggerFor("webclient")
)

type RESTClient interface {
	// Gets a JSON document from the given path with the given querystring parameters, reading the result into target.
	GetJSON(ctx context.Context, path string, params, target any, header map[string]string) error

	// Get data from server and parse to protoc file
	GetPROTOC(ctx context.Context, path string, params any, target protoreflect.ProtoMessage, header map[string]string) error

	// Post the given parameters as form data and reads the result JSON into target.
	PostFormReadingJSON(ctx context.Context, path string, params, target any, header map[string]string) error

	// Post the given body as JSON with the given querystring parameters and reads the result JSON into target.
	PostJSONReadingJSON(ctx context.Context, path string, params, body, target any, header map[string]string) error

	// PostPROTOC sends a POST request with protoc file and parse the response to protoc file
	PostPROTOC(ctx context.Context, path string, params, body protoreflect.ProtoMessage, target protoreflect.ProtoMessage, header map[string]string) error
}

// A function that can send RESTful requests and receive response bodies.
// If specified, params should be encoded as query params for GET requests and as form data for POST and PUT requests.
// If specified, the body bytes should be sent as the body for POST and PUT requests.
// Returns the response body as bytes.
type SendRequest func(ctx context.Context, method string, path string, params any, header map[string]string, body []byte) ([]byte, error)

type restClient struct {
	send SendRequest
}

// Construct a REST client using the given SendRequest function
func NewRESTClient(send SendRequest) RESTClient {
	return &restClient{
		send: send,
	}
}

func (c *restClient) GetJSON(ctx context.Context, path string, params, target any, header map[string]string) error {
	b, err := c.send(ctx, http.MethodGet, path, params, header, nil)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) GetPROTOC(ctx context.Context, path string, params any, target protoreflect.ProtoMessage, header map[string]string) error {
	if header == nil {
		header = make(map[string]string)
	}
	header["Content-Type"] = "application/x-protobuf"
	body, err := c.send(ctx, resty.MethodGet, path, params, header, nil)
	if err != nil {
		return err
	}
	err1 := proto.Unmarshal(body, target)
	if err1 != nil {
		return err1
	}
	return nil

}

func (c *restClient) PostFormReadingJSON(ctx context.Context, path string, params, target any, header map[string]string) error {
	b, err := c.send(ctx, http.MethodPost, path, params, header, nil)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) PostJSONReadingJSON(ctx context.Context, path string, params, body, target any, header map[string]string) error {
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return err
	}
	b, err := c.send(ctx, http.MethodPost, path, params, header, bodyBytes)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) PostPROTOC(ctx context.Context, path string, params, body protoreflect.ProtoMessage, target protoreflect.ProtoMessage, header map[string]string) error {
	bodyBytes, err := proto.Marshal(body)
	if err != nil {
		return err
	}
	if header == nil {
		header = make(map[string]string)
	}
	header["Content-Type"] = "application/x-protobuf"
	bo, err := c.send(ctx, http.MethodPost, path, params, header, bodyBytes)
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
