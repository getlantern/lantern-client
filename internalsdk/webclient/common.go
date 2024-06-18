package webclient

import (
	"net/http"
	"strconv"

	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/go-resty/resty/v2"
)

// Opts are common Opts that instances of RESTClient may be configured with
type Opts struct {
	// HttpClient represents an http.Client that should be used by the resty client
	HttpClient *http.Client
	// UserConfig is a function that returns the user config associated with a Lantern user
	UserConfig func() common.UserConfig
}

// AddCommonUserHeaders adds all common headers that are user or device specific.
func AddCommonUserHeaders(uc common.UserConfig, req *resty.Request) {
	params := map[string]string{}
	if deviceID := uc.GetDeviceID(); deviceID != "" {
		params[common.DeviceIdHeader] = deviceID
	}
	if userID := strconv.FormatInt(uc.GetUserID(), 10); userID != "" && userID != "0" {
		params[common.UserIdHeader] = userID
	}
	if token := uc.GetToken(); token != "" {
		params[common.ProTokenHeader] = token
	}
	params[common.ContentType] = "application/json"
	// Include all the internal headers
	AddInternalHeaders(uc, req)
	req.SetHeaders(params)
}

func AddInternalHeaders(uc common.UserConfig, req *resty.Request) {
	for k, v := range uc.GetInternalHeaders() {
		if v != "" {
			req.SetHeader(k, v)
		}
	}
}
