// filename: lib.go
package main

import (
	"context"
	"encoding/json"
	"fmt"
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
	"github.com/getlantern/i18n"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/internalsdk/common"
	proclient "github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/osversion"

	"google.golang.org/protobuf/encoding/protojson"
)

import "C"

const (
	defaultLocale = "en-US"
)

var (
	log       = golog.LoggerFor("lantern-desktop.main")
	a         *app.App
	proClient proclient.ProClient
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
	flags := flashlight.ParseFlags()

	cdir := configDir(&flags)
	settings := loadSettings(cdir)
	proClient = proclient.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), &proclient.Opts{
		HttpClient: &http.Client{
			Transport: proxied.ParallelForIdempotent(),
			Timeout:   30 * time.Second,
		},
		UserConfig: func() common.UserConfig {
			return userConfig(settings)
		},
	})

	a = app.NewApp(flags, cdir, proClient, settings)

	go func() {
		err := fetchOrCreate()
		if err != nil {
			log.Error(err)
		}
	}()

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
		i18nInit(a)
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

func fetchOrCreate() error {
	settings := a.Settings()
	userID := settings.GetUserID()
	if userID == 0 {
		user, err := proClient.UserCreate(context.Background())
		if err != nil {
			return errors.New("Could not create new Pro user: %v", err)
		}
		log.Debugf("DEBUG: User created: %v", user)
		if user.BaseResponse != nil && user.BaseResponse.Error != "" {
			return errors.New("Could not create new Pro user: %v", err)
		}
		settings.SetUserIDAndToken(user.UserId, user.Token)
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
	// log.Debugf("DEBUG: Payment methods logos: %v providers %v  and plans in string %v", resp.Logo, resp.Providers, resp.Plans)
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
	user := resp.User
	if user != nil && user.Email != "" {
		a.Settings().SetEmailAddress(user.Email)
	}
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
func tryCacheUserData() (*protos.User, error) {
	if cacheUserData, isOldFound := cachedUserData(); isOldFound {
		return cacheUserData, nil
	}
	return getUserData()
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
			return C.CString(string("true"))
		}
	}
	return C.CString(string("false"))
}

//export devices
func devices() *C.char {
	user, err := tryCacheUserData()
	if err != nil {
		return sendError(err)
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
	user, err := tryCacheUserData()
	if err != nil {
		return sendError(err)
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
	lang := a.Settings().GetLanguage()
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
	return C.CString("true")
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
	ctx := context.Background()
	// refresh user data when home page is loaded on desktop
	go getUserData()
	uc := a.Settings()
	if isProUser, ok := app.IsProUserFast(ctx, uc); isProUser && ok {
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
func reportIssue(email, issueType, description *C.char) (*C.char, *C.char) {
	deviceID := a.Settings().GetDeviceID()
	issueIndex := issueMap[C.GoString(issueType)]
	issueTypeInt, err := strconv.Atoi(issueIndex)
	if err != nil {
		return nil, sendError(err)
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
		return nil, sendError(err)
	}
	log.Debug("Successfully reported issue")
	return C.CString("true"), nil
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

func i18nInit(a *app.App) {
	i18n.SetMessagesFunc(func(filename string) ([]byte, error) {
		return a.GetTranslations(filename)
	})
	locale := a.GetLanguage()
	log.Debugf("Using locale: %v", locale)
	if _, err := i18n.SetLocale(locale); err != nil {
		log.Debugf("i18n.SetLocale(%s) failed, fallback to OS default: %q", locale, err)

		// On startup GetLanguage will return '' We use the OS locale instead and make sure the language is
		// populated.
		if locale, err := useOSLocale(); err != nil {
			log.Debugf("i18n.UseOSLocale: %q", err)
			a.SetLanguage(defaultLocale)
		} else {
			a.SetLanguage(locale)
		}
	}
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

func main() {}
