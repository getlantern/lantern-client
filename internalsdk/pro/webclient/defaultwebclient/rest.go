package defaultwebclient

import (
	"context"
	"net/http"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/pro/webclient"

	// "github.com/moul/http2curl"

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

	return func(ctx context.Context, method string, path string, reqParams any, header map[string]string, body []byte) ([]byte, error) {
		req := c.R().SetContext(ctx)

		if reqParams != nil {
			switch reqParams.(type) {
			case map[string]interface{}:
				params := reqParams.(map[string]interface{})
				stringParams := make(map[string]string, len(params))
				for key, value := range params {
					log.Debugf("key: %v, value: %v", key, value)
					stringParams[key] = value.(string)
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

		if header != nil {
			log.Debugf("header: %v", header)
			req.SetHeaders(header)
		}

		log.Debugf("method: %v, path: %v", method, path)
		resp, err := req.Execute(method, path)
		if err != nil {
			return nil, errors.New("we_are_experiencing_technical_difficulties Error sending request: %v", err)
		}
		// command, _ := http2curl.GetCurlCommand(req.RawRequest)
		// log.Debugf("curl command: %v", command)
		responseBody := resp.Body()
		log.Debugf("response body: %v status code %v", string(responseBody), resp.StatusCode())

		if resp.StatusCode() < 200 || resp.StatusCode() >= 300 {
			log.Errorf("Unexpected status code %d response body%v", resp.StatusCode(), string(responseBody))
			return nil, errors.New("Unexpected status code %d", resp.StatusCode())
		}
		return responseBody, nil
	}
}
