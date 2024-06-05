package pro

// Todo
// @Paul we might need to find way to use mock here rather calling actual api
// Using actual api will be slow and also it will created redundant data in db
// func TestClient(t *testing.T) {
// 	log := golog.LoggerFor("pro-http-test")
// 	client := NewClient("https://api.getiantem.org", &Opts{
// 		// Just use the default transport since otherwise test setup is difficult.
// 		// This means it does not actually touch the proxying code, but that should
// 		// be tested separately.
// 		HttpClient: &http.Client{},
// 		UserConfig: func() common.UserConfig {
// 			return common.NewUserConfig(
// 				"Lantern",
// 				"device123", // deviceID
// 				123,         // userID
// 				"token",     // token
// 				nil,
// 				"en", // language
// 			)
// 		},
// 	})
// 	res, e := client.Plans(context.Background())
// 	if !assert.NoError(t, e) {
// 		return
// 	}
// 	log.Debugf("Got response: %v", res)
// 	assert.NotNil(t, res)
// }

// func TestLinkValidate(t *testing.T) {
// 	log := golog.LoggerFor("pro-http-test")
// 	client := NewClient("https://api.getiantem.org", &Opts{
// 		// Just use the default transport since otherwise test setup is difficult.
// 		// This means it does not actually touch the proxying code, but that should
// 		// be tested separately.
// 		HttpClient: &http.Client{},
// 		UserConfig: func() common.UserConfig {
// 			return common.NewUserConfig(
// 				"Lantern",
// 				"device123", // deviceID
// 				123,         // userID
// 				"token",     // token
// 				nil,
// 				"en", // language
// 			)
// 		},
// 	})
// 	prepareRequestBody := &protos.ValidateRecoveryCodeRequest{
// 		Email: "jigar@getlanern.org",
// 		Code:  "123456",
// 	}
// 	res, e := client.ValidateEmailRecoveryCode(context.Background(), prepareRequestBody)
// 	if !assert.NoError(t, e) {
// 		return
// 	}
// 	log.Debugf("Got response: %v", res)
// 	assert.NotNil(t, res)
// }

// func TestSignUp(t *testing.T) {
// 	log := golog.LoggerFor("pro-http-test")
// 	client := NewClient("https://api.getiantem.org", &Opts{
// 		// Just use the default transport since otherwise test setup is difficult.
// 		// This means it does not actually touch the proxying code, but that should
// 		// be tested separately.
// 		HttpClient: &http.Client{},
// 		UserConfig: func() common.UserConfig {
// 			return common.NewUserConfig(
// 				"Lantern",
// 				"device123", // deviceID
// 				123,         // userID
// 				"token",     // token
// 				nil,
// 				"en", // language
// 			)
// 		},
// 	})
// 	prepareRequestBody := &protos.SignupRequest{
// 		Email:    "jigar@getlanern.org",
// 		Salt:     []byte("salt"),
// 		Verifier: []byte("verifier"),
// 	}
// 	res, e := client.SignUp(context.Background(), prepareRequestBody)
// 	if !assert.NoError(t, e) {
// 		return
// 	}
// 	log.Debugf("Got response: %v", res)
// 	assert.NotNil(t, res)
// }
