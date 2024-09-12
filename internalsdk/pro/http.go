package pro

import (
	"net/http"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
)

// NewHTTPClient creates a new http.Client that is configured to use the given options and http.RoundTripper wrapped with
// proxied.AsRoundTripper to process requests
func NewHTTPClient(rt http.RoundTripper, timeout time.Duration) *http.Client {
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	return &http.Client{
		Transport: proxied.AsRoundTripper(
			func(req *http.Request) (*http.Response, error) {
				log.Tracef("Pro client processing request to: %v (%v)", req.Host, req.URL.Host)
				return rt.RoundTrip(req)
			},
		),
		Timeout: timeout,
	}
}
