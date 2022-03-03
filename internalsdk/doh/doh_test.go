package doh

import (
	"context"
	"net/http"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestMakeDohRequest(t *testing.T) {
	for _, tcase := range []struct {
		host string
	}{
		{host: "cloudflare.com"},
		{host: "amazon.com"},
		{host: "ft.com"},
	} {
		t.Run(tcase.host, func(t *testing.T) {
			ctx, cancelFunc := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancelFunc()
			httpClient := &http.Client{Timeout: time.Second * 10}
			resp, err := MakeDohRequest(ctx, httpClient, DnsDomain(tcase.host), TypeA)
			require.NoError(t, err)
			require.NotNil(t, resp)

			// Assert our results match those of dig
			cmd := exec.Command("dig", tcase.host, "+short")
			out, err := cmd.CombinedOutput()
			require.NoError(t, err)
			dnsRespFromDigArr := strings.Split(strings.TrimSpace(string(out)), "\n")
			for _, dohResp := range resp.Answer {
				require.Contains(t, dnsRespFromDigArr, dohResp.Data)
			}
		})
	}
}
