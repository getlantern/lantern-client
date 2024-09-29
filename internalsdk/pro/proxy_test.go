package pro

// func TestProxy(t *testing.T) {
// 	uc := common.NewUserConfigData(common.DefaultAppName, "device", 0, "token", nil, "en-US")
// 	m := &testutils.MockRoundTripper{Header: http.Header{}, Body: strings.NewReader("GOOD")}
// 	// httpClient := &http.Client{Transport: m}
// 	l, err := net.Listen("tcp", "localhost:0")
// 	if !assert.NoError(t, err) {
// 		return
// 	}

// 	addr := l.Addr()
// 	url := fmt.Sprintf("http://%s/pro/abc", addr)
// 	t.Logf("Test server listening at %s", url)
// 	go http.Serve(l, APIHandler(addr.String(), uc))

// 	req, err := http.NewRequest("OPTIONS", url, nil)
// 	if !assert.NoError(t, err) {
// 		return
// 	}

// 	origin := "http://localhost:48933"
// 	req.Header.Set("Origin", origin)
// 	resp, err := (&http.Client{}).Do(req)
// 	if assert.NoError(t, err, "OPTIONS request should succeed") {
// 		assert.Equal(t, 200, resp.StatusCode, "should respond 200 to OPTIONS")
// 		assert.Equal(t, origin, resp.Header.Get("Access-Control-Allow-Origin"), "should respond with correct header")
// 		_ = resp.Body.Close()
// 	}
// 	assert.Nil(t, m.Req, "should not pass the OPTIONS request to origin server")

// 	req, err = http.NewRequest("GET", url, nil)
// 	if !assert.NoError(t, err) {
// 		return
// 	}
// 	req.Header.Set("Origin", origin)
// 	resp, err = (&http.Client{}).Do(req)
// 	if assert.NoError(t, err, "GET request should have no error") {
// 		assert.Equal(t, 200, resp.StatusCode, "should respond 200 ok")
// 		assert.Equal(t, origin, resp.Header.Get("Access-Control-Allow-Origin"), "should respond with correct header")
// 		assert.NotEmpty(t, resp.Header.Get("Access-Control-Allow-Methods"), "should respond with correct header")
// 		msg, _ := ioutil.ReadAll(resp.Body)
// 		_ = resp.Body.Close()
// 		assert.Equal(t, "GOOD", string(msg), "should respond expected body")
// 	}
// 	if assert.NotNil(t, m.Req, "should pass through non-OPTIONS requests to origin server") {
// 		t.Log(m.Req)
// 		assert.Equal(t, origin, resp.Header.Get("Access-Control-Allow-Origin"), "should respond with correct header")
// 		assert.NotEmpty(t, resp.Header.Get("Access-Control-Allow-Methods"), "should respond with correct header")
// 	}

// 	url = fmt.Sprintf("http://%s/pro/user-data", addr)
// 	msg, _ := json.Marshal(&protos.User{Email: "a@a.com"})
// 	m.Body = bytes.NewReader(msg)
// 	req, err = http.NewRequest("GET", url, nil)
// 	if !assert.NoError(t, err) {
// 		return
// 	}
// 	req.Header.Set("X-Lantern-User-Id", "1234")
// 	resp, err = (&http.Client{}).Do(req)
// 	if assert.NoError(t, err, "GET request should have no error") {
// 		assert.Equal(t, 200, resp.StatusCode, "should respond 200 ok")
// 	}
// }

// // APIHandler returns an HTTP handler that specifically looks for and properly handles pro server requests.
// func APIHandler(proAPIHost, proAPIPath string, userConfig common.UserConfig) http.Handler {
// 	log.Debugf("Returning pro API handler hitting host: %v", proAPIHost)
// 	return &httputil.ReverseProxy{
// 		Transport: &proxyTransport{},
// 		Director: func(r *http.Request) {
// 			// Strip /pro from path.
// 			if strings.HasPrefix(r.URL.Path, "/pro/") {
// 				r.URL.Path = r.URL.Path[4:]
// 			}
// 			prepareProRequest(r, proAPIHost, proAPIPath, userConfig)
// 		},
// 	}
// }
