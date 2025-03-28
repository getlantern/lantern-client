// filename: lib.go
package main

import (
	"context"
	"encoding/json"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/golog"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/osversion"
	"google.golang.org/protobuf/encoding/protojson"
)

import "C"

const (
	defaultLocale = "en-US"
)

var (
	log = golog.LoggerFor("lantern-client.main")

	lanternApp *app.App
	mu         sync.RWMutex
	setupOnce  sync.Once
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

func getApp() *app.App {
	mu.RLock()
	defer mu.RUnlock()
	return lanternApp
}

//export setup
func setup() {
	mu.Lock()
	defer mu.Unlock()
	a := lanternApp
	if a != nil {
		return
	}
	setupOnce.Do(func() {
		a, err := app.NewApp()
		if err != nil {
			log.Fatal(err)
		}
		lanternApp = a

		go a.Run(context.Background())
	})
}

//export sysProxyOff
func sysProxyOff() {
	a := getApp()
	if a == nil {
		return
	}
	if !a.SysProxyEnabled() {
		log.Error("system proxy is not currently enabled")
		return
	}
	go a.SysProxyOff()
}

//export sysProxyOn
func sysProxyOn() *C.char {
	log.Debug("sysProxyOn")
	a := getApp()
	if a == nil {
		return C.CString("app not initialized")
	}
	if a.SysProxyEnabled() {
		log.Error("system proxy is already enabled")
		return C.CString("false")
	}
	if err := a.SysproxyOn(); err != nil {
		log.Error(err)
		return sendError(err)
	}
	return C.CString("true")
}

func getDeviceID() string {
	return getApp().Settings().GetDeviceID()
}

func saveUserSalt(salt []byte) {
	getApp().Settings().SaveSalt(salt)
}

//export websocketAddr
func websocketAddr() *C.char {
	a := getApp()
	if a == nil {
		log.Error("cannot get websocket address: app not initialized")
		return C.CString("")
	}
	return C.CString(a.WebsocketAddr())
}

//export setProxyAll
func setProxyAll(value *C.char) {
	proxyAll, _ := strconv.ParseBool(C.GoString(value))
	go getApp().Settings().SetProxyAll(proxyAll)
}

// this method is reposible for checking if the user has updated plan or bought plans
//
//export hasPlanUpdatedOrBuy
func hasPlanUpdatedOrBuy() *C.char {
	// Get the cached user data
	log.Debugf("DEBUG: Checking if user has updated plan or bought new plan")
	a := getApp()
	cacheUserData, isOldFound := a.UserData()
	if isOldFound {
		user, err := a.ProClient().UserData(context.Background())
		if err != nil {
			log.Errorf("Error fetching user data: %v", err)
			return C.CString("true")
		}
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
	_, err := getApp().ProClient().ReferralAttach(context.Background(), C.GoString(referralCode))
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

//export devices
func devices() *C.char {
	log.Debug("devices")
	user, found := getApp().UserData()
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
	resp, err := getApp().ProClient().LinkCodeApprove(context.Background(), C.GoString(code))
	if err != nil {
		return sendError(err)
	}
	return sendJson(resp)
}

//export userLinkCode
func userLinkCode(email *C.char) *C.char {
	resp, err := getApp().ProClient().UserLinkCodeRequest(context.Background(), C.GoString(email))
	if err != nil {
		return sendError(err)
	}
	return sendJson(resp)
}

//export removeDevice
func removeDevice(deviceId *C.char) *C.char {
	resp, err := getApp().ProClient().DeviceRemove(context.Background(), C.GoString(deviceId))
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	return sendJson(resp)
}

//export userLinkValidate
func userLinkValidate(code *C.char) *C.char {
	ctx := context.Background()
	a := getApp()
	proClient := a.ProClient()
	resp, err := proClient.UserLinkValidate(ctx, C.GoString(code))
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	err = a.SetUserIDAndToken(resp.UserID, resp.Token)
	if err != nil {
		return sendError(err)
	}
	// refresh user data
	go proClient.UpdateUserData(ctx, a)
	return C.CString("true")
}

//export expiryDate
func expiryDate() *C.char {
	log.Debug("expiryDate")
	user, found := getApp().UserData()
	if !found {
		return sendError(log.Errorf("User data not found"))
	}
	tm := time.Unix(user.Expiration, 0)
	exp := tm.Format("01/02/2006")
	return C.CString(string(exp))
}

//export userData
func userData() *C.char {
	a := getApp()
	if a == nil {
		return C.CString("")
	}
	user, err := a.RefreshUserData()
	if err != nil {
		log.Errorf("Unable to update user data: %v", err)
		return C.CString("")
	}

	b, _ := protojson.Marshal(user)

	log.Debugf("Got user data %s", string(b))

	return C.CString(string(b))
}

//export emailAddress
func emailAddress() *C.char {
	return C.CString(getApp().Settings().GetEmailAddress())
}

//export emailExists
func emailExists(email *C.char) *C.char {
	_, err := getApp().ProClient().EmailExists(context.Background(), C.GoString(email))
	if err != nil {
		return sendError(err)
	}
	return C.CString("false")
}

//export testProviderRequest
func testProviderRequest(email *C.char, paymentProvider *C.char, plan *C.char) *C.char {
	ctx := context.Background()
	purchaseData := map[string]interface{}{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       C.GoString(paymentProvider),
		"email":          C.GoString(email),
		"plan":           C.GoString(plan),
	}
	_, err := getApp().ProClient().PurchaseRequest(ctx, purchaseData)
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
	response, err := getApp().ProClient().RedeemResellerCode(context.Background(), &protos.RedeemResellerCodeRequest{
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
	a := getApp()
	if user, ok := a.UserData(); ok {
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
	lang := getApp().GetLanguage()
	log.Debugf("DEBUG: Language is %v", lang)
	if lang == "" {
		// Default language is English
		lang = defaultLocale
	}
	return C.CString(lang)
}

//export setSelectLang
func setSelectLang(lang *C.char) {
	getApp().SetLanguage(C.GoString(lang))
}

//export country
func country() *C.char {
	country := getApp().Settings().GetCountry()
	return C.CString(country)
}

//export sdkVersion
func sdkVersion() *C.char {
	version := common.LibraryVersion
	return C.CString(version)
}

//export hasSucceedingProxy
func hasSucceedingProxy() *C.char {
	return booltoCString(getApp().HasSucceedingProxy())
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
	if isProUser, ok := getApp().IsProUserFast(); isProUser && ok {
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
	resp, err := getApp().ProClient().LinkCodeRequest(context.Background(), deviceName())
	if err != nil {
		return sendError(err)
	}
	return C.CString(resp.Code)
}

//export paymentRedirect
func paymentRedirect(planID, currency, provider, email, deviceName *C.char) *C.char {
	country := getApp().Settings().GetCountry()
	ctx := context.Background()
	resp, err := getApp().ProClient().PaymentRedirect(ctx, &protos.PaymentRedirectRequest{
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
	getApp().Exit(nil)
}

//export reportIssue
func reportIssue(email, issueType, description *C.char) *C.char {
	issueTypeStr := C.GoString(issueType)
	a := getApp()
	deviceID := a.Settings().GetDeviceID()
	uc := a.UserConfig()
	issueIndex := issueMap[issueTypeStr]
	issueTypeInt, err := strconv.Atoi(issueIndex)
	if err != nil {
		log.Errorf("Error converting issue type to int: %v", err)
		return sendError(err)
	}

	subscriptionLevel := "free"
	if isProUser, ok := a.IsProUserFast(); ok && isProUser {
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
	a := getApp()
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
	getApp().SetLanguage(userLocale)
	return userLocale, nil
}

// clearLocalUserData clears the local user data from the settings
func clearLocalUserData() {
	setting := getApp().Settings()
	saveUserSalt([]byte{})
	setting.SetEmailAddress("")
	setting.SetProUser(false)
	setting.SetExpirationDate("")
	getApp().SetUserLoggedIn(false)
}

func main() {}
