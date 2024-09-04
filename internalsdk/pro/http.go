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
	log.Debug("Creating new HTTP client")
	rt, err := proxied.ChainedNonPersistent("")
	if err != nil {
		log.Fatal(err)
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

// GetHTTPClient returns an http.Client that uses a proxied.AsRoundTripper to process requests
func GetHTTPClient(opts *webclient.Opts) *http.Client {
	once.Do(func() {
		if httpClient == nil {
			httpClient = newHTTPClient(opts)
		}
	})
	return httpClient
}
