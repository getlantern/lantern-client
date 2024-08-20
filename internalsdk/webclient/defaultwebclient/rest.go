package defaultwebclient

import (
	"context"
	"fmt"
	"net/http"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"github.com/moul/http2curl"

	"github.com/go-resty/resty/v2"
)

var (
	log = golog.LoggerFor("defaultwebclient")
)

// Create function that sends requests to the given URL, optionally sending them through a proxy,
// optionally processing requests with the given beforeRequest middleware and/or responses with the given afterResponse middleware.
func SendToURL(httpClient *http.Client, baseURL string, beforeRequest resty.PreRequestHook, afterResponse resty.ResponseMiddleware) webclient.SendRequest {
	c := resty.NewWithClient(httpClient)
	if beforeRequest != nil {
		c.SetPreRequestHook(beforeRequest)
	}
	if afterResponse != nil {
		c.OnAfterResponse(afterResponse)
	}
	c.SetBaseURL(baseURL)

	return func(ctx context.Context, method string, path string, reqParams any, body []byte) ([]byte, error) {
		req := c.R().SetContext(ctx)
		if reqParams != nil {
			switch reqParams.(type) {
			case map[string]interface{}:
				params := reqParams.(map[string]interface{})
				stringParams := make(map[string]string, len(params))
				for key, value := range params {
					stringParams[key] = fmt.Sprint(value)
				}
				if method == http.MethodGet {
					req.SetQueryParams(stringParams)
				} else {
					req.SetFormData(stringParams)
				}
			default:
				req.SetBody(reqParams)
			}
		} else if body != nil {
			req.Body = body
		}

		resp, err := req.Execute(method, path)
		if err != nil {
			return nil, err
		}

		command, _ := http2curl.GetCurlCommand(req.RawRequest)
		log.Debugf("curl command: %v", command)
		responseBody := resp.Body()
		log.Debugf("response body: %v status code %v", string(responseBody), resp.StatusCode())

		if resp.StatusCode() < 200 || resp.StatusCode() >= 300 {
			// log.Errorf("Unexpected status code %d\n\n%v", resp.StatusCode(), string(responseBody))
			return nil, errors.New("%s Unexpected status code %d", string(responseBody), resp.StatusCode())
		}
		return responseBody, nil
	}
}
