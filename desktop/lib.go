// filename: lib.go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"runtime/debug"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"github.com/getlantern/osversion"
	"github.com/joho/godotenv"

	"google.golang.org/protobuf/encoding/protojson"
)

import "C"

const (
	defaultLocale = "en-US"
)

var (
	log        = golog.LoggerFor("lantern-desktop.main")
	a          *app.App
	proClient  proclient.ProClient
	authClient auth.AuthClient
)

var issueMap = map[string]string{
	"Cannot access blocked sites": "3",
	"Cannot complete purchase":    "0",
	"Cannot sign in":              "1",
	"Spinner loads endlessly":     "2",
	"Slow":                        "4",
	"Chat not working":            "7",
	"Discover not working":        "8",
	"Cannot link device":          "5",
	"Application crashes":         "6",
	"Other":                       "9",
}

//export start
func start() {
	runtime.LockOSThread()
	// Since Go 1.6, panic prints only the stack trace of current goroutine by
	// default, which may not reveal the root cause. Switch to all goroutines.
	debug.SetTraceback("all")

	// Load application configuration from .env file
	err := godotenv.Load()
	if err != nil {
		log.Error("Error loading .env file")
	}

	flags := flashlight.ParseFlags()

	cdir := configDir(&flags)
	settings := loadSettings(cdir)
	webclientOpts := &webclient.Opts{
		HttpClient: &http.Client{
			Transport: proxied.ParallelPreferChained(),
			Timeout:   30 * time.Second,
		},
		UserConfig: func() common.UserConfig {
			return userConfig(settings)
		},
	}
	proClient = proclient.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), webclientOpts)
	authClient = auth.NewClient(fmt.Sprintf("https://%s", common.V1BaseUrl), webclientOpts)

	a = app.NewApp(flags, cdir, proClient, settings)
	go func() {
		err := fetchOrCreate()
		if err != nil {
			log.Error(err)
		}
	}()

	go fetchUserData()

	go func() {
		err := fetchPayentMethodV4()
		if err != nil {
			log.Error(err)
		}
	}()

	logging.EnableFileLogging(common.DefaultAppName, appdir.Logs(common.DefaultAppName))

	go func() {
		tk := time.NewTicker(time.Minute)
		for {
			<-tk.C
			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			if err := a.ProxyAddrReachable(ctx); err != nil {
				log.Debugf("********* ERROR: Lantern HTTP proxy not working properly: %v\n", err)
			} else {
				log.Debugf("DEBUG: Lantern HTTP proxy is working fine")
			}
			cancel()
		}
	}()

	golog.SetPrepender(logging.Timestamped)
	handleSignals(a)

	go func() {
		defer logging.Close()
		// i18nInit(a)
		a.Run(true)

		err := a.WaitForExit()
		if err != nil {
			log.Errorf("Lantern stopped with error %v", err)
			os.Exit(-1)
		}
		log.Debug("Lantern stopped")
		os.Exit(0)
	}()
}

func fetchUserData() error {
	user, err := getUserData()
	if err != nil {
		return log.Errorf("error while fetching user data: %v", err)
	}
	return cacheUserDetail(user)
}

func cacheUserDetail(userDetail *protos.User) error {
	if userDetail.Email != "" {
		a.Settings().SetEmailAddress(userDetail.Email)
	}
	//Save user refferal code
	if userDetail.Referral != "" {
		a.SetReferralCode(userDetail.Referral)
	}
	// err := setUserLevel(session.baseModel, userDetail.UserLevel)
	// if err != nil {
	// 	return err
	// }

	err := setExpiration(userDetail.Expiration)
	if err != nil {
		return err
	}
	currentDevice := getDeviceID()
	log.Debugf("Current device %v", currentDevice)

	// Check if device id is connect to same device if not create new user
	// this is for the case when user removed device from other device
	deviceFound := false
	if userDetail.Devices != nil {
		for _, device := range userDetail.Devices {
			if device.Id == currentDevice {
				deviceFound = true
				break
			}
		}
	}
	log.Debugf("Device found %v", deviceFound)
	/// Check if user has installed app first time
	firstTime := a.Settings().GetUserFirstVisit()
	log.Debugf("First time visit %v", firstTime)
	if userDetail.UserLevel == "pro" && firstTime {
		log.Debugf("User is pro and first time")
		setProUser(true)
	} else if userDetail.UserLevel == "pro" && !firstTime && deviceFound {
		log.Debugf("User is pro and not first time")
		setProUser(true)
	} else {
		log.Debugf("User is not pro")
		setProUser(false)
	}

	a.Settings().SetUserIDAndToken(userDetail.UserId, userDetail.Token)
	log.Debugf("User caching successful: %+v", userDetail)
	// Save data in userData cache
	app.SetUserData(context.Background(), userDetail.UserId, userDetail)
	return nil
}

func getDeviceID() string {
	return a.Settings().GetDeviceID()
}

func setExpiration(expiration int64) error {
	if expiration == 0 {
		return log.Errorf("Expiration date is 0")
	}
	expiry := time.Unix(0, expiration*int64(time.Second))
	dateFormat := "01/02/2006"
	dateStr := expiry.Format(dateFormat)
	a.Settings().SetExpirationDate(dateStr)
	return nil
}

func setProUser(isPro bool) {
	a.Settings().SetProUser(isPro)
	a.SendMessageToUI("pro", map[string]interface{}{
		"isProUser": isPro,
	})
}

func saveUserSalt(salt []byte) {
	a.Settings().SaveSalt(salt)
}

//export hasProxyFected
func hasProxyFected() *C.char {
	if a.GetHasProxyFetched() {
		return C.CString(string("true"))
	}
	return C.CString(string("false"))
}

//export hasConfigFected
func hasConfigFected() *C.char {
	if a.GetHasConfigFetched() {
		return C.CString(string("true"))
	}
	return C.CString(string("false"))
}

//export onSuccess
func onSuccess() *C.char {
	if a.GetOnSuccess() {
		return C.CString(string("true"))
	}
	return C.CString(string("false"))
}

func userCreate() error {
	// User is new
	user, err := proClient.UserCreate(context.Background())
	if err != nil {
		return errors.New("Could not create new Pro user: %v", err)
	}
	log.Debugf("DEBUG: User created: %v", user)
	if user.BaseResponse != nil && user.BaseResponse.Error != "" {
		return errors.New("Could not create new Pro user: %v", err)
	}
	a.Settings().SetUserIDAndToken(user.UserId, user.Token)

	return nil
}

func fetchOrCreate() error {
	settings := a.Settings()
	settings.SetLanguage("en_us")
	userID := settings.GetUserID()
	if userID == 0 {
		a.Settings().SetUserFirstVisit(true)
		err := userCreate()
		if err != nil {
			return err
		}
		// if the user is new mean we need to fetch the payment methods
		fetchPayentMethodV4()
	}
	return nil
}
func fetchPayentMethodV4() error {
	settings := a.Settings()
	userID := settings.GetUserID()
	if userID == 0 {
		return errors.New("User ID is not set")
	}
	resp, err := proClient.PaymentMethodsV4(context.Background())
	if err != nil {
		return errors.New("Could not get payment methods: %v", err)
	}
	log.Debugf("DEBUG: Payment methods: %+v", resp)
	log.Debugf("DEBUG: Payment methods providers: %+v", resp.Providers)
	bytes, err := json.Marshal(resp)
	if err != nil {
		return errors.New("Could not marshal payment methods: %v", err)
	}
	settings.SetPaymentMethodPlans(bytes)
	return nil
}

//export sysProxyOn
func sysProxyOn() {
	go a.SysproxyOn()
}

//export sysProxyOff
func sysProxyOff() {
	go a.SysProxyOff()
}

//export websocketAddr
func websocketAddr() *C.char {
	return C.CString(a.WebsocketAddr())
}

//export plans
func plans() *C.char {
	settings := a.Settings()
	plans := settings.GetPaymentMethods()
	if plans == nil {
		return sendError(errors.New("plans not found"))
	}
	paymentMethodsResponse := &proclient.PaymentMethodsResponse{}
	err := json.Unmarshal(plans, paymentMethodsResponse)
	plansByte, err := json.Marshal(paymentMethodsResponse.Plans)
	if err != nil {
		return sendError(errors.New("error fetching payment methods: %v", err))
	}
	return C.CString(string(plansByte))
}

//export paymentMethodsV3
func paymentMethodsV3() *C.char {
	resp, err := proClient.PaymentMethods(context.Background())
	if err != nil {
		return sendError(errors.New("error fetching payment methods: %v", err))
	}
	b, _ := json.Marshal(resp.Providers)
	return C.CString(string(b))
}

//export paymentMethodsV4
func paymentMethodsV4() *C.char {
	settings := a.Settings()
	plans := settings.GetPaymentMethods()
	if plans == nil {
		return sendError(errors.New("Payment methods not found"))
	}
	paymentMethodsResponse := &proclient.PaymentMethodsResponse{}
	err := json.Unmarshal(plans, paymentMethodsResponse)
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(paymentMethodsResponse)
	return C.CString(string(b))
}

func cachedUserData() (*protos.User, bool) {
	uc := userConfig(a.Settings())
	return app.GetUserDataFast(context.Background(), uc.GetUserID())
}

func getUserData() (*protos.User, error) {
	resp, err := proClient.UserData(context.Background())
	if err != nil {
		return nil, err
	}
	if resp.User == nil {
		return nil, errors.New("User data not found")
	}
	user := resp.User
	cacheUserDetail(user)
	return user, nil
}

//export proxyAll
func proxyAll() *C.char {
	proxyAll := a.Settings().GetProxyAll()
	if proxyAll {
		return C.CString("true")
	}
	return C.CString("false")
}

//export setProxyAll
func setProxyAll(value *C.char) {
	proxyAll, _ := strconv.ParseBool(C.GoString(value))
	go a.Settings().SetProxyAll(proxyAll)
}

// tryCacheUserData retrieves the latest user data for the given user.
// It first checks the cache and if present returns the user data stored there
// func tryCacheUserData() (*protos.User, error) {
// 	if cacheUserData, isOldFound := cachedUserData(); isOldFound {
// 		return cacheUserData, nil
// 	}
// 	return getUserData()
// }

// this method is reposible for checking if the user has updated plan or bought plans
//
//export hasPlanUpdatedOrBuy
func hasPlanUpdatedOrBuy() *C.char {
	//Get the cached user data
	log.Debugf("DEBUG: Checking if user has updated plan or bought new plan")
	cacheUserData, isOldFound := cachedUserData()
	//Get latest user data
	resp, err := proClient.UserData(context.Background())
	if err != nil {
		return sendError(err)
	}
	if isOldFound {
		if cacheUserData.Expiration < resp.User.Expiration {
			// New data has a later expiration
			// if foud then update the cache
			cacheUserDetail(resp.User)
			return C.CString(string("true"))
		}
	}
	return C.CString(string("false"))
}

//export devices
func devices() *C.char {
	user, found := cachedUserData()
	if !found {
		// for now just return empty array
		b, _ := json.Marshal("[]")
		return C.CString(string(b))
	}
	b, _ := json.Marshal(user.Devices)
	return C.CString(string(b))
}

func sendJson(resp any) *C.char {
	b, _ := json.Marshal(resp)
	return C.CString(string(b))
}

func sendError(err error) *C.char {
	if err == nil {
		return C.CString("")
	}
	return sendJson(map[string]interface{}{
		"error": err.Error(),
	})
}

//export approveDevice
func approveDevice(code *C.char) *C.char {
	resp, err := proClient.LinkCodeApprove(context.Background(), C.GoString(code))
	if err != nil {
		return sendError(err)
	}
	return sendJson(resp)
}

//export removeDevice
func removeDevice(deviceId *C.char) *C.char {
	resp, err := proClient.DeviceRemove(context.Background(), C.GoString(deviceId))
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	return sendJson(resp)
}

//export expiryDate
func expiryDate() *C.char {
	user, found := cachedUserData()
	if !found {
		return sendError(log.Errorf("User data not found"))
	}
	tm := time.Unix(user.Expiration, 0)
	exp := tm.Format("01/02/2006")
	return C.CString(string(exp))
}

//export userData
func userData() *C.char {
	user, err := getUserData()
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(user)
	return C.CString(string(b))
}

//export serverInfo
func serverInfo() *C.char {
	stats := a.Stats()
	if stats == nil {
		return C.CString("")
	}
	serverInfo := &protos.ServerInfo{
		City:        stats.City,
		Country:     stats.Country,
		CountryCode: stats.CountryCode,
	}
	b, _ := protojson.Marshal(serverInfo)
	return C.CString(string(b))
}

//export emailAddress
func emailAddress() *C.char {
	return C.CString(a.Settings().GetEmailAddress())
}

//export emailExists
func emailExists(email *C.char) *C.char {
	_, err := proClient.EmailExists(context.Background(), C.GoString(email))
	if err != nil {
		return sendError(err)
	}
	return C.CString("false")
}

//export testProviderRequest
func testProviderRequest(email *C.char, paymentProvider *C.char, plan *C.char) *C.char {
	puchaseData := map[string]interface{}{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       C.GoString(paymentProvider),
		"email":          C.GoString(email),
		"plan":           C.GoString(plan),
	}
	_, err := proClient.PurchaseRequest(context.Background(), puchaseData)
	if err != nil {
		return sendError(err)
	}
	setProUser(true)
	getUserData()
	return C.CString("true")
}

// The function returns two C strings: the first represents success, and the second represents an error.
// If the redemption is successful, the first string contains "true", and the second string is nil.
// If an error occurs during redemption, the first string is nil, and the second string contains the error message.
//
//export redeemResellerCode
func redeemResellerCode(email, currency, deviceName, resellerCode *C.char) *C.char {
	response, err := proClient.RedeemResellerCode(context.Background(), &protos.RedeemResellerCodeRequest{
		Currency:       C.GoString(currency),
		DeviceName:     C.GoString(deviceName),
		Email:          C.GoString(email),
		IdempotencyKey: strconv.FormatInt(time.Now().UnixMilli(), 10),
		ResellerCode:   C.GoString(resellerCode),
		Provider:       "reseller-code",
	})
	log.Debugf("DEBUG: redeeming reseller code response: %v", response)
	if response.Error != "" {
		log.Debugf("DEBUG: error while redeeming reseller code reponse is: %v", response.Error)
		return sendError(errors.New("Error while redeeming reseller code: %v", response.Error))
	}
	if err != nil {
		log.Debugf("DEBUG: error while redeeming reseller code: %v", err)
		return sendError(err)
	}
	log.Debug("DEBUG: redeeming reseller code success")
	return C.CString("true")
}

//export referral
func referral() *C.char {
	referralCode, err := a.ReferralCode(userConfig(a.Settings()))
	if err != nil {
		return sendError(err)
	}
	return C.CString(referralCode)
}

//export myDeviceId
func myDeviceId() *C.char {
	deviceId := getDeviceID()
	return C.CString(deviceId)
}

//export chatEnabled
func chatEnabled() *C.char {
	return C.CString("false")
}

//export playVersion
func playVersion() *C.char {
	return C.CString("false")
}

//export storeVersion
func storeVersion() *C.char {
	return C.CString("false")
}

//export lang
func lang() *C.char {
	lang := a.GetLanguage()
	log.Debugf("DEBUG: Language is %v", lang)
	if lang == "" {
		// Default language is English
		lang = defaultLocale
	}
	return C.CString(lang)
}

//export setSelectLang
func setSelectLang(lang *C.char) {
	a.SetLanguage(C.GoString(lang))
	// update the payment methods if the language is changed
	go func() {
		err := fetchPayentMethodV4()
		if err != nil {
			log.Error(err)
		}
	}()
}

//export country
func country() *C.char {
	country := a.Settings().GetCountry()
	return C.CString(country)
}

//export sdkVersion
func sdkVersion() *C.char {
	version := common.LibraryVersion
	return C.CString(version)
}

//export vpnStatus
func vpnStatus() *C.char {
	if a.IsSysProxyOn() {
		return C.CString("connected")
	}
	return C.CString("disconnected")
}

//export hasSucceedingProxy
func hasSucceedingProxy() *C.char {
	hasSucceedingProxy := a.HasSucceedingProxy()
	if hasSucceedingProxy {
		return C.CString("true")
	}
	return C.CString("false")
}

//export onBoardingStatus
func onBoardingStatus() *C.char {
	return C.CString("true")
}

//export acceptedTermsVersion
func acceptedTermsVersion() *C.char {
	return C.CString("0")
}

//export proUser
func proUser() *C.char {
	// // refresh user data when home page is loaded on desktop
	// go getUserData()
	uc := a.Settings()
	if uc.IsProUser() {
		return C.CString("true")
	}
	// if isProUser, ok := app.IsProUserFast(ctx, uc); isProUser && ok {
	// 	return C.CString("true")
	// }
	return C.CString("false")
}

func deviceName() string {
	deviceName, _ := osversion.GetHumanReadable()
	return deviceName
}

//export deviceLinkingCode
func deviceLinkingCode() *C.char {
	resp, err := proClient.LinkCodeRequest(context.Background(), deviceName())
	if err != nil {
		return sendError(err)
	}
	return C.CString(resp.Code)
}

//export paymentRedirect
func paymentRedirect(planID, currency, provider, email, deviceName *C.char) *C.char {
	country := a.Settings().GetCountry()
	resp, err := proClient.PaymentRedirect(context.Background(), &protos.PaymentRedirectRequest{
		Plan:        C.GoString(planID),
		Provider:    C.GoString(provider),
		Currency:    strings.ToUpper(C.GoString(currency)),
		Email:       C.GoString(email),
		DeviceName:  C.GoString(deviceName),
		CountryCode: country,
	})
	if err != nil {
		return sendError(err)
	}
	return sendJson(resp)
}

//export exitApp
func exitApp() {
	a.Exit(nil)
}

//export developmentMode
func developmentMode() *C.char {
	return C.CString("false")
}

//export splitTunneling
func splitTunneling() *C.char {
	return C.CString("false")
}

//export chatMe
func chatMe() *C.char {
	return C.CString("false")
}

//export replicaAddr
func replicaAddr() *C.char {
	return C.CString("")
}

func userConfig(settings *settings.Settings) common.UserConfig {
	userID, deviceID, token := settings.GetUserID(), settings.GetDeviceID(), settings.GetToken()
	return common.NewUserConfig(
		common.DefaultAppName,
		deviceID,
		userID,
		token,
		nil,
		settings.GetLanguage(),
	)
}

//export reportIssue
func reportIssue(email, issueType, description *C.char) *C.char {
	issueTypeStr := C.GoString(issueType)
	deviceID := a.Settings().GetDeviceID()
	issueIndex := issueMap[issueTypeStr]
	issueTypeInt, err := strconv.Atoi(issueIndex)
	if err != nil {
		log.Errorf("Error converting issue type to int: %v", err)
		return sendError(err)
	}
	ctx := context.Background()
	uc := userConfig(a.Settings())

	subscriptionLevel := "free"
	if isProUser, ok := app.IsProUserFast(ctx, uc); ok && isProUser {
		subscriptionLevel = "pro"
	}

	var osVersion string
	osVersion, err = osversion.GetHumanReadable()
	if err != nil {
		log.Errorf("Unable to get version: %v", err)
	}
	log.Debug("Sending issue report")
	err = issue.SendReport(
		uc,
		issueTypeInt,
		C.GoString(description),
		subscriptionLevel,
		C.GoString(email),
		common.ApplicationVersion,
		deviceID,
		osVersion,
		"",
		nil,
	)
	if err != nil {
		return sendError(err)
	}
	log.Debug("Successfully reported issue")
	return C.CString("true")
}

//export checkUpdates
func checkUpdates() *C.char {
	log.Debug("Checking for updates")
	settings := a.Settings()
	userID := settings.GetUserID()
	deviceID := settings.GetDeviceID()
	op := ops.Begin("check_update").
		Set("user_id", userID).
		Set("device_id", deviceID).
		Set("current_version", common.ApplicationVersion)
	defer op.End()
	updateURL, err := autoupdate.CheckUpdates()
	if err != nil {
		log.Errorf("Error checking for update: %v", err)
		return sendError(err)
	}
	log.Debugf("Auto-update URL is %s", updateURL)
	return C.CString(updateURL)
}

// loadSettings loads the initial settings at startup, either from disk or using defaults.
func loadSettings(configDir string) *settings.Settings {
	path := filepath.Join(configDir, "settings.yaml")
	if common.IsStagingEnvironment() {
		path = filepath.Join(configDir, "settings-staging.yaml")
	}
	settings := settings.LoadSettingsFrom(common.ApplicationVersion, common.RevisionDate, common.BuildDate, path)
	if common.IsStagingEnvironment() {
		settings.SetUserIDAndToken(9007199254740992, "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA")
	}
	return settings
}

func configDir(flags *flashlight.Flags) string {
	cdir := flags.ConfigDir
	if cdir == "" {
		cdir = appdir.General(common.DefaultAppName)
	}
	log.Debugf("Using config dir %v", cdir)
	if _, err := os.Stat(cdir); err != nil {
		if os.IsNotExist(err) {
			// Create config dir
			if err := os.MkdirAll(cdir, 0750); err != nil {
				log.Errorf("Unable to create configdir at %s: %s", configDir, err)
			}
		}
	}
	return cdir
}

// useOSLocale detect OS locale for current user and let i18n to use it
func useOSLocale() (string, error) {
	userLocale, err := jibber_jabber.DetectIETF()
	if err != nil || userLocale == "C" {
		log.Debugf("Ignoring OS locale and using default")
		userLocale = defaultLocale
	}
	log.Debugf("Using OS locale of current user: %v", userLocale)
	a.SetLanguage(userLocale)
	return userLocale, nil
}

//Do not need to call this function
// Since localisation is happing on client side
// func i18nInit(a *app.App) {
// 	i18n.SetMessagesFunc(func(filename string) ([]byte, error) {
// 		return a.GetTranslations(filename)
// 	})
// 	locale := a.GetLanguage()
// 	log.Debugf("Using locale: %v", locale)
// 	if _, err := i18n.SetLocale(locale); err != nil {
// 		log.Debugf("i18n.SetLocale(%s) failed, fallback to OS default: %q", locale, err)

// 		// On startup GetLanguage will return '' We use the OS locale instead and make sure the language is
// 		// populated.
// 		if locale, err := useOSLocale(); err != nil {
// 			log.Debugf("i18n.UseOSLocale: %q", err)
// 			a.SetLanguage(defaultLocale)
// 		} else {
// 			a.SetLanguage(locale)
// 		}
// 	}
// }

// Handle system signals for clean exit
func handleSignals(a *app.App) {
	c := make(chan os.Signal, 1)
	signal.Notify(c,
		syscall.SIGHUP,
		syscall.SIGINT,
		syscall.SIGTERM,
		syscall.SIGQUIT)
	go func() {
		s := <-c
		log.Debugf("Got signal \"%s\", exiting...", s)
		a.Exit(nil)
	}()
}

// Auth Methods

//export isUserFirstTime
func isUserFirstTime() *C.char {
	firstVist := a.Settings().GetUserFirstVisit()
	stringValue := fmt.Sprintf("%t", firstVist)
	return C.CString(stringValue)
}

//export setFirstTimeVisit
func setFirstTimeVisit() {
	a.Settings().SetUserFirstVisit(false)
}

//export isUserLoggedIn
func isUserLoggedIn() *C.char {
	loggedIn := a.IsUserLoggedIn()
	stringValue := fmt.Sprintf("%t", loggedIn)
	log.Debugf("User logged in %v", stringValue)
	return C.CString(stringValue)
}

func getUserSalt(email string) ([]byte, error) {
	lowerCaseEmail := strings.ToLower(email)
	salt := a.Settings().GetSalt()
	if len(salt) == 16 {
		log.Debugf("salt return from cache %v", salt)
		return salt, nil
	}
	log.Debugf("Salt not found calling api for %s", email)
	saltResponse, err := authClient.GetSalt(context.Background(), lowerCaseEmail)
	if err != nil {
		return nil, err
	}
	log.Debugf("Salt Response-> %v", saltResponse.Salt)
	return saltResponse.Salt, nil

}

// Authenticates the user with the given email and password.
//
//	Note-: On Sign up Client needed to generate 16 byte slat
//	Then use that salt, password and email generate encryptedKey once you created encryptedKey pass it to srp.NewSRPClient
//	Then use srpClient.Verifier() to generate verifierKey

//export signup
func signup(email *C.char, password *C.char) *C.char {
	lowerCaseEmail := strings.ToLower(C.GoString(email))

	salt, err := authClient.SignUp(lowerCaseEmail, C.GoString(password))
	if err != nil {
		return sendError(err)
	}
	// save salt and email in settings
	setting := a.Settings()
	saveUserSalt(salt)
	setting.SetEmailAddress(C.GoString(email))
	a.SetUserLoggedIn(true)

	// Todo remove this once we complete teting auth flow
	// we don't need this on prod
	fetchPayentMethodV4()
	return C.CString("true")
}

//export login
func login(email *C.char, password *C.char) *C.char {
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	user, salt, err := authClient.Login(lowerCaseEmail, C.GoString(password), getDeviceID())
	if err != nil {
		return sendError(err)
	}
	// User has more than 3 device connected to device
	if !user.Success {
		err := deviceLimitFlow(user)
		if err != nil {
			return sendError(log.Errorf("error while starting device limit flow %v", err))
		}
		return sendError(log.Errorf("too-many-devices %v", err))
	}

	log.Debugf("User login successfull %+v", user)
	// save salt and email in settings
	saveUserSalt(salt)
	a.SetUserLoggedIn(true)
	userData := auth.ConvertToUserDetailsResponse(user)
	// once login is successfull save user details
	// but overide there email with login email
	// old email might be differnt but we want to show latets email
	userData.Email = C.GoString(email)
	err = cacheUserDetail(userData)
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

//export logout
func logout() *C.char {
	email := a.Settings().GetEmailAddress()
	deviceId := getDeviceID()
	token := a.Settings().GetToken()
	userId := a.Settings().GetUserID()

	signoutData := &protos.LogoutRequest{
		Email:        email,
		DeviceId:     deviceId,
		LegacyToken:  token,
		LegacyUserID: userId,
	}
	log.Debugf("Sign out request %+v", signoutData)
	loggedOut, logoutErr := authClient.SignOut(context.Background(), signoutData)
	if logoutErr != nil {
		return sendError(log.Errorf("Error while signing out %v", logoutErr))
	}
	if !loggedOut {
		return sendError(log.Error("Error while signing out"))
	}

	clearLocalUserData()
	// Create new user
	err := userCreate()
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

// User has reached device limit
// Save latest device
func deviceLimitFlow(login *protos.LoginResponse) error {
	var protoDevices []*protos.Device
	for _, device := range login.Devices {
		protoDevice := &protos.Device{
			Id:      device.Id,
			Name:    device.Name,
			Created: device.Created,
		}
		protoDevices = append(protoDevices, protoDevice)
	}

	user := &protos.User{
		UserId:  login.LegacyID,
		Token:   login.LegacyToken,
		Devices: protoDevices,
	}

	app.SetUserData(context.Background(), login.LegacyID, user)
	return nil
}

// Send recovery code to user email
//
//export startRecoveryByEmail
func startRecoveryByEmail(email *C.char) *C.char {
	//Create body
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	prepareRequestBody := &protos.StartRecoveryByEmailRequest{
		Email: lowerCaseEmail,
	}
	recovery, err := authClient.StartRecoveryByEmail(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	log.Debugf("StartRecoveryByEmail response %v", recovery)
	return C.CString("true")
}

// Complete recovery by email
//
//export completeRecoveryByEmail
func completeRecoveryByEmail(email *C.char, code *C.char, password *C.char) *C.char {
	//Create body
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	newsalt, err := auth.GenerateSalt()
	if err != nil {
		return sendError(err)
	}
	log.Debugf("Slat %v and length %v", newsalt, len(newsalt))
	srpClient := auth.NewSRPClient(lowerCaseEmail, C.GoString(password), newsalt)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return sendError(err)
	}
	prepareRequestBody := &protos.CompleteRecoveryByEmailRequest{
		Email:       lowerCaseEmail,
		Code:        C.GoString(code),
		NewSalt:     newsalt,
		NewVerifier: verifierKey.Bytes(),
	}

	log.Debugf("new Verifier %v and salt %v", verifierKey.Bytes(), newsalt)
	recovery, err := authClient.CompleteRecoveryByEmail(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	//User has been recovered successfully
	//Save new salt
	saveUserSalt(newsalt)
	log.Debugf("CompleteRecoveryByEmail response %v", recovery)
	return C.CString("true")
}

// // This will validate code send by server
//
//export validateRecoveryByEmail
func validateRecoveryByEmail(email *C.char, code *C.char) *C.char {
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	prepareRequestBody := &protos.ValidateRecoveryCodeRequest{
		Email: lowerCaseEmail,
		Code:  C.GoString(code),
	}
	recovery, err := authClient.ValidateEmailRecoveryCode(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	if !recovery.Valid {
		return sendError(log.Errorf("invalid_code Error: %v", err))
	}
	log.Debugf("Validate code response %v", recovery.Valid)
	return C.CString("true")
}

// This will delete user accoutn and creates new user
//
//export deleteAccount
func deleteAccount(password *C.char) *C.char {
	email := a.Settings().GetEmailAddress()
	lowerCaseEmail := strings.ToLower(email)
	// Get the salt
	salt, err := getUserSalt(lowerCaseEmail)
	if err != nil {
		return sendError(err)
	}
	// Prepare login request body
	client := auth.NewSRPClient(lowerCaseEmail, C.GoString(password), salt)

	//Send this key to client
	A := client.EphemeralPublic()
	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: lowerCaseEmail,
		A:     A.Bytes(),
	}
	log.Debugf("Delete Account request email %v A %v", lowerCaseEmail, A.Bytes())
	srpB, err := authClient.LoginPrepare(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	log.Debugf("Login prepare response %v", srpB.B)

	// // Once the client receives B from the server Client should check error status here as defense against
	// // a malicious B sent from server
	B := big.NewInt(0).SetBytes(srpB.B)

	if err = client.SetOthersPublic(B); err != nil {
		log.Errorf("Error while setting srpB %v", err)
		return sendError(err)
	}

	// client can now make the session key
	clientKey, err := client.Key()
	if err != nil || clientKey == nil {
		return sendError(log.Errorf("user_not_found error while generating Client key %v", err))
	}

	// // Step 3

	// // check if the server proof is valid
	if !client.GoodServerProof(salt, lowerCaseEmail, srpB.Proof) {
		return sendError(log.Error("user_not_found error while checking server proof"))
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return sendError(log.Errorf("user_not_found error while generating client proof %v", err))
	}
	deviceId := a.Settings().GetDeviceID()

	changeEmailRequestBody := &protos.DeleteUserRequest{
		Email:     lowerCaseEmail,
		Proof:     clientProof,
		Permanent: true,
		DeviceId:  deviceId,
	}

	log.Debugf("Delete Account request email %v prooof %v deviceId %v", lowerCaseEmail, clientProof, deviceId)
	isAccountDeleted, err := authClient.DeleteAccount(context.Background(), changeEmailRequestBody)
	if err != nil {
		return sendError(err)
	}
	log.Debugf("Account Delted response %v", isAccountDeleted)

	if !isAccountDeleted {
		return sendError(log.Errorf("user_not_found error while deleting account %v", err))
	}

	// Clear local user data
	clearLocalUserData()
	// Set user id and token to nil
	a.Settings().SetUserIDAndToken(0, "")
	// Create new user
	err = userCreate()
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

// clearLocalUserData clears the local user data from the settings
func clearLocalUserData() {
	setting := a.Settings()
	saveUserSalt([]byte{})
	setting.SetEmailAddress("")
	a.SetUserLoggedIn(false)
	setProUser(false)
}

func main() {}
