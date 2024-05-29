package app

import (
	"math/rand"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/golog"
	notify "github.com/getlantern/notifier"

	"github.com/getlantern/lantern-client/desktop/loconf"
	"github.com/getlantern/lantern-client/desktop/notifier"
	"github.com/getlantern/lantern-client/desktop/settings"
)

// LoconfScanner starts a goroutine to periodically check for new loconf files.
// This will show announcements via desktop notification. Each announcement
// is shown only once. It will also do things like check for updates to
// uninstall survey config
//
// interval: The duration between each check.
//
// proChecker: A function to check if current user is Pro (to decide whether
// show the announcement or not).
//
// Returns a function to stop the loop.
func LoconfScanner(settings *settings.Settings, configDir string, interval time.Duration, proChecker func() (bool, bool), iconURL func() string) (stop func()) {
	loc := &loconfer{
		log:       golog.LoggerFor("loconfer"),
		configDir: configDir,
		r:         rand.New(rand.NewSource(time.Now().UnixNano())),
		iconURL:   iconURL,
		settings:  settings,
	}
	return loc.scan(interval, proChecker, loc.onLoconf)
}

func (loc *loconfer) scan(interval time.Duration, proChecker func() (bool, bool), onLoconf func(*loconf.LoConf, bool)) (stop func()) {
	chStop := make(chan bool)
	t := time.NewTicker(interval)
	isStaging := common.Staging
	checker := func() {
		lc, err := loconf.Get(http.DefaultClient, isStaging)
		if err != nil {
			loc.log.Error(err)
			return
		}
		isPro, ok := proChecker()
		if !ok {
			loc.log.Debugf("Skip checking announcement as user status is unknown")
			return
		}
		onLoconf(lc, isPro)
	}
	go func() {
		for {
			checker()
			select {
			case <-t.C:
			case <-chStop:
				t.Stop()
				return
			}
		}
	}()

	return func() {
		chStop <- true
	}
}

func in(s string, coll []string) bool {
	for _, v := range coll {
		if s == v {
			return true
		}
	}
	return false
}

type loconfer struct {
	log       golog.Logger
	configDir string
	r         *rand.Rand
	iconURL   func() string
	settings  *settings.Settings
}

func (loc *loconfer) onLoconf(lc *loconf.LoConf, isPro bool) {
	go loc.setUninstallURL(lc, isPro)
	go loc.makeAnnouncements(lc, isPro)
}

func (loc *loconfer) setUninstallURL(lc *loconf.LoConf, isPro bool) {
	path := filepath.Join(loc.configDir, "uninstall_url.txt")

	survey := lc.GetUninstallSurvey(loc.settings.GetLanguage(), geolookup.GetCountry(time.Second*30), isPro)
	if survey == nil {
		loc.log.Debugf("No available uninstall survey")
		return
	}
	loc.writeURL(path, survey, isPro)
}

func (loc *loconfer) writeURL(path string, survey *loconf.UninstallSurvey, isPro bool) {
	var url string
	if survey.Enabled {
		if survey.Probability > loc.r.Float64() {
			loc.log.Debugf("Enabling survey at URL %v", survey.URL)
			url = survey.URL
		} else {
			loc.log.Debugf("Turning survey off probabalistically")
		}
	}
	outfile, err := os.OpenFile(path, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0644)
	if err != nil {
		loc.log.Errorf("Unable to open file %v for writing: %v", path, err)
		return
	}
	defer outfile.Close()

	_, err = outfile.Write([]byte(url))
	if err != nil {
		loc.log.Errorf("Unable to write url to file %v: %v", path, err)
	}
}

func (loc *loconfer) makeAnnouncements(lc *loconf.LoConf, isPro bool) {
	lang := loc.settings.GetLanguage()
	current, err := lc.GetAnnouncement(lang, isPro)
	if err != nil {
		if err == loconf.ErrNoAvailable {
			loc.log.Debugf("No available announcement")
		} else {
			loc.log.Error(err)
		}
		return
	}
	past := loc.settings.GetPastAnnouncements()
	if in(current.Campaign, past) {
		loc.log.Debugf("Skip announcement %s", current.Campaign)
		return
	}
	if loc.showAnnouncement(current) {
		past = append(past, current.Campaign)
		loc.settings.SetPastAnnouncements(past)
	}
}

func (loc *loconfer) showAnnouncement(a *loconf.Announcement) bool {
	note := &notify.Notification{
		Title:    a.Title,
		Message:  a.Message,
		ClickURL: a.URL,
		IconURL:  loc.iconURL(),
	}
	return notifier.ShowNotification(note, "global-announcement")
}
