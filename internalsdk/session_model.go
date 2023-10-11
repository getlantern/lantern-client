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
const DEVICE = "device"
const MODEL = "model"
const OS_VERSION = "os_version"
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
const EMAIL_ADDRESS = "emailAddress"

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
const PATH_SERVER_INFO = "/server_info"

type SessionModelOpts struct {
	DevelopmentMode bool
	ProUser         bool
	DeviceID        string
	Device          string
	Model           string
	OsVersion       string
	PlayVersion     bool
	Lang            string
	TimeZone        string
}

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(mdb minisql.DB, opts *SessionModelOpts) (*SessionModel, error) {
	base, err := newModel("session", mdb)
	if err != nil {
		return nil, err
	}
	base.db.RegisterType(1000, &ServerInfo{})
	m := &SessionModel{baseModel: base}
	m.initSessionModel(opts)
	return m, nil
}

func (m *SessionModel) InvokeMethod(method string, arguments Arguments) (*minisql.Value, error) {
	switch method {
	case "getBandwidth":
		limit, err := getBandwidthLimit(m.baseModel)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueString(limit), nil
		}
	case "setForceCountry":
		err := setForceCountry(m.baseModel, arguments.Scalar().String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setDNSServer":
		err := setDNSServer(m.baseModel, arguments.Scalar().String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setProvider":
		// Todo Implement setProvider server
		err := setProvider(m.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}

	case "setEmail":
		// Todo Implement setEmail server
		err := setEmail(m.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setProUser":
		// Todo Implement setCurrency server
		err := setCurrency(m.baseModel, "Test")
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setLanguage":
		err := setLanguage(m.baseModel, arguments.Get("lang").String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "acceptTerms":
		err := acceptTerms(m.baseModel)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setStoreVersion":
		err := setStoreVersion(m.baseModel, arguments.Scalar().Bool())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "setSelectedTab":
		err := setSelectedTab(m.baseModel, arguments.Get("tab").String())
		if err != nil {
			return nil, err
		}
		return minisql.NewValueBool(true), nil
	case "reportIssue":
		email := arguments.Get("email").String()
		issue := arguments.Get("issue").String()
		description := arguments.Get("issue").String()
		err := reportIssue(m, email, issue, description)
		if err != nil {
			return nil, err
		}
		return minisql.NewValueBool(true), nil
	case "createUser":
		err := userCreate(m.baseModel, arguments.Scalar().String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	default:
		return m.baseModel.InvokeMethod(method, arguments)
	}
}

// Internal functions that manage method
func (m *SessionModel) StartService(configDir string,
	locale string,
	settings Settings) {
	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
	session := &panickingSessionImpl{m}
	startOnce.Do(func() {
		go run(configDir, locale, settings, session)
	})

}

// InvokeMethod handles method invocations on the SessionModel.
func (m *SessionModel) initSessionModel(opts *SessionModelOpts) error {
	//Check if email if emoty
	email, err := m.baseModel.db.Get(EMAIL_ADDRESS)
	if err != nil {
		log.Debugf("Init Session email error value %v", err)
		return err
	}
	emailStr := string(email)
	if emailStr == "" {
		log.Debugf("Init Session setting email value to an empty string")
		setEmail(m.baseModel, "")
	}
	tx, err := m.db.Begin()
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, DEVELOPMNET_MODE, opts.DevelopmentMode, "")
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, PRO_USER, opts.ProUser, "")
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, DEVICE_ID, opts.DeviceID, "")
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, IS_PLAY_VERSION, opts.PlayVersion, "")
	if err != nil {
		return err
	}
	// Check if lang is already added or not
	// If yes then do not add it
	// This is used for only when user is new
	lang, err := pathdb.Get[string](tx, LANG)
	if err != nil {
		return err
	}
	if lang == "" {
		err = pathdb.Put(tx, LANG, opts.Lang, "")
		if err != nil {
			return err
		}
	}
	err = pathdb.Put(tx, TIMEZONE_ID, opts.TimeZone, "")
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, DEVICE, opts.Device, "")
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, MODEL, opts.Model, "")
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, OS_VERSION, opts.OsVersion, "")
	if err != nil {
		return err
	}
	//Check if user is already registered or not
	userId, err := m.GetUserID()
	if err != nil {
		return err
	}
	if userId == 0 {
		local, err := m.Locale()
		if err != nil {
			return err
		}
		// Create user
		err = userCreate(m.baseModel, local)
		if err != nil {
			return err
		}
	}
	return nil
}

func (m *SessionModel) GetAppName() string {
	return "Lantern-IOS"
}

func (m *SessionModel) GetDeviceID() (string, error) {
	byte, err := m.baseModel.db.Get(DEVICE_ID)
	if err != nil {
		return "", err
	}
	//Todo Find better way to deserialize the values
	// Also fine generic way
	return string(byte), nil
}

// Todo There is some issue with user id changeing it value
// When  Coverting from bytes to Float
func (m *SessionModel) GetUserID() (int64, error) {
	paymentTestMode, err := m.baseModel.db.Get(PAYMENT_TEST_MODE)
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
		userId, err := m.baseModel.db.Get(USER_ID)
		if err != nil {
			return 0, err
		}

		//If userid is null or emtpy return zero to avoid crash
		if string(userId) == "" {
			return 0, nil
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
func (m *SessionModel) GetToken() (string, error) {
	paymentTestMode, err := m.baseModel.db.Get(PAYMENT_TEST_MODE)
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
		userId, err := m.baseModel.db.Get(TOKEN)
		if err != nil {
			return "", err
		}
		return string(userId), nil
	}
}
func (m *SessionModel) SetCountry(country string) error {
	//Find better way to do it
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, GEO_COUNTRY_CODE, country, "")
		return nil
	})
	return err
}

func (m *SessionModel) UpdateAdSettings(adsetting AdSettings) error {
	// Not using these ads anymore
	return nil
}

// Keep name as p1,p2,p3.....
// Name become part of Objective c so this is important
func (m *SessionModel) UpdateStats(p0 string, p1 string, p2 string, p3 int, p4 int, p5 bool) error {
	if p0 != "" && p1 != "" && p2 != "" {
		serverInfo := &ServerInfo{
			City:        p0,
			Country:     p1,
			CountryCode: p2,
		}

		err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			pathdb.Put[string](tx, SERVER_COUNTRY, p1, "")
			pathdb.Put[string](tx, SERVER_CITY, p0, "")
			pathdb.Put[string](tx, SERVER_COUNTRY_CODE, p2, "")
			pathdb.Put[bool](tx, HAS_SUCCEEDING_PROXY, p5, "")
			pathdb.Put[*ServerInfo](tx, PATH_SERVER_INFO, serverInfo, "")

			// Not using ads blocked any more
			return nil
		})
		return err
	}
	return nil
}

func (m *SessionModel) SetStaging(stageing bool) error {
	// Not using stageing anymore
	return nil
}

// Keep name as p1,p2,p3.....
// Name become part of Objective c so this is important
func (m *SessionModel) BandwidthUpdate(p1 int, p2 int, p3 int, p4 int) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
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

func (m *SessionModel) Locale() (string, error) {
	locale, err := m.baseModel.db.Get(LANG)
	if err != nil {
		return "", err
	}
	return string(locale), nil
}

func setLanguage(m *baseModel, lang string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, LANG, lang, "")
		return nil
	})
	return nil
}

func (m *SessionModel) GetTimeZone() (string, error) {
	timezoneId, err := m.baseModel.db.Get(TIMEZONE_ID)
	if err != nil {
		return "", err
	}
	return string(timezoneId), nil
}

// Todo change method name to referral code
func (m *SessionModel) Code() (string, error) {
	//Set the timezeon from swift
	referralCode, err := m.baseModel.db.Get(REFERRAL_CODE)
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
func (m *SessionModel) GetCountryCode() (string, error) {
	//Set the timezeon from swift
	forceCountry, forceCountryErr := m.db.Get(FORCE_COUNTRY)
	if forceCountryErr != nil {
		return "", forceCountryErr
	}
	contryInString := string(forceCountry)
	if contryInString != "" {
		return string(forceCountry), nil
	}
	countryCode, err := m.baseModel.db.Get(GEO_COUNTRY_CODE)
	if err != nil {
		return "", err
	}
	return string(countryCode), nil
}

func (m *SessionModel) GetForcedCountryCode() (string, error) {
	forceCountry, err := m.baseModel.db.Get(FORCE_COUNTRY)
	if err != nil {
		log.Debugf("Force country coode error %v", err)
		return "", err
	}
	log.Debugf("Force country %v", forceCountry)
	return string(forceCountry), nil
}

func setForceCountry(m *baseModel, forceCountry string) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, FORCE_COUNTRY, forceCountry, "")
		return nil
	})
	return nil
}
func (m *SessionModel) GetDNSServer() (string, error) {
	dns, err := m.db.Get(DNS_DETECTOR)
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

func (m *SessionModel) Provider() (string, error) {
	provider, err := m.db.Get(PROVIDER)
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

func (m *SessionModel) IsStoreVersion() (bool, error) {
	osStoreVersion, err := m.db.Get(IS_PLAY_VERSION)
	if err != nil {
		return false, err
	}
	if string(osStoreVersion) == "true" {
		return true, nil
	}
	return false, nil
}

func (m *SessionModel) Email() (string, error) {
	email, err := m.db.Get(EMAIL_ADDRESS)
	if err != nil {
		return "", err
	}
	return string(email), nil
}

func setEmail(m *baseModel, email string) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, EMAIL_ADDRESS, email, "")
		return nil
	})
	return err
}

func (m *SessionModel) Currency() (string, error) {
	currencyCode, err := m.db.Get(CURRENCY_CODE)
	panicIfNecessary(err)
	return string(currencyCode), nil
}

func setCurrency(m *baseModel, currencyCode string) error {
	// Todo Implement this method
	return fmt.Errorf("Method not implemented yet")
}

func (m *SessionModel) DeviceOS() (string, error) {
	// return staif for now
	return "IOS", nil
}

func (m *SessionModel) IsProUser() (bool, error) {
	proUser, err := m.baseModel.db.Get(PRO_USER)
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

func (m *SessionModel) SetReplicaAddr(replicaAddr string) {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		//For now force replicate to disbale it
		pathdb.Put[string](tx, REPLICA_ADDR, "", "")
		return nil
	})
}

func (m *SessionModel) ForceReplica() bool {
	// return static for now
	return false
}

func (m *SessionModel) SetChatEnabled(chatEnable bool) {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, CHAT_ENABLED, chatEnable, "")
		return nil
	})
}

func (m *SessionModel) SplitTunnelingEnabled() (bool, error) {
	// Return static for now
	return true, nil
}

func (m *SessionModel) SetShowInterstitialAdsEnabled(adsEnable bool) {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, ADS_ENABLED, adsEnable, "")
		return nil
	})
}

func (m *SessionModel) SetCASShowInterstitialAdsEnabled(casEnable bool) {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, CAS_ADS_ENABLED, casEnable, "")
		return nil
	})
}

func (m *SessionModel) SerializedInternalHeaders() (string, error) {
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

func reportIssue(session *SessionModel, email string, issue string, description string) error {
	// Check if email is there is yes then store it
	if email != "" {
		err := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			pathdb.Put[string](tx, EMAIL_ADDRESS, email, "")
			return nil
		})
		if err != nil {
			return err
		}
	}

	//Check If user is pro or not
	pro, proErr := session.IsProUser()
	if proErr != nil {
		return proErr
	}
	var level string
	if pro {
		level = "pro"
	} else {
		level = "free"
	}

	// Get Deive id
	model, modelErr := session.db.Get(MODEL)
	if modelErr != nil {
		return modelErr
	}

	// Get os version
	osVersion, osVersionErr := session.db.Get(OS_VERSION)
	if osVersionErr != nil {
		return osVersionErr
	}
	// Get os version
	device, deviceErr := session.db.Get(DEVICE)
	if deviceErr != nil {
		return deviceErr
	}
	// Ignore the first value
	// First value is type of value
	deviceStr := string(device[1:])
	osVersionStr := string(osVersion[1:])
	modelStr := string(model[1:])
	issueKey := issueMap[issue]

	log.Debugf("Report an issue index %v desc %v level %v email %v, device %v model %v version %v ", issueKey, description, level, email, deviceStr, modelStr, osVersionStr)
	reportIssueErr := SendIssueReport(session, issueKey, description, level, email, deviceStr, modelStr, osVersionStr)
	if reportIssueErr != nil {
		return reportIssueErr
	}
	return nil
}
