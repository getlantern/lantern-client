package internalsdk

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"

	"github.com/getlantern/android-lantern/internalsdk/protos"
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
const DEVICES = "devices"
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
	PaymentTestMode bool
}

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(mdb minisql.DB, opts *SessionModelOpts) (*SessionModel, error) {
	base, err := newModel("session", mdb)
	if err != nil {
		return nil, err
	}
	base.db.RegisterType(1000, &protos.ServerInfo{})
	base.db.RegisterType(2000, &protos.Devices{})
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
		description := arguments.Get("description").String()
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
	err = pathdb.Put(tx, PAYMENT_TEST_MODE, opts.PaymentTestMode, "")
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
	log.Debugf("User is %v", userId)
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

	// Get all user details
	err = userDetail(m)
	if err != nil {
		return err
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
	tx, err := m.db.Begin()
	if err != nil {
		return 0, err
	}

	paymentTestMode, err := pathdb.Get[bool](tx, PAYMENT_TEST_MODE)
	if err != nil {
		return 0, err
	}

	if paymentTestMode {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		i64, err := strconv.ParseInt("9007199254740992", 10, 64)
		if err != nil {
			log.Debugf("Wrror while parsing userID %v", err)
			return 0, err
		}
		return i64, nil
	} else {

		userId, err := pathdb.Get[float64](tx, USER_ID)
		if err != nil {
			return 0, err
		}
		i64 := int64(userId)
		return i64, nil
	}
}
func (m *SessionModel) GetToken() (string, error) {
	tx, err := m.db.Begin()
	if err != nil {
		return "", err
	}
	paymentTestMode, err := pathdb.Get[bool](tx, PAYMENT_TEST_MODE)
	if err != nil {
		return "", err
	}

	if paymentTestMode {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		return "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA", nil
	} else {
		token, err := pathdb.Get[string](tx, TOKEN)
		if err != nil {
			return "", err
		}
		return token, nil
	}
}
func (m *SessionModel) SetCountry(country string) error {
	//Find better way to do it
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, GEO_COUNTRY_CODE, country, "")
	})
}

func (m *SessionModel) UpdateAdSettings(adsetting AdSettings) error {
	// Not using these ads anymore
	return nil
}

// Keep name as p1,p2,p3.....
// Name become part of Objective c so this is important
func (m *SessionModel) UpdateStats(p0 string, p1 string, p2 string, p3 int, p4 int, p5 bool) error {
	if p0 != "" && p1 != "" && p2 != "" {
		serverInfo := &protos.ServerInfo{
			City:        p0,
			Country:     p1,
			CountryCode: p2,
		}

		return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			if err := pathdb.Put(tx, SERVER_COUNTRY, p1, ""); err != nil {
				return err
			}
			if err := pathdb.Put(tx, SERVER_CITY, p0, ""); err != nil {
				return err
			}
			if err := pathdb.Put(tx, SERVER_COUNTRY_CODE, p2, ""); err != nil {
				return err
			}
			if err := pathdb.Put(tx, HAS_SUCCEEDING_PROXY, p5, ""); err != nil {
				return err
			}
			if err := pathdb.Put(tx, PATH_SERVER_INFO, serverInfo, ""); err != nil {
				return err
			}

			// Not using ads blocked any more
			return nil
		})
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
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, LATEST_BANDWIDTH, p1, "")
	})
}

func setUserLevel(m *baseModel, userLevel string) error {
	tx, err := m.db.Begin()
	if err != nil {
		return err
	}

	err = pathdb.Put[string](tx, PATH_USER_LEVEL, userLevel, "")
	if err != nil {
		return err
	}
	return nil
}

func getUserLevel(m *baseModel) (string, error) {
	userLevel, err := m.db.Get(PATH_USER_LEVEL)
	if err != nil {
		return "", err
	}
	return string(userLevel), nil
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
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, LANG, lang, "")
	})
}

func setDevices(m *baseModel, devices []UserDevice) error {
	var protoDevices []*protos.Device
	for _, device := range devices {
		protoDevice := &protos.Device{
			Id:      device.ID,
			Name:    device.Name,
			Created: device.Created,
		}
		protoDevices = append(protoDevices, protoDevice)
	}

	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put(tx, DEVICES, protoDevices, "")
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
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, REFERRAL_CODE, referralCode, "")
	})
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
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, FORCE_COUNTRY, forceCountry, "")
	})
}
func (m *SessionModel) GetDNSServer() (string, error) {
	dns, err := m.db.Get(DNS_DETECTOR)
	if err != nil {
		return "", err
	}
	return string(dns), nil
}

func setDNSServer(m *baseModel, dnsServer string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, DNS_DETECTOR, dnsServer, "")
	})
}

func (m *SessionModel) Provider() (string, error) {
	provider, err := m.db.Get(PROVIDER)
	if err != nil {
		return "", err
	}
	return string(provider), nil
}

func setProvider(m *baseModel, provider string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, PROVIDER, provider, "")
	})
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
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, EMAIL_ADDRESS, email, "")
	})
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
	tx, err := m.db.Begin()
	if err != nil {
		return false, err
	}
	paymentTestMode, err := pathdb.Get[bool](tx, PAYMENT_TEST_MODE)
	if err != nil {
		return false, err
	}
	if paymentTestMode {
		log.Debugf("Payment test mode is on setting user to pro")
		return true, nil
	}
	proUser, err := pathdb.Get[bool](tx, PRO_USER)
	if err != nil {
		return false, err
	}
	return proUser, nil
}

func setProUser(m *baseModel, isPro bool) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, PRO_USER, isPro, "")
	})
}

func (m *SessionModel) SetReplicaAddr(replicaAddr string) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		//For now force replicate to disbale it
		return pathdb.Put(tx, REPLICA_ADDR, "", "")
	}))
}

func (m *SessionModel) ForceReplica() bool {
	// return static for now
	return false
}

func (m *SessionModel) SetChatEnabled(chatEnable bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, CHAT_ENABLED, chatEnable, "")
	}))
}

func (m *SessionModel) SplitTunnelingEnabled() (bool, error) {
	// Return static for now
	return true, nil
}

func (m *SessionModel) SetShowInterstitialAdsEnabled(adsEnable bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, ADS_ENABLED, adsEnable, "")
	}))
}

func (m *SessionModel) SetCASShowInterstitialAdsEnabled(casEnable bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, CAS_ADS_ENABLED, casEnable, "")
	}))
}

func (m *SessionModel) SerializedInternalHeaders() (string, error) {
	// Return static for now
	// Todo implement this method
	return "", nil
}

func acceptTerms(m *baseModel) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, ACCEPTED_TERMS_VERSION, CURRENT_TERMS_VERSION, "")
	})
}

func setStoreVersion(m *baseModel, isStoreVersion bool) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, IS_PLAY_VERSION, isStoreVersion, "")
	})
}
func setSelectedTab(m *baseModel, tap string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, SET_SELECTED_TAB, tap, "")
	})
}

func setUserIdAndToken(m *baseModel, userId float64, token string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		if err := pathdb.Put(tx, USER_ID, userId, ""); err != nil {
			return err
		}
		return pathdb.Put(tx, TOKEN, token, "")
	})
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

	//Save user id and token
	setUserIdAndToken(m, userResponse.UserID, userResponse.Token)
	log.Debugf("Created new Lantern user: %+v", userResponse)
	return nil
}

// Create user
// Todo-: Create Sprate http client to manag and reuse client
func userDetail(session *SessionModel) error {
	deviecId, err := session.GetDeviceID()
	if err != nil {
		return err
	}
	userId, err := session.GetUserID()
	if err != nil {
		return err
	}
	token, err := session.GetToken()
	if err != nil {
		return err
	}

	// Create a new request
	req, err := http.NewRequest("GET", "https://api.getiantem.org/user-data", nil)
	if err != nil {
		log.Errorf("Error creating user details request: %v", err)
		return err
	}

	userIdStr := fmt.Sprintf("%d", userId)
	// Add headers
	req.Header.Set("X-Lantern-Device-Id", deviecId)
	req.Header.Set("X-Lantern-User-Id", userIdStr)
	req.Header.Set("X-Lantern-Pro-Token", token)
	log.Debugf("Headers set")
	// Initialize a new http client
	client := &http.Client{}
	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("Error sending user details request: %v", err)

		return err
	}
	defer resp.Body.Close()

	// Read the response body
	var userDetail UserDetailResponse
	// Read and decode the response body
	if err := json.NewDecoder(resp.Body).Decode(&userDetail); err != nil {
		log.Errorf("Error decoding response body: %v", err)
		return err
	}
	err = cacheUserDetail(session.baseModel, userDetail)
	if err != nil {
		return err
	}
	return nil
}

func cacheUserDetail(m *baseModel, userDetail UserDetailResponse) error {
	log.Debugf("User detail: %+v", userDetail)

	//Save user refferal code
	if userDetail.Referral != "" {
		err := setReferalCode(m, userDetail.Referral)
		if err != nil {
			return err
		}
	}
	if userDetail.UserStatus != "" && userDetail.UserStatus == "active" && userDetail.UserLevel == "pro" {
		setProUser(m, true)
	} else {
		setProUser(m, false)
	}
	err := setUserLevel(m, userDetail.UserLevel)
	if err != nil {
		return err
	}

	//Store all device
	err = setDevices(m, userDetail.Devices)
	if err != nil {
		return err
	}
	log.Debugf("Device has stored %v", userDetail.Devices)
	return nil
}

func reportIssue(session *SessionModel, email string, issue string, description string) error {
	// Check if email is there is yes then store it
	if email != "" {
		err := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, EMAIL_ADDRESS, email, "")
		})
		if err != nil {
			return err
		}
	}

	level, err := getUserLevel(session.baseModel)
	if err != nil {
		return err
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
