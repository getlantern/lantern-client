package settings

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"reflect"
	"strings"
	"sync"
	"time"

	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/golog"
	"github.com/getlantern/launcher"
	"github.com/getlantern/timezone"
	"github.com/getlantern/yaml"

	"github.com/getlantern/lantern-client/desktop/deviceid"
	"github.com/getlantern/lantern-client/desktop/ws"
)

// SettingName is the name of a setting.
type SettingName string

const (
	SNAutoReport   SettingName = "autoReport"
	SNAutoLaunch   SettingName = "autoLaunch"
	SNProxyAll     SettingName = "proxyAll"
	SNGoogleAds    SettingName = "googleAds"
	SNSystemProxy  SettingName = "systemProxy"
	SNDisconnected SettingName = "disconnected"

	SNLanguage       SettingName = "lang"
	SNCountry        SettingName = "country"
	SNLocalHTTPToken SettingName = "localHTTPToken"

	SNDeviceID                  SettingName = "deviceID"
	SNEmailAddress              SettingName = "emailAddress"
	SNUserID                    SettingName = "userID"
	SNUserToken                 SettingName = "userToken"
	SNMigratedDeviceIDForUserID SettingName = "migratedDeviceIDForUserID"
	SNTakenSurveys              SettingName = "takenSurveys"
	SNPastAnnouncements         SettingName = "pastAnnouncements"

	SNAddr      SettingName = "addr"
	SNSOCKSAddr SettingName = "socksAddr"
	SNUIAddr    SettingName = "uiAddr"

	SNVersion            SettingName = "version"
	SNBuildDate          SettingName = "buildDate"
	SNRevisionDate       SettingName = "revisionDate"
	SNEnabledExperiments SettingName = "enabledExperiments"

	SNPaymentMethods SettingName = "paymentMethods"
)

type settingType byte

const (
	stBool settingType = iota
	stNumber
	stString
	stStringArray
)

var settingMeta = map[SettingName]struct {
	sType     settingType
	persist   bool
	omitempty bool
}{
	SNAutoReport:     {stBool, true, false},
	SNAutoLaunch:     {stBool, true, false},
	SNProxyAll:       {stBool, true, false},
	SNSystemProxy:    {stBool, true, false},
	SNDisconnected:   {stBool, false, false},
	SNGoogleAds:      {stBool, true, false},
	SNLanguage:       {stString, true, true},
	SNCountry:        {stString, true, true},
	SNLocalHTTPToken: {stString, true, true},

	// SNDeviceID: intentionally omit, to avoid setting it from UI
	SNEmailAddress:              {stString, true, true},
	SNUserID:                    {stNumber, true, true},
	SNUserToken:                 {stString, true, true},
	SNMigratedDeviceIDForUserID: {stNumber, true, true},
	SNTakenSurveys:              {stStringArray, true, true},
	SNPastAnnouncements:         {stStringArray, true, true},

	SNAddr:      {stString, true, true},
	SNSOCKSAddr: {stString, true, true},
	SNUIAddr:    {stString, true, true},

	SNVersion:      {stString, false, false},
	SNBuildDate:    {stString, false, false},
	SNRevisionDate: {stString, false, false},

	SNEnabledExperiments: {stStringArray, false, false},
}

// Settings is a struct of all settings unique to this particular Lantern instance.
type Settings struct {
	muNotifiers     sync.RWMutex
	changeNotifiers map[SettingName][]func(interface{})
	wsOut           chan<- interface{}

	m map[SettingName]interface{}
	sync.RWMutex
	filePath string

	log golog.Logger
}

func LoadSettingsFrom(version, revisionDate, buildDate, path string) *Settings {
	// Create default settings that may or may not be overridden from an existing file
	// on disk.
	sett := newSettings(path)
	set := sett.m

	// Use settings from disk if they're available.
	if bytes, err := ioutil.ReadFile(path); err != nil {
		sett.log.Debugf("Could not read file %v", err)
	} else if err := yaml.Unmarshal(bytes, set); err != nil {
		sett.log.Errorf("Could not load yaml %v", err)
		// Just keep going with the original settings not from disk.
	} else {
		sett.log.Debugf("Loaded settings from %v", path)
	}
	// old lantern persist settings with all lower case, convert them to camel cased.
	toCamelCase(set)

	set[SNDeviceID] = deviceid.Get()

	// SNUserID may be unmarshalled as int, which causes panic when GetUserID().
	// Make sure to store it as int64.
	switch id := set[SNUserID].(type) {
	case int:
		set[SNUserID] = int64(id)
	case int64:
		set[SNUserID] = id
	}

	// Always just sync the auto-launch configuration on startup.
	go launcher.CreateLaunchFile(sett.IsAutoLaunch())

	// always override below 3 attributes as they are not meant to be persisted across versions
	set[SNVersion] = version
	set[SNBuildDate] = buildDate
	set[SNRevisionDate] = revisionDate

	return sett
}

// EmptySettings returns a new settings instance without loading any file from disk.
func EmptySettings() *Settings {
	return LoadSettingsFrom("version", "revisionDate", "buildDate", "")
}

func toCamelCase(m map[SettingName]interface{}) {
	for k := range settingMeta {
		lowerCased := SettingName(strings.ToLower(string(k)))
		if v, exists := m[lowerCased]; exists {
			delete(m, lowerCased)
			m[k] = v
		}
	}
}

func newSettings(filePath string) *Settings {
	return &Settings{
		m: map[SettingName]interface{}{
			SNUserID:                    int64(0),
			SNAutoReport:                true,
			SNAutoLaunch:                true,
			SNProxyAll:                  false,
			SNGoogleAds:                 true,
			SNSystemProxy:               true,
			SNDisconnected:              false,
			SNLanguage:                  "",
			SNLocalHTTPToken:            "",
			SNUserToken:                 "",
			SNUIAddr:                    "",
			SNMigratedDeviceIDForUserID: int64(0),
		},
		filePath:        filePath,
		changeNotifiers: make(map[SettingName][]func(interface{})),
		log:             golog.LoggerFor("app.settings"),
	}
}

// StartService starts the settings service that synchronizes Lantern's configuration with
// every UI client
func (s *Settings) StartService(channel ws.UIChannel) error {
	helloFn := func(write func(interface{})) {
		s.log.Debugf("Sending Lantern settings to new client")
		write(s.uiMap())
	}

	service, err := channel.Register("settings", helloFn)
	if err != nil {
		return err
	}
	s.muNotifiers.Lock()
	s.wsOut = service.Out
	s.muNotifiers.Unlock()
	go s.read(service.In, service.Out)
	return nil
}

func (s *Settings) read(in <-chan interface{}, out chan<- interface{}) {
	s.log.Debugf("Start reading settings messages!!")
	for message := range in {
		s.log.Debugf("Read settings message %v", message)

		data, ok := (message).(map[string]interface{})
		if !ok {
			continue
		}

		for k, v := range data {
			name := SettingName(k)
			t, exists := settingMeta[name]
			if !exists {
				// We do not allow the UI to set the device ID, so only log an
				// error if it's something else. Some discussion here:
				// https://github.com/getlantern/lantern-internal/issues/5367
				if name != SNDeviceID {
					s.log.Errorf("Unknown settings name %s", k)
				}
				continue
			}
			switch t.sType {
			case stBool:
				s.setBool(name, v)
			case stString:
				s.setString(name, v)
			case stNumber:
				s.setNum(name, v)
			case stStringArray:
				s.setStringArray(name, v)
			}
		}

		out <- s.uiMap()
	}
}

func (s *Settings) setBool(name SettingName, v interface{}) {
	b, ok := v.(bool)
	if !ok {
		s.log.Errorf("Could not convert %s(%v) to bool", name, v)
		return
	}
	s.setVal(name, b)
}

func (s *Settings) setInt64(name SettingName, v interface{}) {
	b, ok := v.(int64)
	if !ok {
		s.log.Errorf("Could not convert %s(%v) to int64", name, v)
		return
	}
	s.setVal(name, b)
}

func (s *Settings) setNum(name SettingName, v interface{}) {
	number, ok := v.(json.Number)
	if !ok {
		s.log.Errorf("Could not convert %v of type %v", name, reflect.TypeOf(v))
		return
	}
	bigint, err := number.Int64()
	if err != nil {
		s.log.Errorf("Could not get int64 value for %v with error %v", name, err)
		return
	}
	s.setVal(name, bigint)
}

func (s *Settings) setStringArray(name SettingName, v interface{}) {
	if v == nil {
		v = []string{}
	}
	sa, ok := v.([]string)
	if !ok {
		ss, ok := v.([]interface{})
		if !ok {
			s.log.Errorf("Could not convert %s(%v) to array", name, v)
			return
		}
		for i := range ss {
			sa = append(sa, fmt.Sprintf("%v", ss[i]))
		}
	}
	s.setVal(name, sa)
}

func (s *Settings) setString(name SettingName, v interface{}) {
	str, ok := v.(string)
	if !ok {
		s.log.Errorf("Could not convert %s(%v) to string", name, v)
		return
	}
	s.setVal(name, str)
}

// save saves settings to disk.
func (s *Settings) save() {
	s.saveDefault()
}

// save saves settings to disk as yaml in the default lantern user settings directory.
func (s *Settings) saveDefault() {
	s.log.Trace("Saving settings")
	if f, err := os.Create(s.filePath); err != nil {
		s.log.Errorf("Could not open settings file for writing: %v", err)
	} else {
		defer f.Close()
		if _, err := s.writeTo(f); err != nil {
			s.log.Errorf("Could not save settings file: %v", err)
		} else {
			s.log.Tracef("Saved settings to %s", s.filePath)
		}
	}
}

func (s *Settings) writeTo(w io.Writer) (int, error) {
	toBeSaved := s.mapToSave()
	if bytes, err := yaml.Marshal(toBeSaved); err != nil {
		return 0, err
	} else {
		return w.Write(bytes)
	}
}

func (s *Settings) mapToSave() map[string]interface{} {
	m := make(map[string]interface{})
	s.RLock()
	defer s.RUnlock()
	for k, v := range s.m {
		if settingMeta[k].persist {
			m[string(k)] = v
		}
	}
	return m
}

// uiMap makes a copy of our map for the UI with support for omitting empty
// values.
func (s *Settings) uiMap() map[string]interface{} {
	m := make(map[string]interface{})
	s.RLock()
	defer s.RUnlock()
	for key, v := range s.m {
		meta := settingMeta[key]
		k := string(key)
		// This mimics https://golang.org/pkg/encoding/json/ for what are considered
		// empty values.
		if !meta.omitempty {
			m[k] = v
		} else {
			if v == nil {
				continue
			}
			switch meta.sType {
			case stBool:
				if v.(bool) {
					m[k] = v
				}
			case stString:
				if v != "" {
					m[k] = v
				}
			case stStringArray:
				if a, ok := v.([]string); ok {
					m[k] = a
				}
			case stNumber:
				if v != 0 {
					m[k] = v
				}
			}
		}
	}
	return m
}

func (s *Settings) GetAppName() string {
	return common.DefaultAppName
}

// GetEnabledExperiments returns the names of the Lantern experiment IDs that were enabled via flags.
func (s *Settings) GetEnabledExperiments() []string {
	return s.getStringArray(SNEnabledExperiments)
}

// SetEnabledExperiments sets the Lantern experiment IDs that were enabled via flags.
func (s *Settings) SetEnabledExperiments(ex []string) {
	s.setStringArray(SNEnabledExperiments, ex)
}

// GetTakenSurveys returns the IDs of surveys the user has already taken.
func (s *Settings) GetTakenSurveys() []string {
	return s.getStringArray(SNTakenSurveys)
}

// SetTakenSurveys sets the IDs of taken surveys.
func (s *Settings) SetTakenSurveys(campaigns []string) {
	s.setStringArray(SNTakenSurveys, campaigns)
}

// GetProxyAll returns whether or not to proxy all traffic.
func (s *Settings) GetProxyAll() bool {
	return s.getBool(SNProxyAll)
}

// SetProxyAll sets whether or not to proxy all traffic.
func (s *Settings) SetProxyAll(proxyAll bool) {
	s.setVal(SNProxyAll, proxyAll)
}

// GetDisconnected returns whether or not we're disconnected
func (s *Settings) GetDisconnected() bool {
	return s.getBool(SNDisconnected)
}

// SetDisconnected sets whether or not we're disconnected
func (s *Settings) SetDisconnected(disconnected bool) {
	s.setBool(SNDisconnected, disconnected)
}

// GetGoogleAds returns whether or not to proxy all traffic.
func (s *Settings) GetGoogleAds() bool {
	return s.getBool(SNGoogleAds)
}

// SetGoogleAds sets whether or not to proxy all traffic.
func (s *Settings) SetGoogleAds(g bool) {
	s.setVal(SNGoogleAds, g)
}

// IsAutoReport returns whether or not to auto-report debugging and analytics data.
func (s *Settings) IsAutoReport() bool {
	return s.getBool(SNAutoReport)
}

// IsAutoLaunch returns whether or not to automatically launch on system
// startup.
func (s *Settings) IsAutoLaunch() bool {
	return s.getBool(SNAutoLaunch)
}

// SetLanguage sets the user language
func (s *Settings) SetLanguage(language string) {
	s.setVal(SNLanguage, language)
}

// GetLanguage returns the user language
func (s *Settings) GetLanguage() string {
	return s.getString(SNLanguage)
}

// SetCountry sets the user's country.
func (s *Settings) SetCountry(country string) {
	s.setVal(SNCountry, country)
}

// GetCountry returns the user country
func (s *Settings) GetCountry() string {
	return s.getString(SNCountry)
}

func (s *Settings) GetTimeZone() (string, error) {
	return timezone.IANANameForTime(time.Now())
}

// SetLocalHTTPToken sets the local HTTP token, stored on disk because we've
// seen weird issues on Windows where the OS remembers old, inactive PAC URLs
// with old tokens and uses them, breaking Edge and IE.
func (s *Settings) SetLocalHTTPToken(token string) {
	s.setVal(SNLocalHTTPToken, token)
}

// GetLocalHTTPToken returns the local HTTP token.
func (s *Settings) GetLocalHTTPToken() string {
	return s.getString(SNLocalHTTPToken)
}

// GetPastAnnouncements returns past campaign announcements
func (s *Settings) GetPastAnnouncements() []string {
	return s.getStringArray(SNPastAnnouncements)
}

// SetPastAnnouncements sets past campaigns announcements
func (s *Settings) SetPastAnnouncements(announcements []string) {
	s.setStringArray(SNPastAnnouncements, announcements)
}

// SetUIAddr sets the last known UI address.
func (s *Settings) SetUIAddr(uiaddr string) {
	s.setVal(SNUIAddr, uiaddr)
}

// GetAddr gets the HTTP proxy address.
func (s *Settings) GetAddr() string {
	return s.getString(SNAddr)
}

// SetAddr sets the HTTP proxy address.
func (s *Settings) SetAddr(addr string) {
	s.setString(SNAddr, addr)
}

// GetSOCKSAddr returns the SOCKS proxy address.
func (s *Settings) GetSOCKSAddr() string {
	return s.getString(SNSOCKSAddr)
}

// SetSOCKSAddr sets the SOCKS proxy address.
func (s *Settings) SetSOCKSAddr(addr string) {
	s.setString(SNSOCKSAddr, addr)
}

// GetEmailAddress gets the email address of pro users.
func (s *Settings) GetEmailAddress() string {
	return s.getString(SNEmailAddress)
}

// SetEmailAddress locally stores the email address of a pro user
func (s *Settings) SetEmailAddress(email string) {
	s.setVal(SNEmailAddress, email)
}

// GetUIAddr returns the address of the UI, stored across runs to avoid a
// different port on each run, which breaks things like local storage in the UI.
func (s *Settings) GetUIAddr() string {
	return s.getString(SNUIAddr)
}

// GetDeviceID returns the unique ID of this device.
func (s *Settings) GetDeviceID() string {
	return s.getString(SNDeviceID)
}

// SetUserIDAndToken sets the user ID and token atomically
func (s *Settings) SetUserIDAndToken(id int64, token string) {
	s.setVals(map[SettingName]interface{}{SNUserID: id, SNUserToken: token})
}

// SetPaymentMethods sets plans as string
func (s *Settings) SetPaymentMethodPlans(paymentMethods []byte) {
	s.setVal(SNPaymentMethods, paymentMethods)

}

// () returns the payment methods
func (s *Settings) GetPaymentMethods() []byte {
	return s.getbytes(SNPaymentMethods)
}

// GetUserID returns the user ID
func (s *Settings) GetUserID() int64 {
	return s.getInt64(SNUserID)
}

// GetToken returns the user token
func (s *Settings) GetToken() string {
	return s.getString(SNUserToken)
}

// GetMigratedDeviceIDForUserID returns the user ID (if any) for which the current device's ID has been migrated from the old style to the new style
func (s *Settings) GetMigratedDeviceIDForUserID() int64 {
	return s.getInt64(SNMigratedDeviceIDForUserID)
}

// SetMigratedDeviceIDForUserID stores the user ID (if any) for which the current device's ID has been migrated from the old style to the new style
func (s *Settings) SetMigratedDeviceIDForUserID(userID int64) {
	s.setInt64(SNMigratedDeviceIDForUserID, userID)
}

// GetInternalHeaders returns extra headers sent with requests to internal services
func (s *Settings) GetInternalHeaders() map[string]string {
	// stubbed
	return make(map[string]string)
}

// GetSystemProxy returns whether or not to set system proxy when lantern starts
func (s *Settings) GetSystemProxy() bool {
	return s.getBool(SNSystemProxy)
}

func (s *Settings) getBool(name SettingName) bool {
	if val, err := s.getVal(name); err == nil {
		if v, ok := val.(bool); ok {
			return v
		}
	}
	return false
}

func (s *Settings) getStringArray(name SettingName) []string {
	if val, err := s.getVal(name); err == nil {
		if v, ok := val.([]string); ok {
			return v
		}
		if v, ok := val.([]interface{}); ok {
			var sa []string
			for _, item := range v {
				sa = append(sa, fmt.Sprintf("%v", item))
			}
			return sa
		}
	}
	return nil
}

func (s *Settings) getString(name SettingName) string {
	if val, err := s.getVal(name); err == nil {
		if v, ok := val.(string); ok {
			return v
		}
	}
	return ""
}

func (s *Settings) getbytes(name SettingName) []byte {
	if val, err := s.getVal(name); err == nil {
		if v, ok := val.([]byte); ok {
			return v
		}
	}
	return []byte{}
}
func (s *Settings) getInt64(name SettingName) int64 {
	if val, err := s.getVal(name); err == nil {
		if v, ok := val.(int64); ok {
			return v
		}
		if v, ok := val.(int); ok {
			return int64(v)
		}
	}
	return int64(0)
}

func (s *Settings) getVal(name SettingName) (interface{}, error) {
	s.log.Tracef("Getting value for %v", name)
	s.RLock()
	defer s.RUnlock()
	if val, ok := s.m[name]; ok {
		return val, nil
	}
	s.log.Debugf("Could not get value for %s", name)
	return nil, fmt.Errorf("no value for %v", name)
}

func (s *Settings) setVal(name SettingName, val interface{}) {
	s.setVals(map[SettingName]interface{}{name: val})
}

func (s *Settings) setVals(vals map[SettingName]interface{}) {
	s.log.Debugf("Setting %v in %v", vals, s.m)
	s.Lock()
	for name, val := range vals {
		s.m[name] = val
	}
	// Need to unlock here because s.save() will lock again.
	s.Unlock()
	s.save()
	for name, val := range vals {
		s.onChange(name, val)
	}
}

// GetInt64Eventually blocks returning an int64 until the int has a value
// other than the defualt.
func (s *Settings) GetInt64Eventually(name SettingName) (int64, error) {
	nval := eventual.NewValue()
	s.OnChange(name, func(val interface{}) {
		nval.Set(val)
	})

	val := s.getInt64(name)
	if val > 0 {
		return val, nil
	}

	eid, _ := nval.Get(-1)
	intVal, ok := eid.(int64)
	if !ok {
		return int64(0), errors.New("Could not cast to int64?")
	}
	return intVal, nil
}

// OnChange sets a callback cb to get called when attr is changed from UI.
func (s *Settings) OnChange(attr SettingName, cb func(interface{})) {
	s.muNotifiers.Lock()
	s.changeNotifiers[attr] = append(s.changeNotifiers[attr], cb)
	s.muNotifiers.Unlock()
}

// onChange is called when attr is changed from UI
func (s *Settings) onChange(attr SettingName, value interface{}) {
	s.muNotifiers.RLock()
	notifiers := s.changeNotifiers[attr]
	wsOut := s.wsOut
	s.muNotifiers.RUnlock()
	for _, fn := range notifiers {
		fn(value)
	}
	if wsOut != nil {
		// notify UI of changed settings
		wsOut <- s.uiMap()
	}
}
