package internalsdk

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"

	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
	"google.golang.org/protobuf/proto"
)

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	*baseModel
}

// List of const we are using for Session Model
// Might be eaier to move all const at one place
// All keys are expose to front end so we can use same to avoid duplication and reduce error
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
const ACCEPTED_TERMS_VERSION = "accepted_terms_version"
const ADS_ENABLED = "adsEnabled"
const CAS_ADS_ENABLED = "casAsEnabled"
const CURRENT_TERMS_VERSION = 1
const IS_PLAY_VERSION = "playVersion"
const SET_SELECTED_TAB = "/selectedTab"

// All method names
// this expose to client IOS & Andorid
const SESSION_MODEL_METHOD_INIT_MODEL = "initSesssionModel"
const SESSION_MODEL_METHOD_SET_TIMEZONE = "setTimeZone"
const SESSION_MODEL_METHOD_GET_BANDWIDTH = "getBandwidth"
const SESSION_MODEL_METHOD_SET_DEVICEID = "setDeviceId"
const SESSION_MODEL_METHOD_SET_REFERAL_CODE = "setReferalCode"
const SESSION_MODEL_METHOD_SET_FORCE_COUNTRY = "setForceCountry"
const SESSION_MODEL_METHOD_SET_DNS_SERVER = "setDNSServer"
const SESSION_MODEL_METHOD_SET_PROVIDER = "setProvider"
const SESSION_MODEL_METHOD_SET_EMAIL = "setEmail"
const SESSION_MODEL_METHOD_SET_PRO_USER = "setProUser"
const SESSION_MODEL_METHOD_SET_LOCAL = "setLocal"
const SESSION_MODEL_METHOD_SET_CURRENCY = "setCurrency"
const SESSION_MODEL_METHOD_ACCEPT_TERMS = "acceptTerms"
const SESSION_MODEL_METHOD_SET_STORE_VERSION = "setStoreVersion"
const SESSION_MODEL_METHOD_SET_SELECTED_TAB = "setSelectedTab"
const SESSION_MODEL_METHOD_CREATE_USER = "createUser"

type TabData struct {
	Tab string `json:"tab"`
}

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(schema string, mdb minisql.DB) (*SessionModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}

	model := &SessionModel{base.(*baseModel)}
	return model, nil
}

// TO check if session model implemnets all method or not
// var s Session = &SessionModel{}

func (s *SessionModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case SESSION_MODEL_METHOD_INIT_MODEL:
		jsonString := arguments.Get(0)
		err := initSessionModel(s.baseModel, jsonString.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_TIMEZONE:
		// Get timezone id
		timezoneId := arguments.Get(0)
		err := setTimeZone(s.baseModel, timezoneId.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_GET_BANDWIDTH:
		limit, err := getBandwidthLimit(s.baseModel)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueString(limit), nil
		}

	case SESSION_MODEL_METHOD_SET_DEVICEID:
		deviceID := arguments.Get(0)
		err := setDeviceId(s.baseModel, deviceID.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_REFERAL_CODE:
		referralCode := arguments.Get(0)
		err := setReferalCode(s.baseModel, referralCode.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_FORCE_COUNTRY:
		forceCountry := arguments.Get(0)
		err := setForceCountry(s.baseModel, forceCountry.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_DNS_SERVER:
		dns := arguments.Get(0)
		err := setDNSServer(s.baseModel, dns.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_PROVIDER:
		// Todo Implement setProvider server
		err := setProvider(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}

	case SESSION_MODEL_METHOD_SET_EMAIL:
		// Todo Implement setEmail server
		err := setEmail(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_CURRENCY:
		// Todo Implement setCurrency server
		err := setCurrency(s.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_PRO_USER:
		err := setProUser(s.baseModel, false)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_LOCAL:
		local := arguments.Get(0)
		err := setLocale(s.baseModel, local.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_ACCEPT_TERMS:
		err := acceptTerms(s.baseModel)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}

	case SESSION_MODEL_METHOD_SET_STORE_VERSION:
		IsStoreVersion := arguments.Get(0)
		err := setStoreVersion(s.baseModel, IsStoreVersion.Bool())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case SESSION_MODEL_METHOD_SET_SELECTED_TAB:
		jsonString := arguments.Get(0).String()

		var tabData TabData
		err := json.Unmarshal([]byte(jsonString), &tabData)
		if err != nil {
			return nil, err
		}

		err = setSelectedTab(s.baseModel, tabData.Tab)
		if err != nil {
			return nil, err
		}
		return minisql.NewValueBool(true), nil
	case SESSION_MODEL_METHOD_CREATE_USER:
		local := arguments.Get(0)
		err := userCreate(s.baseModel, local.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	default:
		return s.baseModel.InvokeMethod(method, arguments)
	}
}

// Internal functions that manage method
func (s *SessionModel) StartService(configDir string,
	locale string,
	settings Settings) {
	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
	session := &panickingSessionImpl{s}
	startOnce.Do(func() {
		go run(configDir, locale, settings, session)
	})

}

// InvokeMethod handles method invocations on the SessionModel.
func initSessionModel(m *baseModel, jsonString string) error {
	// Init few path for startup
	return putFromJson(jsonString, m.db)
}

func (s *SessionModel) GetAppName() string {
	return "Lantern-IOS"
}

func setDeviceId(m *baseModel, deviceID string) error {
	// Find better way to do it
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, DEVICE_ID, deviceID, "")
		return nil
	})
	return err
}

func (s *SessionModel) GetDeviceID() (string, error) {
	byte, err := s.baseModel.db.Get(DEVICE_ID)
	if err != nil {
		return "", err
	}
	//Todo Find better way to deserialize the values
	// Also fine generic way
	return string(byte), nil
}

// Todo There is some issue with user id changeing it value
// When  Coverting from bytes to Float
func (s *SessionModel) GetUserID() (int64, error) {
	paymentTestMode, err := s.baseModel.db.Get(PAYMENT_TEST_MODE)
	if err != nil {
		return 0, err
	}
	//Todo find way to deserialize the values
	paymentTestModeStr := string(paymentTestMode)
	if paymentTestModeStr == "true" && paymentTestModeStr != "" {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		i64, err := strconv.ParseInt("9007199254740992L", 10, 64)
		if err != nil {
			return 0, err
		}
		return i64, nil
	} else {
		userId, err := s.baseModel.db.Get(USER_ID)
		if err != nil {
			return 0, err
		}
		userId = userId[1:]
		newUserId, err := BytesToFloat64LittleEndian(userId)
		if err != nil {
			return 0, err
		}
		i64 := int64(newUserId)
		return i64, nil
	}
}
func (s *SessionModel) GetToken() (string, error) {
	paymentTestMode, err := s.baseModel.db.Get(PAYMENT_TEST_MODE)
	if err != nil {
		return "", err
	}
	//Todo find way to deserialize the values
	paymentTestModeStr := string(paymentTestMode)
	if paymentTestModeStr == "true" {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		return "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA", nil
	} else {
		userId, err := s.baseModel.db.Get(TOKEN)
		if err != nil {
			return "", err
		}
		return string(userId), nil
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

// Keep name as p1,p2,p3.....
// Name become part of Objective c so this is important
func (s *SessionModel) UpdateStats(p0 string, p1 string, p2 string, p3 int, p4 int, p5 bool) error {
	if p0 != "" && p1 != "" && p2 != "" {
		serverInfo := &ServerInfo{
			City:        p0,
			Country:     p1,
			CountryCode: p2,
		}

		// Serialize the ServerInfo object to byte slice
		serverInfoBytes, serverErr := proto.Marshal(serverInfo)
		if serverErr != nil {
			return serverErr
		}

		log.Debugf("UpdateStats called with city %v and country %v and code %v with proxy %v server info bytes %v", p0, p1, p2, p5, serverInfoBytes)
		err := pathdb.Mutate(s.db, func(tx pathdb.TX) error {
			pathdb.Put[string](tx, SERVER_COUNTRY, p1, "")
			pathdb.Put[string](tx, SERVER_CITY, p0, "")
			pathdb.Put[string](tx, SERVER_COUNTRY_CODE, p2, "")
			pathdb.Put[bool](tx, HAS_SUCCEEDING_PROXY, p5, "")
			pathdb.Put[[]byte](tx, PATH_SERVER_INFO, serverInfoBytes, "")

			// Not using ads blocked any more
			return nil
		})
		return err
	}
	return nil
}

func (s *SessionModel) SetStaging(stageing bool) error {
	// Not using stageing anymore
	return nil
}

// Keep name as p1,p2,p3.....
// Name become part of Objective c so this is important
func (s *SessionModel) BandwidthUpdate(p1 int, p2 int, p3 int, p4 int) error {
	err := pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[int](tx, LATEST_BANDWIDTH, p1, "")
		return nil
	})
	return err
}

func getBandwidthLimit(m *baseModel) (string, error) {
	percent, err := m.db.Get(LATEST_BANDWIDTH)
	if err != nil {
		return "", err
	}
	return string(percent), nil
}

func (s *SessionModel) Locale() (string, error) {
	// For now just send back english by default
	// Once have machisim but to dyanmic
	locale, err := s.baseModel.db.Get(LANG)
	if err != nil {
		return "", err
	}
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
	if err != nil {
		return "", err
	}
	return string(timezoneId), nil
}

// set timezone
func setTimeZone(m *baseModel, timezoneId string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, TIMEZONE_ID, timezoneId, "")
		return nil
	})
	return nil
}

// Todo change method name to referral code
func (s *SessionModel) Code() (string, error) {
	//Set the timezeon from swift
	referralCode, err := s.baseModel.db.Get(REFERRAL_CODE)
	if err != nil {
		return "", err
	}
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
	forceCountry, forceCountryErr := s.db.Get(FORCE_COUNTRY)
	if forceCountryErr != nil {
		return "", forceCountryErr
	}
	contryInString := string(forceCountry)
	if contryInString != "" {
		return string(forceCountry), nil
	}
	countryCode, err := s.baseModel.db.Get(GEO_COUNTRY_CODE)
	if err != nil {
		return "", err
	}
	return string(countryCode), nil
}

func (s *SessionModel) GetForcedCountryCode() (string, error) {
	forceCountry, err := s.baseModel.db.Get(FORCE_COUNTRY)
	if err != nil {
		return "", err
	}
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
	if err != nil {
		return "", err
	}
	return string(dns), nil
}

func setDNSServer(m *baseModel, dnsServer string) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, DNS_DETECTOR, dnsServer, "")
		return nil
	})
	return err
}

func (s *SessionModel) Provider() (string, error) {
	provider, err := s.db.Get(PROVIDER)
	if err != nil {
		return "", err
	}
	return string(provider), nil
}

func setProvider(m *baseModel, provider string) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, PROVIDER, provider, "")
		return nil
	})
	return err
}

func (s *SessionModel) IsStoreVersion() (bool, error) {
	osStoreVersion, err := s.db.Get(IS_PLAY_VERSION)
	if err != nil {
		return false, err
	}
	if string(osStoreVersion) == "true" {
		return true, nil
	}
	return false, nil
}

func (s *SessionModel) Email() (string, error) {
	email, err := s.db.Get(EMAIL_ADDRESS)
	if err != nil {
		return "", err
	}
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
	proUser, err := s.baseModel.db.Get(PRO_USER)
	if err != nil {
		return false, err
	}
	return (string(proUser) == "true"), nil
}
func setProUser(m *baseModel, isPro bool) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, PRO_USER, isPro, "")
		return nil
	})
	return nil
}

func (s *SessionModel) SetReplicaAddr(replicaAddr string) {
	pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		//For now force replicate to disbale it
		pathdb.Put[string](tx, REPLICA_ADDR, "", "")
		return nil
	})
}

func (s *SessionModel) ForceReplica() bool {
	// return static for now
	return false
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

func (s *SessionModel) SetShowInterstitialAdsEnabled(adsEnable bool) {
	pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, ADS_ENABLED, adsEnable, "")
		return nil
	})
}

func (s *SessionModel) SetCASShowInterstitialAdsEnabled(casEnable bool) {
	pathdb.Mutate(s.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, CAS_ADS_ENABLED, casEnable, "")
		return nil
	})
}

func (s *SessionModel) SerializedInternalHeaders() (string, error) {
	// Return static for now
	// Todo implement this method
	return "", nil
}

func acceptTerms(m *baseModel) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[int](tx, ACCEPTED_TERMS_VERSION, CURRENT_TERMS_VERSION, "")
		return nil
	})
	return nil
}

func setStoreVersion(m *baseModel, isStoreVersion bool) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, IS_PLAY_VERSION, isStoreVersion, "")
		return nil
	})
	return nil
}
func setSelectedTab(m *baseModel, tap string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, SET_SELECTED_TAB, tap, "")
		return nil
	})
	return nil
}

func setUserIdAndToken(m *baseModel, userId float64, token string) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[float64](tx, USER_ID, userId, "")
		pathdb.Put[string](tx, TOKEN, token, "")
		return nil
	})
	return err
}

type UserResponse struct {
	UserID       float64  `json:"userId"`
	Code         string   `json:"code"`
	Token        string   `json:"token"`
	Referral     string   `json:"referral"`
	Locale       string   `json:"locale"`
	Servers      []string `json:"servers"`
	Inviters     []string `json:"inviters"`
	Invitees     []string `json:"invitees"`
	Devices      []string `json:"devices"`
	YinbiEnabled bool     `json:"yinbiEnabled"`
}

// Create user
// Todo-: Create Sprate http client to manag and reuse client
func userCreate(m *baseModel, local string) error {
	deviecId, err := m.db.Get(DEVICE_ID)
	if err != nil {
		return err
	}

	requestBodyMap := map[string]string{
		"locale": local,
	}
	// Marshal the map to JSON
	requestBody, err := json.Marshal(requestBodyMap)
	if err != nil {
		log.Errorf("Error marshaling request body: %v", err)
		return err
	}
	// Create a new request
	req, err := http.NewRequest("POST", "https://api.getiantem.org/user-create", bytes.NewBuffer(requestBody))
	if err != nil {
		log.Errorf("Error creating new request: %v", err)
		return err
	}

	// Add headers
	req.Header.Set("X-Lantern-Device-Id", string(deviecId))
	log.Debugf("Headers set")
	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("Error sending request: %v", err)

		return err
	}
	defer resp.Body.Close()
	var userResponse UserResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userResponse); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return err
	}
	//Save user refferal code
	if userResponse.Referral != "" {
		err := setReferalCode(m, userResponse.Referral)
		if err != nil {
			return err
		}
	}
	//Save user id and token
	setUserIdAndToken(m, userResponse.UserID, userResponse.Token)
	log.Debugf("Created new Lantern user: %+v", userResponse)
	return nil
}
