package pro

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"testing"
	"time"

	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"github.com/stretchr/testify/assert"
)

func TestPurchaseRequest(t *testing.T) {
	// Write your test code here
	// dialTimeout := 30 * time.Second
	//  curl -X 'POST' -d '' -H 'Access-Control-Allow-Headers: X-Lantern-Device-Id, X-Lantern-Pro-Token, X-Lantern-User-Id' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Lantern/7.6.87 (darwin/arm64) go-resty/2.13.1 (https://github.com/go-resty/resty)' -H 'X-Lantern-App: Lantern' -H 'X-Lantern-App-Version: 9999.99.99' -H 'X-Lantern-Device-Id: 81004e7f-c135-4fd2-96fd-588895b5fcd3' -H 'X-Lantern-Locale: en_US' -H 'X-Lantern-Platform: darwin' -H 'X-Lantern-Pro-Token: fFNNcUAf20uQdZ6ay_mZd9WkwUu22iD7hPQVxBDBhrTWOvwHS7T8ZQ' -H 'X-Lantern-Rand: mjatfmyzfzkuemszhlkixpzewbufcebocibycyqeqfquthvfktwqaqnpbrdsckdtlp' -H 'X-Lantern-Supported-Data-Caps: monthly weekly daily' -H 'X-Lantern-Time-Zone: Asia/Colombo' -H 'X-Lantern-User-Id: 372759893' -H 'X-Lantern-Version: 7.6.87' 'https://api.getiantem.org/purchase'
	webclientOpts := &webclient.Opts{
		// Use proxied.Fronted for IOS client since ChainedThenFronted it does not work with ios due to (chained proxy unavailable)
		// because we are not using the flashlight on ios
		// We need to figure out where to put proxied SetProxyAddr

		HttpClient: &http.Client{},
		UserConfig: func() common.UserConfig {
			deviceID := "c8484d35d019ae02"
			userID := int64(373643046)
			token := "2jnuNPf_ZqP-HFJKLkzvbd6rAf1x1M7NFChpjx9Ud2vP7WwpNYqurg"
			lang := "en_US"
			return common.NewUserConfig(
				common.DefaultAppName,
				deviceID,
				userID,
				token,
				nil,
				lang,
			)
		},
	}

	proClient := NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), webclientOpts)

	puchaseData := map[string]interface{}{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       "reseller-code",
		"email":          "jigar+seller@getlanern.org",
		"resellerCode":   "DKXTT-YHHT4-CD4M4-33726-4XT99",
		"device":         "Nokia 8.1",
		"currency":       "usd",
	}
	log.Debugf("DEBUG: Testing provider request: %v", puchaseData)

	_, err := proClient.PurchaseRequest(context.Background(), puchaseData)

	assert.NoError(t, err)
}

// Add more test functions as needed
