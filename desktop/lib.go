// filename: lib.go
package main

import (
	"context"
	"encoding/json"
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
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/pro"
	"github.com/getlantern/flashlight/v7/pro/client"
	"github.com/getlantern/golog"
	"github.com/getlantern/i18n"
	"github.com/getlantern/jibber_jabber"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/autoupdate"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/osversion"

	"github.com/shirou/gopsutil/v3/host"
	"google.golang.org/protobuf/encoding/protojson"
)

import "C"

const (
	defaultLocale = "en-US"
)

var (
	log       = golog.LoggerFor("lantern-desktop.main")
	a         *app.App
	proClient *client.Client
)

//export start
func start() {
	runtime.LockOSThread()
	// Since Go 1.6, panic prints only the stack trace of current goroutine by
	// default, which may not reveal the root cause. Switch to all goroutines.
	debug.SetTraceback("all")
	flags := flashlight.ParseFlags()

	cdir := configDir(&flags)
	settings := loadSettings(cdir)
	proClient = pro.NewClient()

	a = app.NewApp(flags, cdir, proClient, settings)

	go func() {
		err := fetchOrCreate()
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

	go func() {
		defer logging.Close()
		i18nInit(a)
		runApp(a)

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
		user, err := pro.NewUser(settings)
		if err != nil {
			return errors.New("Could not create new Pro user: %v", err)
		}
		settings.SetUserIDAndToken(user.Auth.ID, user.Auth.Token)
	}
	return nil
}

//export sysProxyOn
func sysProxyOn() {
	a.SysproxyOn()
}

//export sysProxyOff
func sysProxyOff() {
	a.SysProxyOff()
}

func sendError(err error) *C.char {
	if err == nil {
		return C.CString("")
	}
	errors := map[string]interface{}{
		"error": err.Error(),
	}
	b, _ := json.Marshal(errors)
	return C.CString(string(b))
}

//export selectedTab
func selectedTab() *C.char {
	return C.CString(string(a.SelectedTab()))
}

//export websocketAddr
func websocketAddr() *C.char {
	return C.CString(a.WebsocketAddr())
}

//export setSelectTab
func setSelectTab(ttab *C.char) {
	tab, err := app.ParseTab(C.GoString(ttab))
	if err != nil {
		log.Error(err)
		return
	}
	a.SetSelectedTab(tab)
}

//export plans
func plans() *C.char {
	resp, err := proClient.Plans(userConfig())
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Plans)
	return C.CString(string(b))
}

//export paymentMethods
func paymentMethods() *C.char {
	resp, err := proClient.PaymentMethods(userConfig())
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Providers)
	return C.CString(string(b))
}

func getUserData() (*client.User, error) {
	resp, err := proClient.UserData(userConfig())
	if err != nil {
		return nil, err
	}
	user := resp.User
	if user.Email != "" {
		a.Settings().SetEmailAddress(user.Email)
	}
	return &user, nil
}

//export devices
func devices() *C.char {
	user, err := getUserData()
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(user.Devices)
	return C.CString(string(b))
}

//export expiryDate
func expiryDate() *C.char {
	user, err := getUserData()
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
	err := proClient.EmailExists(userConfig(), C.GoString(email))
	if err != nil {
		log.Error(err)
		return sendError(err)
	}
	return C.CString("false")
}

// The function returns two C strings: the first represents success, and the second represents an error.
// If the redemption is successful, the first string contains "true", and the second string is nil.
// If an error occurs during redemption, the first string is nil, and the second string contains the error message.
//
//export redeemResellerCode
func redeemResellerCode(email, currency, deviceName, resellerCode *C.char) (*C.char, *C.char) {
	_, err := proClient.RedeemResellerCode(userConfig(), C.GoString(email), C.GoString(resellerCode),
		C.GoString(deviceName), C.GoString(currency))
	if err != nil {
		log.Debugf("DEBUG: error while redeeming reseller code: %v", err)
		return nil, C.CString(err.Error())
		// return sendError(err)
	}
	log.Debugf("DEBUG: redeeming reseller code success: %v", err)
	return C.CString("true"), nil
}

//export referral
func referral() *C.char {
	referralCode, err := a.ReferralCode(userConfig())
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
	a.Settings().SetLanguage(C.GoString(lang))
}

//export country
func country() *C.char {
	country := a.Settings().GetCountry()
	return C.CString(country)
}

//export sdkVersion
func sdkVersion() *C.char {
	return C.CString("1.0.0")
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
	// refresh user data when home page is loaded on desktop
	go pro.FetchUserData(a.Settings())
	if isProUser, ok := a.IsProUser(); isProUser && ok {
		return C.CString("true")
	}
	return C.CString("false")
}

//export deviceLinkingCode
func deviceLinkingCode() *C.char {
	info, _ := host.Info()
	resp, err := proClient.RequestDeviceLinkingCode(userConfig(), info.Hostname)
	if err != nil {
		return sendError(err)
	}
	return C.CString(resp.Code)
}

//export paymentRedirect
func paymentRedirect(planID, currency, provider, email, deviceName *C.char) *C.char {
	country := a.Settings().GetCountry()
	resp, err := proClient.PaymentRedirect(userConfig(), &client.PaymentRedirectRequest{
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
	return C.CString(resp.Redirect)
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

func userConfig() *common.UserConfigData {
	settings := a.Settings()
	userID, deviceID, token := settings.GetUserID(), settings.GetDeviceID(), settings.GetToken()
	return common.NewUserConfigData(
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
	deviceID := a.Settings().GetDeviceID()
	issueTypeInt, err := strconv.Atoi(C.GoString(issueType))
	if err != nil {
		return sendError(err)
	}

	uc := userConfig()

	subscriptionLevel := "free"
	if isProUser, ok := a.IsProUser(); ok && isProUser {
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
		app.ApplicationVersion,
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
		Set("current_version", app.ApplicationVersion)
	defer op.End()
	updateURL, err := autoupdate.CheckUpdates()
	if err != nil {
		log.Errorf("Error checking for update: %v", err)
		return sendError(err)
	}
	log.Debugf("Auto-update URL is %s", updateURL)
	return C.CString(updateURL)
}

//export purchase
func purchase(planID, email, cardNumber, expDate, cvc string) *C.char {
	/*resp, err := proClient.Purchase(&proclient.PurchaseRequest{
		Provider: proclient.Provider_STRIPE,
		Email: email,
		Plan: planID,
		CardNumber: cardNumber,
		ExpDate: expDate,
		Cvc: cvc,
	})
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp)*/
	return C.CString("")
}

// loadSettings loads the initial settings at startup, either from disk or using defaults.
func loadSettings(configDir string) *app.Settings {
	path := filepath.Join(configDir, "settings.yaml")
	if common.Staging {
		path = filepath.Join(configDir, "settings-staging.yaml")
	}
	settings := app.LoadSettingsFrom(app.ApplicationVersion, app.RevisionDate, app.BuildDate, path)
	if common.Staging {
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

func runApp(a *app.App) {
	// Schedule cleanup actions
	handleSignals(a)
	a.Run(true)
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
	}()
}

func main() {}
