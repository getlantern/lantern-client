package pro

import (
	"net/http"
	"sync"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
)

var (
	httpClient *http.Client
	once       sync.Once
)

// getHTTPClient creates a new http.Client that is configured to use the given options and http.RoundTripper wrapped with
// proxied.AsRoundTripper to process requests
func getHTTPClient(rt http.RoundTripper, timeout time.Duration) *http.Client {
	once.Do(func() {
		if httpClient == nil {
			httpClient = NewHTTPClient(rt, timeout)
		}
	})
	return httpClient
}

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
