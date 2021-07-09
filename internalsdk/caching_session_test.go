package internalsdk

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type staticSession struct {
	deviceID          string
	userID            int64
	token             string
	proxyAll          bool
	locale            string
	timeZone          string
	code              string
	countryCode       string
	forcedCountryCode string
	dnsServer         string
	provider          string
	appVersion        string
	isPlayVersion     bool
	email             string
	currency          string
	deviceOS          string
	isProUser         bool
}

func (s *staticSession) GetDeviceID() (string, error)                       { return s.deviceID, nil }
func (s *staticSession) GetUserID() (int64, error)                          { return s.userID, nil }
func (s *staticSession) GetToken() (string, error)                          { return s.token, nil }
func (s *staticSession) SetCountry(string) error                            { return nil }
func (s *staticSession) UpdateAdSettings(AdSettings) error                  { return nil }
func (s *staticSession) UpdateStats(string, string, string, int, int) error { return nil }
func (s *staticSession) SetStaging(bool) error                              { return nil }
func (s *staticSession) ProxyAll() (bool, error)                            { return s.proxyAll, nil }
func (s *staticSession) BandwidthUpdate(int, int, int, int) error           { return nil }
func (s *staticSession) Locale() (string, error)                            { return s.locale, nil }
func (s *staticSession) GetTimeZone() (string, error)                       { return s.timeZone, nil }
func (s *staticSession) Code() (string, error)                              { return s.code, nil }
func (s *staticSession) GetCountryCode() (string, error)                    { return s.countryCode, nil }
func (s *staticSession) GetForcedCountryCode() (string, error)              { return s.forcedCountryCode, nil }
func (s *staticSession) GetDNSServer() (string, error)                      { return s.dnsServer, nil }
func (s *staticSession) Provider() (string, error)                          { return s.provider, nil }
func (s *staticSession) AppVersion() (string, error)                        { return s.appVersion, nil }
func (s *staticSession) IsPlayVersion() (bool, error)                       { return false, nil }
func (s *staticSession) Email() (string, error)                             { return s.email, nil }
func (s *staticSession) Currency() (string, error)                          { return s.currency, nil }
func (s *staticSession) DeviceOS() (string, error)                          { return s.deviceOS, nil }
func (s *staticSession) IsProUser() (bool, error)                           { return s.isProUser, nil }
func (s *staticSession) SerializedInternalHeaders() (string, error)         { return "", nil }
func (s *staticSession) SetSentryExtra(key, value string) error             { return nil }

func TestCachingSession(t *testing.T) {
	s := &staticSession{
		deviceID:          "a",
		userID:            2,
		token:             "b",
		proxyAll:          true,
		locale:            "d",
		timeZone:          "e",
		code:              "f",
		countryCode:       "g",
		forcedCountryCode: "h",
		dnsServer:         "i",
		provider:          "j",
		appVersion:        "k",
		isPlayVersion:     false,
		email:             "l",
		currency:          "m",
		deviceOS:          "n",
		isProUser:         true,
	}

	// make a copy of the session to remember the initial values
	sCopy := &staticSession{}
	*sCopy = *s

	cs := wrapCaching(s)

	checkString := func(expected string, fn func() (string, error)) {
		actual, err := fn()
		require.NoError(t, err)
		assert.Equal(t, expected, actual)
	}

	checkInt64 := func(expected int64, fn func() (int64, error)) {
		actual, err := fn()
		require.NoError(t, err)
		assert.Equal(t, expected, actual)
	}

	checkBool := func(expected bool, fn func() (bool, error)) {
		actual, err := fn()
		require.NoError(t, err)
		assert.Equal(t, expected, actual)
	}

	// make sure we get the original values
	checkString(s.deviceID, cs.GetDeviceID)
	checkInt64(s.userID, cs.GetUserID)
	checkString(s.token, cs.GetToken)
	checkBool(s.proxyAll, cs.ProxyAll)
	checkString(s.locale, cs.Locale)
	checkString(s.timeZone, cs.GetTimeZone)
	checkString(s.code, cs.Code)
	checkString(s.countryCode, cs.GetCountryCode)
	checkString(s.forcedCountryCode, cs.GetForcedCountryCode)
	checkString(s.dnsServer, cs.GetDNSServer)
	checkString(s.provider, cs.Provider)
	checkString(s.appVersion, cs.AppVersion)
	checkBool(s.isPlayVersion, cs.IsPlayVersion)
	checkString(s.email, cs.Email)
	checkString(s.currency, cs.Currency)
	checkString(s.deviceOS, cs.DeviceOS)
	checkBool(s.isPlayVersion, cs.IsPlayVersion)

	// now modify the original session and make sure we still get the initial (cached) values
	s.deviceID = "a"
	s.userID = 2
	s.token = "b"
	s.proxyAll = true
	s.locale = "d"
	s.timeZone = "e"
	s.code = "f"
	s.countryCode = "g"
	s.forcedCountryCode = "h"
	s.dnsServer = "i"
	s.provider = "j"
	s.appVersion = "k"
	s.isPlayVersion = false
	s.email = "l"
	s.currency = "m"
	s.deviceOS = "n"
	s.isProUser = true

	checkString(sCopy.deviceID, cs.GetDeviceID)
	checkInt64(sCopy.userID, cs.GetUserID)
	checkString(sCopy.token, cs.GetToken)
	checkBool(sCopy.proxyAll, cs.ProxyAll)
	checkString(sCopy.locale, cs.Locale)
	checkString(sCopy.timeZone, cs.GetTimeZone)
	checkString(sCopy.code, cs.Code)
	checkString(sCopy.countryCode, cs.GetCountryCode)
	checkString(sCopy.forcedCountryCode, cs.GetForcedCountryCode)
	checkString(sCopy.dnsServer, cs.GetDNSServer)
	checkString(sCopy.provider, cs.Provider)
	checkString(sCopy.appVersion, cs.AppVersion)
	checkBool(sCopy.isPlayVersion, cs.IsPlayVersion)
	checkString(sCopy.email, cs.Email)
	checkString(sCopy.currency, cs.Currency)
	checkString(sCopy.deviceOS, cs.DeviceOS)
	checkBool(sCopy.isPlayVersion, cs.IsPlayVersion)
}

func TestCachedString(t *testing.T) {
	v := "a"
	c := &cachedString{
		maxAge: 100 * time.Millisecond,
		fetch: func() (string, error) {
			return v, nil
		},
	}

	get := func() string {
		val, err := c.get()
		require.NoError(t, err)
		return val
	}

	assert.Equal(t, "a", get(), "initial value")
	v = "b"
	assert.Equal(t, "a", get(), "cached value")
	time.Sleep(100 * time.Millisecond)
	assert.Equal(t, "b", get(), "fresh value")
}

func TestCachedInt64(t *testing.T) {
	v := int64(1)
	c := &cachedInt64{
		maxAge: 100 * time.Millisecond,
		fetch: func() (int64, error) {
			return v, nil
		},
	}

	get := func() int64 {
		val, err := c.get()
		require.NoError(t, err)
		return val
	}

	assert.Equal(t, int64(1), get(), "initial value")
	v = 2
	assert.Equal(t, int64(1), get(), "cached value")
	time.Sleep(100 * time.Millisecond)
	assert.Equal(t, int64(2), get(), "fresh value")
}

func TestCachedBool(t *testing.T) {
	v := true
	c := &cachedBool{
		maxAge: 100 * time.Millisecond,
		fetch: func() (bool, error) {
			return v, nil
		},
	}

	get := func() bool {
		val, err := c.get()
		require.NoError(t, err)
		return val
	}

	assert.True(t, get(), "initial value")
	v = false
	assert.True(t, get(), "cached value")
	time.Sleep(100 * time.Millisecond)
	assert.False(t, get(), "fresh value")
}
