package webclient

import (
	"context"
	"encoding/json"
	"time"

	"fmt"
	"net/http"
	"unicode"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/go-resty/resty/v2"

	"github.com/moul/http2curl"
	"google.golang.org/protobuf/proto"
)

var (
	log = golog.LoggerFor("webclient")
)

const (
	ContentType               = "Content-Type"
	ContentTypeJSON           = "application/json"
	ContentTypeProtobuf       = "application/x-protobuf"
	ContentTypeFormURLEncoded = "application/x-www-form-urlencoded"
)

// Opts are common options that RESTClient may be configured with
type Opts struct {
	// The OnAfterResponse option sets response middleware
	OnAfterResponse resty.ResponseMiddleware
	// BaseURL is the primary URL the client is configured with
	BaseURL string
	// The OnBeforeRequest option appends the given request middleware into the before request chain.
	OnBeforeRequest resty.PreRequestHook
	// HttpClient represents an http.Client that should be used by the resty client
	HttpClient *http.Client
	// UserConfig is a function that returns the user config associated with a Lantern user
	UserConfig func() common.UserConfig
	// Timeout represents a time limit for requests made by the web client
	Timeout time.Duration
}

type RESTClient interface {
	// Gets a JSON document from the given path with the given querystring parameters, reading the result into target.
	GetJSON(ctx context.Context, path string, params, target any) error

	// Post the given parameters as form data and reads the result JSON into target.
	PostFormReadingJSON(ctx context.Context, path string, params, target any) error

	// Post the given body as JSON with the given querystring parameters and reads the result JSON into target.
	PostJSONReadingJSON(ctx context.Context, path string, params, body, target any) error

	// Get data from server and parse to protoc file
	GetPROTOC(ctx context.Context, path string, params any, target proto.Message) error

	// PostPROTOC sends a POST request with protoc file and parse the response to protoc file
	PostPROTOC(ctx context.Context, path string, params any, body proto.Message, target proto.Message) error
}

// A function that can send RESTful requests and receive response bodies.
// If specified, params should be encoded as query params for GET requests and as form data for POST and PUT requests.
// If specified, the body bytes should be sent as the body for POST and PUT requests.
// Returns the response body as bytes.
type SendRequest func(ctx context.Context, method string, path string, params any, body []byte, headers map[string]string) ([]byte, error)

type restClient struct {
	*resty.Client
	send SendRequest
}

// Construct a REST client using the given SendRequest function
func NewRESTClient(opts *Opts) RESTClient {
	if opts.HttpClient == nil {
		opts.HttpClient = &http.Client{}
	}
	c := resty.NewWithClient(opts.HttpClient)

	if opts.OnBeforeRequest != nil {
		c.SetPreRequestHook(opts.OnBeforeRequest)
	}
	if opts.OnAfterResponse != nil {
		c.OnAfterResponse(opts.OnAfterResponse)
	}
	if opts.BaseURL != "" {
		c.SetBaseURL(opts.BaseURL)
	}

	rc := &restClient{
		Client: c,
		// send executes an HTTP request with the specified method, path, parameters, and body
		// It applies any configured middleware (OnBeforeRequest) and response middleware (OnAfterResponse)
		send: func(ctx context.Context, method string, path string, reqParams any, body []byte, headers map[string]string) ([]byte, error) {

			req := c.R().SetContext(ctx)

			// Default headers
			if headers == nil {
				headers = map[string]string{}
			}
			if _, exists := headers[ContentType]; !exists {
				headers[ContentType] = ContentTypeJSON
			}
			for key, value := range headers {
				req.SetHeader(key, value)
			}

			// Process request parameters
			processParams(req, method, reqParams)

			resp, err := req.Execute(method, path)
			if err != nil {
				return nil, err
			}
			if common.IsDevEnvironment() {
				command, _ := http2curl.GetCurlCommand(req.RawRequest)
				log.Debugf("curl command: %v", command)
			}
			responseBody := sanitizeResponseBody(resp.Body())
			// on some cases, we are getting non-printable characters in the response body
			cleanedResponseBody := sanitizeResponseBody(responseBody)

			log.Debugf("response body: %v status code %v", string(cleanedResponseBody), resp.StatusCode())

			if resp.StatusCode() < 200 || resp.StatusCode() >= 300 {
				return nil, errors.New("%s status code %d", string(cleanedResponseBody), resp.StatusCode())
			}
			return responseBody, nil
		},
	}
	return rc
}

func processParams(req *resty.Request, method string, params any) {
	if params == nil {
		return
	}

	switch p := params.(type) {
	case map[string]any:
		stringParams := make(map[string]string, len(p))
		for key, value := range p {
			stringParams[key] = fmt.Sprint(value)
		}
		if method == http.MethodGet {
			req.SetQueryParams(stringParams)
		} else {
			req.SetFormData(stringParams)
		}
	default:
		req.SetBody(params)
	}
}

func sanitizeResponseBody(data []byte) []byte {
	var cleaned []byte
	for _, b := range data {
		if unicode.IsPrint(rune(b)) {
			cleaned = append(cleaned, b)
		}
	}
	return cleaned
}

func (c *restClient) GetJSON(ctx context.Context, path string, params, target any) error {
	b, err := c.send(ctx, http.MethodGet, path, params, nil, nil)
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) GetPROTOC(ctx context.Context, path string, params any, target proto.Message) error {
	body, err := c.send(ctx, http.MethodGet, path, params, nil, map[string]string{
		ContentType: ContentTypeProtobuf,
	})
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
	b, err := c.send(ctx, http.MethodPost, path, params, nil, map[string]string{
		ContentType: ContentTypeFormURLEncoded,
	})
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
	b, err := c.send(ctx, http.MethodPost, path, params, bodyBytes, map[string]string{
		ContentType: ContentTypeJSON,
	})
	if err != nil {
		return err
	}
	return unmarshalJSON(path, b, target)
}

func (c *restClient) PostPROTOC(ctx context.Context, path string, params any, body proto.Message, target proto.Message) error {
	bodyBytes, err := proto.Marshal(body)
	if err != nil {
		return err
	}

	bo, err := c.send(ctx, http.MethodPost, path, params, bodyBytes, map[string]string{
		ContentType: ContentTypeProtobuf,
	})
	if err != nil {
		return err
	}

	return proto.Unmarshal(bo, target)
}

func unmarshalJSON(path string, b []byte, target any) error {
	err := json.Unmarshal(b, target)
	if err != nil {
		log.Errorf("Error unmarshalling JSON from %v: %v\n\n", path, err, string(b))
	}
	return err
}
