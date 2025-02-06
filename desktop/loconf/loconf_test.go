package loconf

import (
	"io/ioutil"
	"net/http"
	"strings"
	"testing"

	"github.com/getlantern/golog"
	"github.com/stretchr/testify/assert"
)

func TestRoundTrip(t *testing.T) {
	lc, err := Get(http.DefaultClient)
	_ = assert.NoError(t, err) && assert.True(t, len(lc.Surveys) > 0)

	lc, err = Get(http.DefaultClient)
	_ = assert.NoError(t, err) && assert.True(t, len(lc.Surveys) > 0)

	lc, err = get(http.DefaultClient, "badurl")
	assert.Error(t, err)

	lc, err = get(http.DefaultClient, "badurl")
	assert.Error(t, err)

	lc, err = get(http.DefaultClient,
		"https://raw.githubusercontent.com/getlantern/loconf/master/DOESNOTEXIST.json")
	assert.Error(t, err)
}

func TestParsing(t *testing.T) {
	log := golog.LoggerFor("loconf-test")
	buf, _ := ioutil.ReadFile("test/desktop-ui.json")

	lc, err := parse(buf)

	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	us := lc.GetUninstallSurvey("zh-CN", "US", false)

	assert.NotNil(t, us)

	log.Debugf("Got uninstall survey: %+v", us)

	us = lc.GetUninstallSurvey("nothereatall", "notthere", false)

	assert.Nil(t, us)

	us = lc.GetUninstallSurvey("first-arg-not-there", "zh-CN", false)

	assert.NotNil(t, us)

	log.Debugf("Got uninstall survey: %+v", us)
}

func TestUninstallSurvey(t *testing.T) {
	testUninstallSurvey(t, "free", func(lc *LoConf, locale, country string) *UninstallSurvey {
		return lc.GetUninstallSurvey(locale, country, false)
	})

	testUninstallSurvey(t, "pro", func(lc *LoConf, locale, country string) *UninstallSurvey {
		return lc.GetUninstallSurvey(locale, country, true)
	})
}

func testUninstallSurvey(t *testing.T, suffix string, getUninstallSurvey func(lc *LoConf, locale, country string) *UninstallSurvey) {
	buf := `
  {
    "uninstall-survey": {
      "en-US": {
        "enabled": true,
        "probability": 1.00,
        "pro": false
      }
    }
  }
  `
	buf = strings.Replace(buf, "uninstall-survey", "uninstall-survey-"+suffix, 1)
	lc, err := parse([]byte(buf))
	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	sur := getUninstallSurvey(lc, "en-US", "US")

	assert.NotNil(t, sur)

	buf = `
  {
    "uninstall-survey": {
      "en-US": {
        "enabled": false,
        "probability": 1.00,
        "pro": true
      }
    }
  }
  `
	buf = strings.Replace(buf, "uninstall-survey", "uninstall-survey-"+suffix, 1)
	lc, err = parse([]byte(buf))
	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	sur = getUninstallSurvey(lc, "en-US", "US")

	assert.NotNil(t, sur)

	buf = `
  {
    "uninstall-survey": {
      "en-US": {
        "enabled": true,
        "probability": 1.00,
        "pro": true
      }
    }
  }
  `
	buf = strings.Replace(buf, "uninstall-survey", "uninstall-survey-"+suffix, 1)
	lc, err = parse([]byte(buf))
	_ = assert.NotNil(t, lc) && assert.NoError(t, err)

	sur = getUninstallSurvey(lc, "en-US", "US")

	assert.NotNil(t, sur)

	// Make sure we don't return the survey with 0 probability
	buf = `
  {
    "uninstall-survey": {
      "en-US": {
        "enabled": true,
        "probability": 0.00,
        "pro": true
      }
    }
  }
  `
	buf = strings.Replace(buf, "uninstall-survey", "uninstall-survey-"+suffix, 1)
	lc, err = parse([]byte(buf))
	_ = assert.NotNil(t, lc) && assert.NoError(t, err)

	sur = getUninstallSurvey(lc, "en-US", "US")

	assert.NotNil(t, sur)
}

func TestSurvey(t *testing.T) {
	buf := `
  {
    "survey": {
      "en-US": {
        "enabled": true,
        "probability": 1.0,
        "message": "Lantern is hiring an engineer in India! For more info, and to apply",
        "thanks": "Thanks for your application!",
        "button": "Click Here",
        "pro": true
      }
    }
  }
  `
	lc, err := parse([]byte(buf))
	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	sur := lc.GetSurvey("en-US", "US")

	_ = assert.NotNil(t, sur) && assert.Equal(t, "Click Here", sur.Button)

	sur = lc.GetSurvey("nothereatall", "notthere")

	assert.Nil(t, sur)

	// Make sure we don't return the survey with 0 probability
	buf = `
  {
    "survey": {
      "en-US": {
        "enabled": true,
        "probability": 0.00,
        "pro": true
      }
    }
  }
  `
	lc, err = parse([]byte(buf))
	_ = assert.NotNil(t, lc) && assert.NoError(t, err)

	sur = lc.GetSurvey("en-US", "US")

	assert.NotNil(t, sur)

	sur = lc.GetSurvey("US", "en-US")

	assert.NotNil(t, sur)
}

func TestAnnouncements(t *testing.T) {
	buf := `
  {
    "announcement": {
       "default": "en-US",
       "en-US": {
         "campaign": "20160801-new-feature",
         "pro": true,
         "free": true,
         "expiry": "2099-02-02T15:00:00+07:00",
         "title": "Try out the new feature",
         "message": "Believe or not, you'll definitely love it!",
         "url": ""
       }
    }
  }`
	lc, err := parse([]byte(buf))
	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	log.Debug("Start")
	ann, err := lc.GetAnnouncement("en-US", true)
	log.Debug("End")

	_ = assert.NoError(t, err) && assert.NotNil(t, ann) && assert.Equal(t, "Try out the new feature", ann.Title)

	// Test that checking for an invalid locale still returns the default.
	ann, err = lc.GetAnnouncement("FAKE-LOCALE", true)
	_ = assert.NoError(t, err) && assert.NotNil(t, ann)

	// Now test missing default.
	buf = `
  {
    "announcement": {
       "default": "zh-CN",
       "en-US": {
         "campaign": "20160801-new-feature",
         "pro": true,
         "free": true,
         "expiry": "2099-02-02T15:00:00+07:00",
         "title": "Try out the new feature",
         "message": "Believe or not, you'll definitely love it!",
         "url": ""
       }
    }
  }`
	lc, err = parse([]byte(buf))

	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	// Test that checking for an invalid locale no longer returns the default.
	ann, err = lc.GetAnnouncement("FAKE-LOCALE", true)
	_ = assert.Error(t, err) && assert.Nil(t, ann)

	// Now test no default.
	buf = `
  {
    "announcement": {
      "en-US": {
        "campaign": "20160801-new-feature",
        "pro": true
      }
    }
  }`
	lc, err = parse([]byte(buf))

	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	// Test that checking for an invalid locale no longer returns the default.
	ann, err = lc.GetAnnouncement("FAKE-LOCALE", true)
	_ = assert.Error(t, err) && assert.Nil(t, ann)
}

func TestAnnouncementsExpiry(t *testing.T) {
	buf := `
  {
    "announcement": {
       "default": "en-US",
       "en-US": {
         "campaign": "20160801-new-feature",
         "pro": true,
         "free": true,
         "expiry": "2016-02-02T15:00:00+07:00",
         "title": "Try out the new feature",
         "message": "Believe or not, you'll definitely love it!",
         "url": ""
       }
    }
  }`
	lc, err := parse([]byte(buf))

	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	// Announcement should be expired!
	ann, err := lc.GetAnnouncement("en-US", true)

	_ = assert.Error(t, err) && assert.Nil(t, ann)

	// Now test a bogus expiry time.

	buf = `
  {
    "announcement": {
       "default": "en-US",
       "en-US": {
         "campaign": "20160801-new-feature",
         "pro": true,
         "free": true,
         "expiry": "woah-not-correct",
         "title": "Try out the new feature",
         "message": "Believe or not, you'll definitely love it!",
         "url": ""
       }
    }
  }`
	lc, err = parse([]byte(buf))

	_ = assert.NoError(t, err) && assert.NotNil(t, lc)

	// Should not have been able to parse expiry
	ann, err = lc.GetAnnouncement("en-US", true)

	_ = assert.Error(t, err) && assert.Nil(t, ann)
}
