// filename: lib.go
package main

import (
	"encoding/json"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"runtime/debug"
	"strconv"
	"syscall"

	"github.com/getlantern/appdir"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/pro"
	"github.com/getlantern/osversion"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/app"
	proclient "github.com/getlantern/lantern-client/desktop/pro"
)

import "C"

var (
	log = golog.LoggerFor("lantern-desktop.main")
	a   *app.App

	proClient *proclient.ProClient
)

//export Start
func Start() *C.char {
	// systray requires the goroutine locked with main thread, or the whole
	// application will crash.
	runtime.LockOSThread()
	// Since Go 1.6, panic prints only the stack trace of current goroutine by
	// default, which may not reveal the root cause. Switch to all goroutines.
	debug.SetTraceback("all")
	flags := flashlight.ParseFlags()

	cdir := configDir(&flags)
	settings := loadSettings(cdir)
	proClient = proclient.New(settings)

	a = app.NewApp(flags, cdir, settings)

	go func() {
		err := fetchOrCreate()
		if err != nil {
			log.Error(err)
		}
	}()

	log.Debug("Running headless")
	go func() {
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
	resp, err := proClient.Plans()
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Plans)
	return C.CString(string(b))
}

//export PaymentMethods
func PaymentMethods() *C.char {
	resp, err := proClient.PaymentMethods()
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Providers)
	return C.CString(string(b))
}

//export UserData
func UserData() *C.char {
	resp, err := proClient.UserData()
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
	return C.CString("")
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
	return C.CString("en")
}

//export Country
func Country() *C.char {
	return C.CString("US")
}

//export SdkVersion
func SdkVersion() *C.char {
	return C.CString("1.0.0")
}

//export VpnStatus
func VpnStatus() *C.char {
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
	/*if isProUser, ok := a.IsProUser(); isProUser && ok {
		return C.CString("true")
	}*/
	return C.CString("false")
}

//export DeviceLinkingCode
func DeviceLinkingCode() *C.char {
	resp, err := proClient.LinkCodeRequest()
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

func ReportIssue(email, issueType, description string) *C.char {
	settings := a.Settings()
	userID, deviceID, token := settings.GetUserID(), settings.GetDeviceID(), settings.GetToken()
	issueTypeInt, err := strconv.Atoi(issueType)
	if err != nil {
		return sendError(err)
	}

	uc := common.NewUserConfigData(
		common.DefaultAppName,
		deviceID,
		userID,
		token,
		nil,
		settings.GetLanguage(),
	)

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

func Purchase(planID, email, cardNumber, expDate, cvc string) *C.char {
	resp, err := proClient.Purchase(&proclient.PurchaseRequest{
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
	b, _ := json.Marshal(resp)
	return C.CString(string(b))
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
		os.Exit(1)
		//desktop.QuitSystray(a)
	}()
}

func main() {}
