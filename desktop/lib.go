// filename: lib.go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"runtime/debug"
	"strconv"
	"strings"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/golog"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/sentry"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"github.com/getlantern/osversion"
	"github.com/joho/godotenv"
)

import "C"

const (
	defaultLocale = "en-US"
)

var (
	log        = golog.LoggerFor("lantern-client.main")
	flags      = flashlight.ParseFlags()
	proClient  proclient.ProClient
	authClient auth.AuthClient
	a          *app.App
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

func init() {
	cdir := configDir(&flags)
	ss := settings.LoadSettings(cdir)
	userConfig := func() common.UserConfig {
		return settings.UserConfig(ss)
	}
	proClient = proclient.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), &webclient.Opts{
		UserConfig: userConfig,
	})
	authClient = auth.NewClient(fmt.Sprintf("https://%s", common.DFBaseUrl), userConfig)

	a = app.NewApp(flags, cdir, proClient, ss)
}

//export start
func start() *C.char {
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

	// This init needs to be called before the panicwrapper fork so that it has been
	// defined in the parent process
	if app.ShouldReportToSentry() {
		sentry.InitSentry(sentry.Opts{
			DSN:             common.SentryDSN,
			MaxMessageChars: common.SentryMaxMessageChars,
		})
	}
	golog.SetPrepender(logging.Timestamped)

	if flags.Pprof {
		addr := "localhost:6060"
		go func() {
			log.Debugf("Starting pprof page at http://%s/debug/pprof", addr)
			srv := &http.Server{
				Addr: addr,
			}
			if err := srv.ListenAndServe(); err != nil {
				log.Error(err)
			}
		}()
	}

	// i18nInit(a)
	a.Run(context.Background())

	return C.CString("")
}

func getDeviceID() string {
	return a.Settings().GetDeviceID()
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

//export paymentMethodsV3
func paymentMethodsV3() *C.char {
	return C.CString("")
}

//export paymentMethodsV4
func paymentMethodsV4() *C.char {
	/*resp, err := a.PaymentMethods(context.Background())
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp)
	return C.CString(string(b))*/
	return C.CString("")
}

func cachedUserData() (*protos.User, bool) {
	uc := settings.UserConfig(a.Settings())
	return a.GetUserData(uc.GetUserID())
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
			a.Settings().SetExpiration(resp.User.Expiration)
			return C.CString(string("true"))
		}
	}
	return C.CString(string("false"))
}

//export applyRef
func applyRef(referralCode *C.char) *C.char {
	_, err := proClient.ReferralAttach(context.Background(), C.GoString(referralCode))
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

//export userLinkValidate
func userLinkValidate(code *C.char) *C.char {
	_, err := proClient.UserLinkValidate(context.Background(), C.GoString(code))
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
	_, err := proClient.EmailExists(context.Background(), C.GoString(email))
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
	_, err := proClient.PurchaseRequest(ctx, puchaseData)
	if err != nil {
		return sendError(err)
	}
	//a.SetProUser(true)
	go a.UserData(ctx)
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
	if isProUser, ok := a.IsProUserFast(settings.UserConfig(a.Settings())); isProUser && ok {
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
	uc := settings.UserConfig(a.Settings())

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
	ss := settings.LoadSettings(configDir(nil))
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

func configDir(flags *flashlight.Flags) string {
	cdir := appdir.General(common.DefaultAppName)
	if flags != nil && flags.ConfigDir != "" {
		cdir = flags.ConfigDir
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

// clearLocalUserData clears the local user data from the settings
func clearLocalUserData() {
	setting := a.Settings()
	saveUserSalt([]byte{})
	setting.SetEmailAddress("")
	a.SetUserLoggedIn(false)
}

func main() {}
