package internalsdk

import (
	"sync"
	"time"
)

const (
	cacheShort = 5 * time.Second
	cacheLong  = 60 * time.Second
)

// cachingSession is a Session that remembers certain values for a limited period of time
// to avoid excessive calls to Java
type cachingSession struct {
	Session

	deviceID          *cachedString
	userID            *cachedInt64
	token             *cachedString
	proxyAll          *cachedBool
	locale            *cachedString
	timeZone          *cachedString
	code              *cachedString
	countryCode       *cachedString
	forcedCountryCode *cachedString
	dnsServer         *cachedString
	provider          *cachedString
	appVersion        *cachedString
	isPlayVersion     *cachedBool
	email             *cachedString
	currency          *cachedString
	deviceOS          *cachedString
	isProUser         *cachedBool
}

func wrapCaching(s Session) Session {
	return &cachingSession{
		Session: s,
		deviceID: &cachedString{
			maxAge: cacheLong,
			fetch:  s.GetDeviceID,
		},
		userID: &cachedInt64{
			maxAge: cacheShort,
			fetch:  s.GetUserID,
		},
		token: &cachedString{
			maxAge: cacheShort,
			fetch:  s.GetToken,
		},
		proxyAll: &cachedBool{
			maxAge: cacheShort,
			fetch:  s.ProxyAll,
		},
		locale: &cachedString{
			maxAge: cacheLong,
			fetch:  s.Locale,
		},
		timeZone: &cachedString{
			maxAge: cacheLong,
			fetch:  s.GetTimeZone,
		},
		code: &cachedString{
			maxAge: cacheShort,
			fetch:  s.Code,
		},
		countryCode: &cachedString{
			maxAge: cacheLong,
			fetch:  s.GetCountryCode,
		},
		forcedCountryCode: &cachedString{
			maxAge: cacheLong,
			fetch:  s.GetForcedCountryCode,
		},
		dnsServer: &cachedString{
			maxAge: cacheLong,
			fetch:  s.GetDNSServer,
		},
		provider: &cachedString{
			maxAge: cacheShort,
			fetch:  s.Provider,
		},
		appVersion: &cachedString{
			maxAge: cacheLong,
			fetch:  s.AppVersion,
		},
		isPlayVersion: &cachedBool{
			maxAge: cacheLong,
			fetch:  s.IsPlayVersion,
		},
		email: &cachedString{
			maxAge: cacheShort,
			fetch:  s.Email,
		},
		currency: &cachedString{
			maxAge: cacheShort,
			fetch:  s.Currency,
		},
		deviceOS: &cachedString{
			maxAge: cacheLong,
			fetch:  s.DeviceOS,
		},
		isProUser: &cachedBool{
			maxAge: cacheShort,
			fetch:  s.IsProUser,
		},
	}
}

func (s *cachingSession) GetDeviceID() (string, error) {
	return s.deviceID.get()
}

func (s *cachingSession) GetUserID() (int64, error) {
	return s.userID.get()
}

func (s *cachingSession) GetToken() (string, error) {
	return s.token.get()
}

func (s *cachingSession) ProxyAll() (bool, error) {
	return s.proxyAll.get()
}

func (s *cachingSession) Locale() (string, error) {
	return s.locale.get()
}

func (s *cachingSession) GetTimeZone() (string, error) {
	return s.timeZone.get()
}

func (s *cachingSession) Code() (string, error) {
	return s.code.get()
}

func (s *cachingSession) GetCountryCode() (string, error) {
	return s.countryCode.get()
}

func (s *cachingSession) GetForcedCountryCode() (string, error) {
	return s.forcedCountryCode.get()
}

func (s *cachingSession) GetDNSServer() (string, error) {
	return s.dnsServer.get()
}

func (s *cachingSession) Provider() (string, error) {
	return s.provider.get()
}

func (s *cachingSession) AppVersion() (string, error) {
	return s.appVersion.get()
}

func (s *cachingSession) IsPlayVersion() (bool, error) {
	return s.isPlayVersion.get()
}

func (s *cachingSession) Email() (string, error) {
	return s.email.get()
}

func (s *cachingSession) Currency() (string, error) {
	return s.currency.get()
}

func (s *cachingSession) DeviceOS() (string, error) {
	return s.deviceOS.get()
}

func (s *cachingSession) IsProUser() (bool, error) {
	return s.isProUser.get()
}

type cachedString struct {
	maxAge      time.Duration
	lastUpdated time.Time
	value       string
	fetch       func() (string, error)
	mx          sync.Mutex
}

func (c *cachedString) get() (string, error) {
	c.mx.Lock()
	defer c.mx.Unlock()

	now := time.Now()
	if now.Sub(c.lastUpdated) < c.maxAge {
		return c.value, nil
	}
	value, err := c.fetch()
	if err == nil {
		c.lastUpdated = now
		c.value = value
	}
	return value, err
}

type cachedInt64 struct {
	maxAge      time.Duration
	lastUpdated time.Time
	value       int64
	fetch       func() (int64, error)
	mx          sync.Mutex
}

func (c *cachedInt64) get() (int64, error) {
	c.mx.Lock()
	defer c.mx.Unlock()

	now := time.Now()
	if now.Sub(c.lastUpdated) < c.maxAge {
		return c.value, nil
	}
	value, err := c.fetch()
	if err == nil {
		c.lastUpdated = now
		c.value = value
	}
	return value, err
}

type cachedBool struct {
	maxAge      time.Duration
	lastUpdated time.Time
	value       bool
	fetch       func() (bool, error)
	mx          sync.Mutex
}

func (c *cachedBool) get() (bool, error) {
	c.mx.Lock()
	defer c.mx.Unlock()

	now := time.Now()
	if now.Sub(c.lastUpdated) < c.maxAge {
		return c.value, nil
	}
	value, err := c.fetch()
	if err == nil {
		c.lastUpdated = now
		c.value = value
	}
	return value, err
}
