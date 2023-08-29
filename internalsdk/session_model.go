package internalsdk

import (
	"fmt"

	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	*baseModel
}

// List of const we are using for Session Model
// Might be eaier to move all const at one place
const DEVICE_ID = "deviceid"
const PAYMENT_TEST_MODE = "paymentTestMode"
const USER_ID = "userid"
const TOKEN = "token"
const PATH_PRO_USER = "prouser"
const PATH_SDK_VERSION = "sdkVersion"
const PATH_USER_LEVEL = "userLevel"
const CHAT_ENABLED = "chatEnabled"
const DEVELOPMNET_MODE = "developmentMode"
const GEO_COUNTRY_CODE = "geo_country_code"
const SERVER_COUNTRY = "server_country"
const SERVER_COUNTRY_CODE = "server_country_code"
const SERVER_CITY = "server_city"
const HAS_SUCCEEDING_PROXY = "hasSucceedingProxy"
const LATEST_BANDWIDTH = "latest_bandwidth"
const TIMEZONE_ID = "timezone_id"
const REFERRAL_CODE = "referral"
const FORCE_COUNTRY = "forceCountry"
const DNS_DETECTOR = "dns_detector"
const PROVIDER = "provider"
const EMAIL_ADDRESS = "email_address"
const CURRENCY_CODE = "currency_Code"
const PRO_USER = "prouser"
const REPLICA_ADDR = "replicaAddr"
const SPLIT_TUNNELING = "splitTunneling"
const LANG = "lang"

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(schema string, mdb minisql.DB) (*SessionModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}

	model := &SessionModel{base.(*baseModel)}
	return model, nil
}

func (s *SessionModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "initSesssionModel":
		jsonString := arguments.Get(0)
		err := initSessionModel(s.baseModel, jsonString.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setTimeZone":
		// Get timezone id
		timezoneId := arguments.Get(0)
		err := setTimeZone(s.baseModel, timezoneId.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setReferalCode":
		referralCode := arguments.Get(0)
		err := setReferalCode(s.baseModel, referralCode.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setForceCountry":
		forceCountry := arguments.Get(0)
		err := setForceCountry(s.baseModel, forceCountry.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setDNSServer":
		// Todo Implement SetDns server
		err := setDNSServer(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setProvider":
		// Todo Implement setProvider server
		err := setProvider(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}

	case "setEmail":
		// Todo Implement setEmail server
		err := setEmail(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setCurrency":
		// Todo Implement setCurrency server
		err := setCurrency(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setProUser":
		// Todo Implement setCurrency server
		err := setProUser(s.baseModel, false)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setLocal":
		local := arguments.Get(0)
		err := setLocale(s.baseModel, local.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	default:

		return s.baseModel.InvokeMethod(method, arguments)
	}
}

// InvokeMethod handles method invocations on the SessionModel.
func initSessionModel(m *baseModel, jsonString string) error {
	// Init few path for startup
	return putFromJson(jsonString, m.db)
}

func (s *SessionModel) GetAppName() string {
	return "Lantern-IOS"
}

func (s *SessionModel) GetDeviceID() string {
	byte, err := s.baseModel.db.Get(DEVICE_ID)
	panicIfNecessary(err)
	//Todo Find better way to deserialize the values
	// Also fine generic way
	return string(byte)
}

func (s *SessionModel) GetUserID() string {
	paymentTestMode, err := s.baseModel.db.Get(PAYMENT_TEST_MODE)
	panicIfNecessary(err)
	//Todo find way to deserialize the values
	paymentTestModeStr := string(paymentTestMode)
	if paymentTestModeStr == "true" {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		return "9007199254740992L"
	} else {
		userId, err := s.baseModel.db.Get(USER_ID)
		panicIfNecessary(err)
		return string(userId)
	}
}
func (s *SessionModel) GetToken() string {
	paymentTestMode, err := s.baseModel.db.Get(PAYMENT_TEST_MODE)
	panicIfNecessary(err)
	//Todo find way to deserialize the values
	paymentTestModeStr := string(paymentTestMode)
	if paymentTestModeStr == "true" {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		return "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA"
	} else {
		userId, err := s.baseModel.db.Get(TOKEN)
		panicIfNecessary(err)
		return string(userId)
	}
}
func (s *SessionModel) SetCountry(country string) error {
	//Find better way to do it
	err := pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, GEO_COUNTRY_CODE, country, "")
		return nil
	})
	return err
}

func (s *SessionModel) UpdateAdSettings(adsetting AdSettings) error {
	// Not using these ads anymore
	return nil
}

func (s *SessionModel) UpdateStats(city string, country string, countryCode string, httpsUpgrades int, adsBlocked int, hasSucceedingProxy bool) error {
	err := pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, SERVER_COUNTRY, country, "")
		pathdb.Put[string](tx, SERVER_CITY, city, "")
		pathdb.Put[string](tx, SERVER_COUNTRY_CODE, countryCode, "")
		pathdb.Put[bool](tx, HAS_SUCCEEDING_PROXY, hasSucceedingProxy, "")
		// Not using ads blocked any more
		return nil
	})
	return err
}

func (s *SessionModel) SetStaging(stageing bool) error {
	// Not using stageing anymore
	return nil
}

func (s *SessionModel) BandwidthUpdate(percent int, remaining int, allowed int, ttlSeconds int) error {
	pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[int](tx, LATEST_BANDWIDTH, percent, "")
		return nil
	})

	//Here we are using eventBus to post or update UI
	// Find way do it from go somehow
	return nil
}

func (s *SessionModel) Locale() (string, error) {
	// For now just send back english by default
	// Once have machisim but to dyanmic
	locale, err := s.baseModel.db.Get(LANG)
	panicIfNecessary(err)
	return string(locale), nil
}

func setLocale(m *baseModel, langCode string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, LANG, langCode, "")
		return nil
	})
	return nil
}

func (s *SessionModel) GetTimeZone() (string, error) {
	timezoneId, err := s.baseModel.db.Get(TIMEZONE_ID)
	panicIfNecessary(err)
	// For now just send back english by default
	// Once have machisim change to dyanmic
	return string(timezoneId), nil
}

// set timezone
func setTimeZone(m *baseModel, timezoneId string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, TIMEZONE_ID, timezoneId, "")
		return nil
	})
	byte, error := m.db.Get(TIMEZONE_ID)
	panicIfNecessary(error)
	log.Debugf("Successfulyy added timezone%v", string(byte))
	return nil
}

// Todo change method name to referral code
func (s *SessionModel) Code() (string, error) {
	//Set the timezeon from swift
	referralCode, err := s.baseModel.db.Get(REFERRAL_CODE)
	panicIfNecessary(err)
	return string(referralCode), nil
}

func setReferalCode(m *baseModel, referralCode string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, REFERRAL_CODE, referralCode, "")
		return nil
	})
	return nil
}

// Todo need to make chanegs for Force country setup
func (s *SessionModel) GetCountryCode() (string, error) {
	//Set the timezeon from swift
	forceCountry, err := s.db.Get(FORCE_COUNTRY)
	panicIfNecessary(err)
	contryInString := string(forceCountry)
	if contryInString != "" {
		return string(forceCountry), nil
	}
	countryCode, err := s.baseModel.db.Get(GEO_COUNTRY_CODE)
	panicIfNecessary(err)
	return string(countryCode), nil
}

func (s *SessionModel) GetForcedCountryCode() (string, error) {
	forceCountry, err := s.baseModel.db.Get(FORCE_COUNTRY)
	panicIfNecessary(err)
	return string(forceCountry), nil
}

func setForceCountry(m *baseModel, forceCountry string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, FORCE_COUNTRY, forceCountry, "")
		return nil
	})
	return nil
}
func (s *SessionModel) GetDNSServer() (string, error) {
	dns, err := s.db.Get(DNS_DETECTOR)
	panicIfNecessary(err)
	return string(dns), nil
}

func setDNSServer(m *baseModel, forceCountry string) error {
	// Implement this
	// Check out kotlin code
	return nil
}

func (s *SessionModel) Provider() (string, error) {
	provider, err := s.db.Get(PROVIDER)
	panicIfNecessary(err)
	return string(provider), nil
}

func setProvider(m *baseModel, provider string) error {
	// Implement this
	// Check out kotlin code
	return nil
}

// Todo: Change this method name to IsStoreVersion
func (s *SessionModel) IsPlayVersion() (bool, error) {
	// For now return static to yes
	return true, nil
}

func (s *SessionModel) Email() (string, error) {
	email, err := s.db.Get(EMAIL_ADDRESS)
	panicIfNecessary(err)
	return string(email), nil
}

func setEmail(m *baseModel, email string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, EMAIL_ADDRESS, email, "")
		return nil
	})
	return nil
}

func (s *SessionModel) Currency() (string, error) {
	currencyCode, err := s.db.Get(CURRENCY_CODE)
	panicIfNecessary(err)
	return string(currencyCode), nil
}

func setCurrency(m *baseModel, currencyCode string) error {
	// Todo Implement this method
	return fmt.Errorf("Method not implemented yet")
}

func (s *SessionModel) DeviceOS() (string, error) {
	// return staif for now
	return "IOS", nil
}

func (s *SessionModel) IsProUser() (bool, error) {
	// return static for now
	return false, nil
}
func setProUser(m *baseModel, isPro bool) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, PRO_USER, isPro, "")
		return nil
	})
	return nil
}

func (s *SessionModel) SetReplicaAddr(replicaAddr string) error {
	pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, REPLICA_ADDR, replicaAddr, "")
		return nil
	})
	return nil
}

func (s *SessionModel) ForceReplica() bool {
	// return static for now
	return true
}

func (s *SessionModel) SetChatEnabled(chatEnable bool) {
	pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, CHAT_ENABLED, chatEnable, "")
		return nil
	})
}

func (s *SessionModel) SplitTunnelingEnabled() (bool, error) {
	// Return static for now
	return true, nil
}

func (s *SessionModel) SerializedInternalHeaders() (string, error) {
	// Return static for now
	// Todo implement this method
	return "", nil
}
