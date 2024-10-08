package pro

import (
	"bytes"
	"compress/gzip"
	"encoding/json"
	"io"
	"io/ioutil"
	"net/http"
	"net/http/httputil"
	"strconv"
	"strings"
	"time"

	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

type proxyTransport struct {
	// Satisfies http.RoundTripper
}

func (pt *proxyTransport) processOptions(req *http.Request) *http.Response {
	resp := &http.Response{
		StatusCode: http.StatusOK,
		Header: http.Header{
			"Connection": {"keep-alive"},
			"Via":        {"Lantern Client"},
		},
		Body: ioutil.NopCloser(strings.NewReader("preflight complete")),
	}
	if !common.ProcessCORS(resp.Header, req) {
		return &http.Response{
			StatusCode: http.StatusForbidden,
		}
	}
	return resp
}

func (pt *proxyTransport) RoundTrip(req *http.Request) (resp *http.Response, err error) {
	if req.Method == "OPTIONS" {
		// No need to proxy the OPTIONS request.
		return pt.processOptions(req), nil
	}
	origin := req.Header.Get("Origin")
	// Workaround for https://github.com/getlantern/pro-server/issues/192
	req.Header.Del("Origin")
	resp, err = NewHTTPClient(http.DefaultTransport, time.Duration(time.Second*30)).Do(req)
	if err != nil {
		log.Errorf("Could not issue HTTP request? %v", err)
		return
	}

	// Put the header back for subsequent CORS processing.
	req.Header.Set("Origin", origin)
	common.ProcessCORS(resp.Header, req)
	if req.URL.Path != "/user-data" || resp.StatusCode != http.StatusOK {
		return
	}
	// Try to update user data implicitly
	_userID := req.Header.Get("X-Lantern-User-Id")
	if _userID == "" {
		log.Error("Request has an empty user ID")
		return
	}
	userID, parseErr := strconv.ParseInt(_userID, 10, 64)
	if parseErr != nil {
		log.Errorf("User ID %s is invalid", _userID)
		return
	}
	body, readErr := ioutil.ReadAll(resp.Body)
	if readErr != nil {
		log.Errorf("Error read response body: %v", readErr)
		return
	}
	resp.Body = ioutil.NopCloser(bytes.NewReader(body))
	encoding := resp.Header.Get("Content-Encoding")
	var br io.Reader = bytes.NewReader(body)
	switch encoding {
	case "gzip":
		gzr, readErr := gzip.NewReader(bytes.NewReader(body))
		if readErr != nil {
			log.Errorf("Unable to decode gzipped data: %v", readErr)
			return
		}
		br = gzr
	case "":
	default:
		log.Errorf("Unsupported response encoding %s", encoding)
		return
	}
	user := protos.User{}
	readErr = json.NewDecoder(br).Decode(&user)
	if readErr != nil {
		log.Errorf("Error decoding JSON: %v", readErr)
		return
	}
	log.Debugf("Updating user data implicitly for user %v", userID)
	return
}

// APIHandler returns an HTTP handler that specifically looks for and properly handles pro server requests.
func APIHandler(proAPIHost string, userConfig common.UserConfig) http.Handler {
	log.Debugf("Returning pro API handler hitting host: %v", proAPIHost)
	return &httputil.ReverseProxy{
		Transport: &proxyTransport{},
		Director: func(r *http.Request) {
			// Strip /pro from path.
			if strings.HasPrefix(r.URL.Path, "/pro/") {
				r.URL.Path = r.URL.Path[4:]
			}
			prepareProRequest(r, proAPIHost, userConfig)
		},
	}
}
