package common

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

var allHeaders = []string{
	"Vary",
	"Access-Control-Allow-Origin",
	"Access-Control-Allow-Methods",
	"Access-Control-Allow-Headers",
	"Access-Control-Allow-Credentials",
	"Access-Control-Max-Age",
	"Access-Control-Expose-Headers",
}

type CorsSpec struct {
	name        string
	method      string
	uri         string
	reqHeaders  map[string]string
	respHeaders map[string]string
}

var testHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("test"))
})

func assertHeaders(t *testing.T, resHeaders http.Header, expHeaders map[string]string) {
	for _, name := range allHeaders {
		sort.Strings(resHeaders[name])
		got := strings.Join(resHeaders[name], ", ")
		want := expHeaders[name]
		if got != want {
			t.Errorf("Response header %q = %q, want %q", name, got, want)
		}
	}
}

func TestCORSMiddleware(t *testing.T) {
	uiAddr := "http://localhost:2000"
	cases := []CorsSpec{
		{
			"BadOrigin",
			http.MethodGet,
			"/login",
			map[string]string{
				"Origin": "http://baddomain.com",
			},
			map[string]string{
				"Vary":                        "",
				"Access-Control-Allow-Origin": "",
			},
		},
		{
			"AllowedOrigin",
			http.MethodGet,
			"/login",
			map[string]string{
				"Origin": uiAddr,
			},
			map[string]string{
				"Vary":                             "Origin",
				"Access-Control-Allow-Methods":     strings.Join([]string{"GET", "OPTIONS", "POST"}, ", "),
				"Access-Control-Allow-Credentials": "true",
				"Access-Control-Allow-Origin":      uiAddr,
			},
		},
	}
	for i := range cases {
		tc := cases[i]
		t.Run(tc.name, func(t *testing.T) {
			url := fmt.Sprintf("http://localhost%s", tc.uri)
			req, _ := http.NewRequest(tc.method, url,
				nil)
			for name, value := range tc.reqHeaders {
				req.Header.Add(name, value)
			}
			resp := httptest.NewRecorder()
			CORSMiddleware(testHandler).ServeHTTP(resp, req)
			assertHeaders(t, resp.Header(), tc.respHeaders)
		})
	}
}

func TestProcessCORS(t *testing.T) {

	// CORS headers in response to localhost origin
	resp := &http.Response{Header: http.Header{}}
	r, err := http.NewRequest(http.MethodGet, "http://test.com", nil)
	assert.NoError(t, err)
	origin := "http://localhost:47899"
	r.Header.Set("Origin", origin)
	ProcessCORS(resp.Header, r)

	assert.Equal(t, origin, resp.Header.Get("Access-Control-Allow-Origin"))
	methods := resp.Header.Values("Access-Control-Allow-Methods")
	sort.Strings(methods)
	assert.EqualValues(t, []string{"GET", "OPTIONS", "POST"}, methods)

	// CORS headers in response to 127.0.0.1 origin
	resp = &http.Response{Header: http.Header{}}
	r, err = http.NewRequest(http.MethodGet, "http://test.com", nil)
	assert.NoError(t, err)
	origin = "http://127.0.0.1:47899"
	r.Header.Set("Origin", origin)
	ProcessCORS(resp.Header, r)

	assert.Equal(t, origin, resp.Header.Get("Access-Control-Allow-Origin"))
	methods = resp.Header.Values("Access-Control-Allow-Methods")
	sort.Strings(methods)
	assert.Equal(t, []string{"GET", "OPTIONS", "POST"}, methods)

	// No CORS headers in response to public origin
	resp = &http.Response{Header: http.Header{}}
	r, err = http.NewRequest(http.MethodGet, "http://test.com", nil)
	assert.NoError(t, err)
	origin = "http://publicdomain:47899"
	r.Header.Set("Origin", origin)
	ProcessCORS(resp.Header, r)
	assert.Equal(t, "", resp.Header.Get("Access-Control-Allow-Origin"))

	// No CORS headers in response to no origin
	resp = &http.Response{Header: http.Header{}}
	r, err = http.NewRequest(http.MethodGet, "http://test.com", nil)
	assert.NoError(t, err)
	ProcessCORS(resp.Header, r)
	assert.Equal(t, "", resp.Header.Get("Access-Control-Allow-Origin"))
}
