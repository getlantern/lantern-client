package pro

import (
	"net/http"
	"sync"
	"time"

	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
)

var (
	httpClient *http.Client
	once       sync.Once
)

// newHTTPClient creates a new http.Client that uses a proxied.AsRoundTripper to process requests
func newHTTPClient(opts *webclient.Opts) *http.Client {
	timeout := opts.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	return &http.Client{
		Transport: proxied.AsRoundTripper(
			func(req *http.Request) (*http.Response, error) {
				log.Tracef("Pro client processing request to: %v (%v)", req.Host, req.URL.Host)
				chained, err := proxied.ChainedNonPersistent("")
				if err != nil {
					return nil, log.Errorf("connecting to proxy: %w", err)
				}
				return chained.RoundTrip(req)
			},
		),
		Timeout: timeout,
	}
}

// GetHTTPClient creates a new http.Client that uses a proxied.AsRoundTripper to process requests
func GetHTTPClient(opts *webclient.Opts) *http.Client {
	if httpClient == nil {
		once.Do(func() {
			httpClient = newHTTPClient(opts)
		})
	}
	return httpClient
}
