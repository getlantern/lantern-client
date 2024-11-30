package pro

import (
	"net/http"
	"time"
)

// NewHTTPClient creates a new http.Client that is configured to use the given options and http.RoundTripper wrapped with
// proxied.AsRoundTripper to process requests
func NewHTTPClient(rt http.RoundTripper, timeout time.Duration) *http.Client {
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	return &http.Client{
		Transport: rt,
		Timeout:   timeout,
	}
}
