// filename: lib.go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"runtime/debug"
	"strconv"
	"strings"
	"syscall"

	"github.com/shirou/gopsutil/v3/host"

	"github.com/getlantern/appdir"
	"github.com/getlantern/autoupdate"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/flashlight/v7/pro"
	"github.com/getlantern/flashlight/v7/pro/client"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/osversion"
	"github.com/getlantern/golog"
	"github.com/getlantern/i18n"
	"github.com/getlantern/lantern-client/desktop/app"
)

import "C"

var (
	log = golog.LoggerFor("lantern-desktop.main")
	a   *app.App
	proClient *client.Client
	updateClient = &http.Client{Transport: proxied.ChainedThenFrontedWith("")}
)

//export Start
func Start() *C.char {
	// Since Go 1.6, panic prints only the stack trace of current goroutine by
	// default, which may not reveal the root cause. Switch to all goroutines.
	debug.SetTraceback("all")

	cdir := configDir()
	settings := loadSettings(cdir)
	proClient = pro.NewClient()

	a = app.NewApp(flashlight.Flags{}, cdir, proClient, settings)

	go func() {
		err := fetchOrCreate()
		if err != nil {
			log.Error(err)
		}
	}()

	logging.EnableFileLogging(common.DefaultAppName, appdir.Logs(common.DefaultAppName))

	go func() {
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
	return C.CString("")
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

//export SysProxyOn
func SysProxyOn() *C.char {
	app.SysproxyOn()
	return C.CString("on")
}

//export SysProxyOff
func SysProxyOff() *C.char {
	app.SysProxyOff()
	return C.CString("off")
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

//export SelectedTab
func SelectedTab() *C.char {
	return C.CString(string(a.SelectedTab()))
}

//export SetSelectTab
func SetSelectTab(ttab *C.char) {
	tab, err := app.ParseTab(C.GoString(ttab))
	if err != nil {
		log.Error(err)
		return
	}
	a.SetSelectedTab(tab)
}

//export Plans
func Plans() *C.char {
	resp, err := proClient.Plans(userConfig())
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Plans)
	return C.CString(string(b))
}

//export PaymentMethods
func PaymentMethods() *C.char {
	resp, err := proClient.PaymentMethods(userConfig())
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Providers)
	return C.CString(string(b))
}

//export UserData
func UserData() *C.char {
	resp, err := proClient.UserData(userConfig())
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp)
	return C.CString(string(b))
}

//export EmailAddress
func EmailAddress() *C.char {
	return C.CString("")
}

//export Referral
func Referral() *C.char {
	referralCode, err := a.ReferralCode(userConfig())
	if err != nil {
		return sendError(err)
	}
	return C.CString(referralCode)
}

//export ChatEnabled
func ChatEnabled() *C.char {
	return C.CString("false")
}

//export PlayVersion
func PlayVersion() *C.char {
	return C.CString("false")
}

//export StoreVersion
func StoreVersion() *C.char {
	return C.CString("false")
}

//export Lang
func Lang() *C.char {
	lang := a.Settings().GetLanguage()
	return C.CString(lang)
}

//export Country
func Country() *C.char {
	country := a.Settings().GetCountry()
	return C.CString(country)
}

//export SdkVersion
func SdkVersion() *C.char {
	return C.CString("1.0.0")
}

//export VpnStatus
func VpnStatus() *C.char {
	log.Debug("Another vpn status call")
	if app.IsSysProxyOn() {
		return C.CString("connected")
	}
	return C.CString("disconnected")
}

//export HasSucceedingProxy
func HasSucceedingProxy() *C.char {
	return C.CString("true")
}

//export OnBoardingStatus
func OnBoardingStatus() *C.char {
	return C.CString("true")
}

//export AcceptedTermsVersion
func AcceptedTermsVersion() *C.char {
	return C.CString("0")
}

//export ProUser
func ProUser() *C.char {
	if isProUser, ok := a.IsProUser(); isProUser && ok {
		return C.CString("true")
	}
	return C.CString("false")
}

//export DeviceLinkingCode
func DeviceLinkingCode() *C.char {
	info, _ := host.Info()
	resp, err := proClient.RequestDeviceLinkingCode(userConfig(), info.Hostname)
	if err != nil {
		return sendError(err)
	}
	return C.CString(resp.Code)
}

//export DevelopmentMode
func DevelopmentMode() *C.char {
	return C.CString("false")
}

//export SplitTunneling
func SplitTunneling() *C.char {
	return C.CString("false")
}

//export ChatMe
func ChatMe() *C.char {
	return C.CString("false")
}

//export ReplicaAddr
func ReplicaAddr() *C.char {
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

//export ReportIssue
func ReportIssue(email, issueType, description string) *C.char {
	deviceID := a.Settings().GetDeviceID()
	issueTypeInt, err := strconv.Atoi(issueType)
	if err != nil {
		return sendError(err)
	}

	uc := userConfig()

	subscriptionLevel := "free"
	if a.IsPro() {
		subscriptionLevel = "pro"
	}

	var osVersion string
	osVersion, err = osversion.GetHumanReadable()
	if err != nil {
		log.Errorf("Unable to get version: %v", err)
	}

	err = issue.SendReport(
		uc,
		issueTypeInt,
		description,
		subscriptionLevel,
		email,
		app.ApplicationVersion,
		deviceID,
		osVersion,
		"",
		nil,
	)
	if err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

//export CheckUpdates
func CheckUpdates() {
	log.Debug("Checking for updates")
	settings := a.Settings()
	userID := settings.GetUserID()
	deviceID := settings.GetDeviceID()
	op := ops.Begin("check_update").
		Set("user_id", userID).
		Set("device_id", deviceID).
		Set("current_version", app.ApplicationVersion)
	defer op.End()
	updateURL, err := autoupdate.CheckMobileUpdate(&autoupdate.Config{
		CurrentVersion: app.ApplicationVersion,
		URL:            fmt.Sprintf("https://update.getlantern.org/update/%s", strings.ToLower(common.DefaultAppName)),
		HTTPClient: 	updateClient,
		PublicKey:      []byte(autoupdate.PackagePublicKey),
	})
	if err != nil {
		log.Errorf("Error checking for update: %v", err)
	} else {
		log.Debugf("Auto-update URL is %s", updateURL)
	}
}


//export Purchase
func Purchase(planID, email, cardNumber, expDate, cvc string) *C.char {
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

func configDir() string {
	cdir := appdir.General(common.DefaultAppName)
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

func i18nInit(a *app.App) {
	locale := a.GetLanguage()
	log.Debugf("Using locale: %v", locale)
	if _, err := i18n.SetLocale(locale); err != nil {
		log.Debugf("i18n.SetLocale(%s) failed, fallback to OS default: %q", locale, err)

		// On startup GetLanguage will return '', as the browser has not set the language yet.
		// We use the OS locale instead and make sure the language is populated.
		if locale, err := i18n.UseOSLocale(); err != nil {
			log.Debugf("i18n.UseOSLocale: %q", err)
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
