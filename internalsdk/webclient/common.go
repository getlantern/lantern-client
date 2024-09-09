package webclient

import (
	"strconv"

	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/go-resty/resty/v2"
)

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
	// Include all the internal headers
	for k, v := range uc.GetInternalHeaders() {
		if v != "" {
			params[k] = v
		}
	}
	req.SetHeaders(params)
}

// AddInternalHeaders adds the common.UserConfig internal headers to the given request
func AddInternalHeaders(uc common.UserConfig, req *resty.Request) {
	for k, v := range uc.GetInternalHeaders() {
		if v != "" {
			req.SetHeader(k, v)
		}
	}
}
