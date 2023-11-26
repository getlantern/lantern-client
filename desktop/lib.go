// filename: lib.go
package main

import (
	"encoding/json"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"runtime"
	"runtime/debug"
	"strconv"
	"sync"

	"github.com/getlantern/appdir"
	"github.com/getlantern/android-lantern/desktop/app"
	"github.com/getlantern/android-lantern/desktop/pro"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/golog"
)

import "C"

var (
	log = golog.LoggerFor("lantern-desktop.main")
	selectedTab = "account"
	selectedTabMu sync.Mutex
	proClient *pro.ProClient
	settings *app.Settings 
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
	settings = loadSettings(cdir)
	proClient = pro.New()
	a := app.NewApp(flags, cdir, settings)
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

func userHeaders() (string, string, string) {
	uID, deviceID, token := settings.GetUserID(), settings.GetDeviceID(), settings.GetToken()
	userID := strconv.FormatInt(uID, 10)
	return deviceID, userID, token
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
	selectedTabMu.Lock()
	defer selectedTabMu.Unlock()
	return C.CString(selectedTab)
}

//export SetSelectTab
func SetSelectTab(ttab *C.char) {
	tab := C.GoString(ttab)
	selectedTabMu.Lock()
	defer selectedTabMu.Unlock()
	selectedTab = tab
}

//export Plans
func Plans() *C.char {
	deviceID, userID, token := userHeaders()
	resp, err := proClient.Plans(deviceID, userID, token)
	if err != nil {
		return sendError(err)
	}
	b, _ := json.Marshal(resp.Plans)
	return C.CString(string(b))
}

//export UserData
func UserData() *C.char {
	deviceID, userID, token := userHeaders()
	resp, err := proClient.UserData(deviceID, userID, token)
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
