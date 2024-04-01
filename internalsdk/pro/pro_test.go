package pro

import (
	"context"
	"net/http"
	"testing"

	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/stretchr/testify/assert"
)

func TestClient(t *testing.T) {
	log := golog.LoggerFor("pro-http-test")
	client := NewClient("https://api.getiantem.org", &Opts{
		// Just use the default transport since otherwise test setup is difficult.
		// This means it does not actually touch the proxying code, but that should
		// be tested separately.
		HttpClient: &http.Client{},
		Settings:   settings.EmptySettings(),
	})
	res, e := client.Plans(context.Background())
	if !assert.NoError(t, e) {
		return
	}
	log.Debugf("Got responsde: %v", res)
	assert.NotNil(t, res)
}
