package defaultwebclient

import (
	"context"
	"fmt"
	"net/http"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"

	"github.com/go-resty/resty/v2"
)

var (
	log = golog.LoggerFor("defaultwebclient")
)

// Create function that sends requests to the given URL, optionally sending them through a proxy,
// optionally processing requests with the given beforeRequest middleware and/or responses with the given afterResponse middleware.
func SendToURL(httpClient *http.Client, baseURL string, beforeRequest resty.RequestMiddleware, afterResponse resty.ResponseMiddleware) webclient.SendRequest {
	c := resty.NewWithClient(httpClient)
	if beforeRequest != nil {
		c.OnBeforeRequest(beforeRequest)
	}
	if afterResponse != nil {
		c.OnAfterResponse(afterResponse)
	}
	c.SetBaseURL(baseURL)

	return func(ctx context.Context, method string, path string, params map[string]interface{}, body []byte) ([]byte, error) {
		req := c.R().SetContext(ctx)
		if params != nil {
			stringParams := make(map[string]string, len(params))
			for key, value := range params {
				stringParams[key] = fmt.Sprint(value)
			}
			if method == http.MethodGet {
				req.SetQueryParams(stringParams)
			} else {
				req.SetFormData(stringParams)
			}
		} else if body != nil {
			req.Body = body
		}

		resp, err := req.Execute(method, path)
		if err != nil {
			return nil, err
		}
		responseBody := resp.Body()
		if resp.StatusCode() < 200 || resp.StatusCode() >= 300 {
			log.Errorf("Unexpected status code %d\n\n%v", resp.StatusCode(), string(responseBody))
			return nil, errors.New("Unexpected status code %d", resp.StatusCode())
		}
		return responseBody, nil
	}
}
