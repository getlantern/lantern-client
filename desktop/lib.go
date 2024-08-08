// filename: lib.go
package main

import (
	"context"
	"encoding/json"
	"os"
	"os/signal"
	"runtime"
	"runtime/debug"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"

	//"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/osversion"
	"github.com/joho/godotenv"
)

import "C"

var (
	log   = golog.LoggerFor("lantern-desktop.main")
	flags = flashlight.ParseFlags()
	cdir  = configDir(&flags)
	a     = app.NewApp(flags, cdir)
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
		log.Errorf("Error loading .env file: %v", err)
	} else {
		log.Debug("Successfully loaded .env file")
	}

	_, err = logging.RotatedLogsUnder(common.DefaultAppName, appdir.Logs(common.DefaultAppName))
	if err != nil {
		log.Error(err)
		// Nothing we can do if fails to create log files, leave logFile nil so
		// the child process writes to standard outputs as usual.
	}

	golog.SetPrepender(logging.Timestamped)
	//handleSignals(a)
	a.Run()
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

//export onSuccess
func onSuccess() *C.char {
	return booltoCString(a.GetOnSuccess())
}

//export hasProxyFected
func hasProxyFected() *C.char {
	return booltoCString(a.GetHasProxyFetched())
}

//export hasConfigFected
func hasConfigFected() *C.char {
	return booltoCString(a.GetHasConfigFetched())
}

func userCreate() error {
	// User is new
	user, err := a.ProClient().UserCreate(context.Background())
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
	resp, err := a.ProClient().PaymentMethods(context.Background())
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

// this method is reposible for checking if the user has updated plan or bought plans
//
//export hasPlanUpdatedOrBuy
func hasPlanUpdatedOrBuy() *C.char {
	ctx := context.Background()
	//Get the cached user data
	log.Debugf("DEBUG: Checking if user has updated plan or bought new plan")
	cacheUserData, isOldFound := a.UserData(ctx)
	//Get latest user data
	if isOldFound && a.ProClient() != nil {
		resp, err := a.ProClient().UserData(ctx)
		if err != nil {
			return sendError(err)
		}
		user := resp.User
		if user != nil && cacheUserData.Expiration < user.Expiration {
			// New data has a later expiration
			// if foud then update the cache
			a.SetUserData(ctx, user.UserId, user)
			return C.CString(string("true"))
		}
	}
	return C.CString(string("false"))
}

//export devices
func devices() *C.char {
	user, found := a.UserData(context.Background())
	if !found {
		// for now just return empty array
		b, _ := json.Marshal("[]")
		return C.CString(string(b))
	}
	b, _ := json.Marshal(user.Devices)
	return C.CString(string(b))
}

//export approveDevice
func approveDevice(code *C.char) *C.char {
	resp, err := a.ProClient().LinkCodeApprove(context.Background(), C.GoString(code))
	if err != nil {
		return sendError(err)
	}
	return sendJson(resp)
}

//export removeDevice
func removeDevice(deviceId *C.char) *C.char {
	resp, err := a.ProClient().DeviceRemove(context.Background(), C.GoString(deviceId))
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	return sendJson(resp)
}

//export userLinkValidate
func userLinkValidate(code *C.char) *C.char {
	_, err := a.ProClient().UserLinkValidate(context.Background(), C.GoString(code))
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	return C.CString("true")
}

//export expiryDate
func expiryDate() *C.char {
	user, found := a.UserData(context.Background())
	if !found {
		return sendError(log.Errorf("User data not found"))
	}
	tm := time.Unix(user.Expiration, 0)
	exp := tm.Format("01/02/2006")
	return C.CString(string(exp))
}

//export userData
func userData() *C.char {
	user, ok := a.UserData(context.Background())
	if !ok {
		return sendError(errors.New("user not found"))
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
	serverInfo := map[string]interface{}{
		"city":        stats.City,
		"country":     stats.Country,
		"countryCode": stats.CountryCode,
	}
	b, _ := json.Marshal(serverInfo)
	return C.CString(string(b))
}

//export emailAddress
func emailAddress() *C.char {
	return C.CString(a.Settings().GetEmailAddress())
}

//export emailExists
func emailExists(email *C.char) *C.char {
	_, err := a.ProClient().EmailExists(context.Background(), C.GoString(email))
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
	_, err := a.ProClient().PurchaseRequest(context.Background(), puchaseData)
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

// The function returns two C strings: the first represents success, and the second represents an error.
// If the redemption is successful, the first string contains "true", and the second string is nil.
// If an error occurs during redemption, the first string is nil, and the second string contains the error message.
//
//export redeemResellerCode
func redeemResellerCode(email, currency, deviceName, resellerCode *C.char) *C.char {
	response, err := a.ProClient().RedeemResellerCode(context.Background(), &protos.RedeemResellerCodeRequest{
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
	referralCode, err := a.ReferralCode()
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

//export authEnabled
func authEnabled() *C.char {
	authEnabled := a.IsFeatureEnabled(config.FeatureAuth)
	if ok, err := strconv.ParseBool(os.Getenv("ENABLE_AUTH_FEATURE")); err == nil && ok {
		authEnabled = true
	}
	log.Debugf("DEBUG: Auth enabled: %v", authEnabled)
	return booltoCString(authEnabled)
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
	//lang := a.GetLanguage()
	//log.Debugf("DEBUG: Language is %v", lang)
	return C.CString("en-US")
}

//export setSelectLang
func setSelectLang(lang *C.char) {
	a.SetLanguage(C.GoString(lang))
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
	return booltoCString(a.HasSucceedingProxy())
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
	if isProUser, ok := a.IsProUserFast(context.Background()); isProUser && ok {
		return C.CString("true")
	}
	return C.CString("false")
}

func deviceName() string {
	deviceName, _ := osversion.GetHumanReadable()
	return deviceName
}

//export deviceLinkingCode
func deviceLinkingCode() *C.char {
	resp, err := a.ProClient().LinkCodeRequest(context.Background(), deviceName())
	if err != nil {
		return sendError(err)
	}
	return C.CString(resp.Code)
}

//export paymentRedirect
func paymentRedirect(planID, currency, provider, email, deviceName *C.char) *C.char {
	country := a.Settings().GetCountry()
	resp, err := a.ProClient().PaymentRedirect(context.Background(), &protos.PaymentRedirectRequest{
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
	os.Exit(1)
	//a.Exit(nil)
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

	subscriptionLevel := "free"
	if isProUser, ok := a.IsProUserFast(ctx); ok && isProUser {
		subscriptionLevel = "pro"
	}

	var osVersion string
	osVersion, err = osversion.GetHumanReadable()
	if err != nil {
		log.Errorf("Unable to get version: %v", err)
	}
	log.Debug("Sending issue report")
	err = issue.SendReport(
		a.UserConfig(),
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

// clearLocalUserData clears the local user data from the settings
func clearLocalUserData() {
	setting := a.Settings()
	saveUserSalt([]byte{})
	setting.SetEmailAddress("")
	a.SetUserLoggedIn(false)
	setProUser(false)
}

func main() {}
