// filename: lib.go
package main

import (
	"context"
	"encoding/json"
	"runtime/debug"
	"strconv"
	"strings"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/golog"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/sentry"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/osversion"
	"github.com/joho/godotenv"
)

import "C"

const (
	defaultLocale = "en-US"
)

var (
	log = golog.LoggerFor("lantern-client.main")
	a   *app.App
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
func start() *C.char {
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

	logging.EnableFileLogging(common.DefaultAppName, appdir.Logs(common.DefaultAppName))

	// This init needs to be called before the panicwrapper fork so that it has been
	// defined in the parent process
	if app.ShouldReportToSentry() {
		sentry.InitSentry(sentry.Opts{
			DSN:             common.SentryDSN,
			MaxMessageChars: common.SentryMaxMessageChars,
		})
	}
	golog.SetPrepender(logging.Timestamped)

	a, err = app.NewApp()
	if err != nil {
		log.Fatal(err)
	}
	go a.Run(context.Background())

	return C.CString("")
}

func getDeviceID() string {
	return a.Settings().GetDeviceID()
}

func saveUserSalt(salt []byte) {
	a.Settings().SaveSalt(salt)
}

//export sysProxyOn
func sysProxyOn() *C.char {
	err := a.SysproxyOn()
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	return C.CString("true")
}

//export sysProxyOff
func sysProxyOff() {
	go a.SysProxyOff()
}

//export websocketAddr
func websocketAddr() *C.char {
	return C.CString(a.WebsocketAddr())
}
func cachedUserData() (*protos.User, bool) {
	uc := a.UserConfig()
	return a.GetUserData(uc.GetUserID())
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
	proClient := a.ProClient()
	go proClient.PollUserData(ctx, a, 10*time.Minute, proClient)
	//Get the cached user data
	log.Debugf("DEBUG: Checking if user has updated plan or bought new plan")
	cacheUserData, isOldFound := cachedUserData()
	//Get latest user data
	resp, err := a.ProClient().UserData(ctx)
	if err != nil {
		return sendError(err)
	}
	if isOldFound {
		user := resp.User
		if cacheUserData.Expiration < user.Expiration {
			// New data has a later expiration
			// if foud then update the cache
			a.Settings().SetExpiration(user.Expiration)
			return C.CString(string("true"))
		}
	}
	return C.CString(string("false"))
}

//export applyRef
func applyRef(referralCode *C.char) *C.char {
	_, err := a.ProClient().ReferralAttach(context.Background(), C.GoString(referralCode))
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

//export devices
func devices() *C.char {
	log.Debug("devices")
	user, found := cachedUserData()
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
	log.Debug("expiryDate")
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
	user, ok := a.GetUserData(a.Settings().GetUserID())
	if !ok {
		return C.CString("")
	}

	b, _ := json.Marshal(user)
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
	ctx := context.Background()
	puchaseData := map[string]interface{}{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       C.GoString(paymentProvider),
		"email":          C.GoString(email),
		"plan":           C.GoString(plan),
	}
	_, err := a.ProClient().PurchaseRequest(ctx, puchaseData)
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
	if err != nil {
		log.Errorf("error redeeming reseller code: %v", err)
		return sendError(err)
	} else if response.Error != "" {
		log.Errorf("error redeeming reseller code: %v", response.Error)
		return sendError(err)
	}
	log.Debug("redeeming reseller code success")
	return C.CString("true")
}

//export referral
func referral() *C.char {
	if user, ok := a.GetUserData(a.Settings().GetUserID()); ok {
		return C.CString(user.Referral)
	}
	referralCode := a.Settings().GetReferralCode()
	return C.CString(referralCode)
}

//export myDeviceId
func myDeviceId() *C.char {
	deviceId := getDeviceID()
	return C.CString(deviceId)
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
	if isProUser, ok := a.IsProUserFast(a.UserConfig()); isProUser && ok {
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
	ctx := context.Background()
	resp, err := a.ProClient().PaymentRedirect(ctx, &protos.PaymentRedirectRequest{
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
	uc := a.UserConfig()

	subscriptionLevel := "free"
	if isProUser, ok := a.IsProUserFast(uc); ok && isProUser {
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
		"",
	)
	if err != nil {
		return sendError(err)
	}
	log.Debug("Successfully reported issue")
	return C.CString("true")
}

//export updatePaymentMethod
func updatePaymentMethod() *C.char {
	_, err := a.ProClient().DesktopPaymentMethods(context.Background())
	if err != nil {
		return sendError(err)
	}
	a.SendConfig()
	return C.CString("true")
}

//export checkUpdates
func checkUpdates() *C.char {
	log.Debug("Checking for updates")
	ss := app.LoadSettings("")
	userID := ss.GetUserID()
	deviceID := ss.GetDeviceID()
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

// clearLocalUserData clears the local user data from the settings
func clearLocalUserData() {
	setting := a.Settings()
	saveUserSalt([]byte{})
	setting.SetEmailAddress("")
	setting.SetProUser(false)
	setting.SetExpirationDate("")
	a.SetUserLoggedIn(false)
}

func main() {}
