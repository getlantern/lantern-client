package internalsdk

import (
	"fmt"
	"strconv"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/apimodels"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	*baseModel
}

// List of we are using for Session Model
const (
	pathDeviceID               = "deviceid"
	pathDevice                 = "device"
	pathDevices                = "devices"
	pathModel                  = "model"
	pathOSVersion              = "os_version"
	pathPaymentTestMode        = "paymentTestMode"
	pathUserID                 = "userid"
	pathToken                  = "token"
	pathProUser                = "prouser"
	pathSDKVersion             = "sdkVersion"
	pathUserLevel              = "userLevel"
	pathChatEnabled            = "chatEnabled"
	pathDevelopmentMode        = "developmentMode"
	pathGeoCountryCode         = "geo_country_code"
	pathIPAddress              = "ip_address"
	pathServerCountry          = "server_country"
	pathServerCountryCode      = "server_country_code"
	pathServerCity             = "server_city"
	pathHasSucceedingProxy     = "hasSucceedingProxy"
	pathLatestBandwith         = "latest_bandwidth"
	pathTimezoneID             = "timezone_id"
	pathReferralCode           = "referral"
	pathForceCountry           = "forceCountry"
	pathDNSDetector            = "dns_detector"
	pathProvider               = "provider"
	pathEmailAddress           = "emailAddress"
	pathCurrencyCode           = "currency_Code"
	pathReplicaAddr            = "replicaAddr"
	pathSplitTunneling         = "splitTunneling"
	pathLang                   = "lang"
	pathAcceptedTermsVersion   = "accepted_terms_version"
	pathAdsEnabled             = "adsEnabled"
	pathStoreVersion           = "storeVersion"
	pathSelectedTab            = "/selectedTab"
	pathServerInfo             = "/server_info"
	pathHasAllNetworkPermssion = "/hasAllNetworkPermssion"
	pathShouldShowGoogleAds    = "shouldShowGoogleAds"
	currentTermsVersion        = 1
)

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
	Platform        string
}

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(mdb minisql.DB, opts *SessionModelOpts) (*SessionModel, error) {
	base, err := newModel("session", mdb)
	if err != nil {
		return nil, err
	}
	if opts.Platform == "ios" {
		base.db.RegisterType(1000, &protos.ServerInfo{})
		base.db.RegisterType(2000, &protos.Devices{})
	}
	m := &SessionModel{baseModel: base}
	m.baseModel.doInvokeMethod = m.doInvokeMethod
	return m, m.initSessionModel(opts)
}

func (m *SessionModel) doInvokeMethod(method string, arguments Arguments) (interface{}, error) {
	switch method {
	case "getBandwidth":
		return getBandwidthLimit(m.baseModel)
	case "setForceCountry":
		err := setForceCountry(m.baseModel, arguments.Scalar().String())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setDNSServer":
		err := setDNSServer(m.baseModel, arguments.Scalar().String())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setProvider":
		// Todo Implement setProvider server
		err := setProvider(m.baseModel, "Test")
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setEmail":
		// Todo Implement setEmail server
		err := setEmail(m.baseModel, "Test")
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setProUser":
		// Todo Implement setCurrency server
		err := setCurrency(m.baseModel, "Test")
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setLanguage":
		err := setLanguage(m.baseModel, arguments.Get("lang").String())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "acceptTerms":
		err := acceptTerms(m.baseModel)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setStoreVersion":
		err := setStoreVersion(m.baseModel, arguments.Scalar().Bool())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setSelectedTab":
		err := setSelectedTab(m.baseModel, arguments.Get("tab").String())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "reportIssue":
		email := arguments.Get("email").String()
		issue := arguments.Get("issue").String()
		description := arguments.Get("description").String()
		err := reportIssue(m, email, issue, description)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "createUser":
		err := userCreate(m.baseModel, arguments.Scalar().String())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "hasAllNetworkPermssion":
		err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put[bool](tx, pathHasAllNetworkPermssion, true, "")
		})
		if err != nil {
			return nil, err
		}
		checkAdsEnabled(m)
		return true, nil
	default:
		return m.methodNotImplemented(method)
	}
}

// InvokeMethod handles method invocations on the SessionModel.
func (m *SessionModel) initSessionModel(opts *SessionModelOpts) error {
	// Check if email if empty
	email, err := pathdb.Get[string](m.db, pathEmailAddress)
	if err != nil {
		log.Errorf("Init Session email error value %v", err)
		return err
	}
	if email == "" {
		log.Debugf("Init Session setting email value to an empty string")
		setEmail(m.baseModel, "")
	}
	tx, err := m.db.Begin()
	if err != nil {
		return err
	}
	err = pathdb.PutAll(tx, map[string]interface{}{
		pathDevelopmentMode: opts.DevelopmentMode,
		pathProUser:         opts.ProUser,
		pathDeviceID:        opts.DeviceID,
		pathStoreVersion:    opts.PlayVersion,
		pathTimezoneID:      opts.TimeZone,
		pathDevice:          opts.Device,
		pathModel:           opts.Model,
		pathOSVersion:       opts.OsVersion,
		pathSDKVersion:      SDKVersion(),
	})
	if err != nil {
		return err
	}
	err = pathdb.Put(tx, pathPaymentTestMode, opts.PaymentTestMode, "")
	if err != nil {
		return err
	}
	// Check if lang is already added or not
	// If yes then do not add it
	// This is used for only when user is new
	lang, err := pathdb.Get[string](tx, pathLang)
	if err != nil {
		return err
	}
	log.Debugf("Selected language value is %v", lang)
	if lang == "" {
		err = pathdb.Put(tx, pathLang, opts.Lang, "")
		if err != nil {
			return err
		}
	}

	err = tx.Commit()
	if err != nil {
		return err
	}
	// // Check if user is already registered or not
	// userId, err := m.GetUserID()
	// if err != nil {
	// 	return err
	// }
	// log.Debugf("UserId is %v", userId)
	// if userId == 0 {
	// 	local, err := m.Locale()
	// 	if err != nil {
	// 		return err
	// 	}
	// 	// Create user
	// 	err = userCreate(m.baseModel, local)
	// 	if err != nil {
	// 		return err
	// 	}
	// }

	// // Get all user details
	// err = userDetail(m)
	// if err != nil {
	// 	return err
	// }
	return checkAdsEnabled(m)
}

func (m *SessionModel) GetAppName() string {
	return "Lantern-IOS"
}

func (m *SessionModel) GetDeviceID() (string, error) {
	return pathdb.Get[string](m.baseModel.db, pathDeviceID)
}

// Todo There is some issue with user id changeing it value
// When  Coverting from bytes to Float
func (m *SessionModel) GetUserID() (int64, error) {
	paymentTestMode, err := pathdb.Get[bool](m.baseModel.db, pathPaymentTestMode)
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
	}
	return pathdb.Get[int64](m.baseModel.db, pathUserID)
}

func (m *SessionModel) GetToken() (string, error) {
	paymentTestMode, err := pathdb.Get[bool](m.baseModel.db, pathPaymentTestMode)
	if err != nil {
		return "", err
	}

	if paymentTestMode {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		return "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOusUkc0fKpEZW6tc8uUvA", nil
	}
	return pathdb.Get[string](m.baseModel.db, pathToken)
}

func (m *SessionModel) SetCountry(country string) error {
	//Find better way to do it
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathGeoCountryCode, country, "")
	})
}

// SetIP stores the IP address of the client after a successful geolookup
func (m *SessionModel) SetIP(ipAddress string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathIPAddress, ipAddress, "")
	})
}

func (m *SessionModel) UpdateAdSettings(adsetting AdSettings) error {
	// Not using these ads anymore
	return nil
}

// Note - the names of these parameters have to match what's defined on the `Session` interface
func (m *SessionModel) UpdateStats(serverCity string, serverCountry string, serverCountryCode string, p3 int, p4 int, hasSucceedingProxy bool) error {

	if serverCity != "" && serverCountry != "" && serverCountryCode != "" {

		serverInfo := &protos.ServerInfo{
			City:        serverCity,
			Country:     serverCountry,
			CountryCode: serverCountryCode,
		}
		log.Debugf("UpdateStats city %v country %v hasSucceedingProxy %v serverInfo %v", serverCity, serverCountry, hasSucceedingProxy, serverInfo)
		return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			err := pathdb.Put[bool](tx, pathHasSucceedingProxy, hasSucceedingProxy, "")
			if err != nil {
				log.Debugf("Error while adding hasSucceedingProxy %v", err)
				return err
			}
			return pathdb.PutAll(tx, map[string]interface{}{
				pathServerCountry:     serverCountry,
				pathServerCity:        serverCity,
				pathServerCountryCode: serverCountryCode,
				pathServerInfo:        serverInfo,
			})
		})
	}
	return nil
}

func (m *SessionModel) SetStaging(staging bool) error {
	// Not using staging anymore
	return nil
}

// Keep name as p1,p2,p3.....
// Name become part of Objective c so this is important
func (m *SessionModel) BandwidthUpdate(p1 int, p2 int, p3 int, p4 int) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathLatestBandwith, p1, "")
	})
}

func setUserLevel(m *baseModel, userLevel string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathUserLevel, userLevel, "")
	})
}

func getUserLevel(m *baseModel) (string, error) {
	return pathdb.Get[string](m.db, pathUserLevel)
}

func getBandwidthLimit(m *baseModel) (int64, error) {
	return pathdb.Get[int64](m.db, pathLatestBandwith)
}

func (m *SessionModel) Locale() (string, error) {
	return pathdb.Get[string](m.baseModel.db, pathLang)
}

func setLanguage(m *baseModel, lang string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathLang, lang, "")
	})
}

func setDevices(m *baseModel, devices []apimodels.UserDevice) error {
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
		pathdb.Put(tx, pathDevices, protoDevices, "")
		return nil
	})
	return nil
}

func (m *SessionModel) GetTimeZone() (string, error) {
	return pathdb.Get[string](m.baseModel.db, pathTimezoneID)
}

// Todo change method name to referral code
func (m *SessionModel) Code() (string, error) {
	return pathdb.Get[string](m.baseModel.db, pathReferralCode)
}

func setReferalCode(m *baseModel, referralCode string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathReferralCode, referralCode, "")
	})
}

// Todo need to make chanegs for Force country setup
func (m *SessionModel) GetCountryCode() (string, error) {
	forceCountry, forceCountryErr := pathdb.Get[string](m.db, pathForceCountry)
	if forceCountryErr != nil {
		return "", forceCountryErr
	}
	if forceCountry != "" {
		return forceCountry, nil
	}

	return pathdb.Get[string](m.baseModel.db, pathGeoCountryCode)
}

func (m *SessionModel) GetForcedCountryCode() (string, error) {
	return pathdb.Get[string](m.db, pathForceCountry)
}

func setForceCountry(m *baseModel, forceCountry string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathForceCountry, forceCountry, "")
	})
}

func (m *SessionModel) GetDNSServer() (string, error) {
	return pathdb.Get[string](m.db, pathDNSDetector)
}

func setDNSServer(m *baseModel, dnsServer string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathDNSDetector, dnsServer, "")
	})
}

func (m *SessionModel) Provider() (string, error) {
	return pathdb.Get[string](m.db, pathProvider)
}

func setProvider(m *baseModel, provider string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathProvider, provider, "")
	})
}

func (m *SessionModel) IsStoreVersion() (bool, error) {
	return pathdb.Get[bool](m.db, pathStoreVersion)
}

func (m *SessionModel) Email() (string, error) {
	return pathdb.Get[string](m.db, pathEmailAddress)
}

func setEmail(m *baseModel, email string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathEmailAddress, email, "")
	})
}

func (m *SessionModel) Currency() (string, error) {
	return pathdb.Get[string](m.db, pathCurrencyCode)
}

func setCurrency(m *baseModel, currencyCode string) error {
	// Todo Implement this method
	return errors.New("Method not implemented yet")
}

func (m *SessionModel) DeviceOS() (string, error) {
	// return static for now
	return "IOS", nil
}

func (m *SessionModel) IsProUser() (bool, error) {
	return pathdb.Get[bool](m.db, pathProUser)
}

func setProUser(m *baseModel, isPro bool) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathProUser, isPro, "")
	})
}

func (m *SessionModel) SetReplicaAddr(replicaAddr string) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		//For now force replicate to disbale it
		return pathdb.Put(tx, pathReplicaAddr, "", "")
	}))
}

func (m *SessionModel) ForceReplica() bool {
	// return static for now
	return false
}

func (m *SessionModel) SetChatEnabled(chatEnable bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathChatEnabled, chatEnable, "")
	}))
}

func (m *SessionModel) SplitTunnelingEnabled() (bool, error) {
	// Return static for now
	return true, nil
}

func (m *SessionModel) SetShowInterstitialAdsEnabled(adsEnable bool) {
	log.Debugf("SetShowInterstitialAdsEnabled %v", adsEnable)
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathAdsEnabled, adsEnable, "")
	}))
}

func (m *SessionModel) SerializedInternalHeaders() (string, error) {
	// Return static for now
	// Todo implement this method
	return "", nil
}

func acceptTerms(m *baseModel) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathAcceptedTermsVersion, currentTermsVersion, "")
	})
}

func setStoreVersion(m *baseModel, isStoreVersion bool) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathStoreVersion, isStoreVersion, "")
	})
}

func setSelectedTab(m *baseModel, tap string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathSelectedTab, tap, "")
	})
}

func setUserIdAndToken(m *baseModel, userId int, token string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		if err := pathdb.Put(tx, pathUserID, userId, ""); err != nil {
			return err
		}
		return pathdb.Put(tx, pathToken, token, "")
	})
}

// Create user
// Todo-: Create Sprate http client to manag and reuse client
func userCreate(m *baseModel, local string) error {
	deviceID, err := pathdb.Get[string](m.db, pathDeviceID)
	if err != nil {
		return err
	}

	userResponse, err := apimodels.UserCreate(deviceID, local)
	if err != nil {
		log.Errorf("Error sending request: %v", err)
		return err
	}

	//Save user id and token
	err = setUserIdAndToken(m, int(userResponse.UserID), userResponse.Token)
	if err != nil {
		return err
	}
	log.Debugf("Created new Lantern user: %+v", userResponse)
	return nil
}

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
	userIdStr := fmt.Sprintf("%d", userId)
	userDetail, err := apimodels.FechUserDetail(deviecId, userIdStr, token)
	if err != nil {
		return nil
	}
	log.Debugf("User detail: %+v", userDetail)
	err = cacheUserDetail(session.baseModel, userDetail)
	if err != nil {
		return err
	}
	return nil
}

func cacheUserDetail(m *baseModel, userDetail *apimodels.UserDetailResponse) error {
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
	log.Debugf("User caching successful: %+v", userDetail)
	return setUserIdAndToken(m, int(userDetail.UserID), userDetail.Token)
}

func reportIssue(session *SessionModel, email string, issue string, description string) error {
	// Check if email is there is yes then store it
	if email != "" {
		err := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathEmailAddress, email, "")
		})
		if err != nil {
			return err
		}
	}

	level, err := getUserLevel(session.baseModel)
	if err != nil {
		return err
	}

	model, modelErr := pathdb.Get[string](session.db, pathModel)
	if modelErr != nil {
		return modelErr
	}

	osVersion, osVersionErr := pathdb.Get[string](session.db, pathOSVersion)
	if osVersionErr != nil {
		return osVersionErr
	}

	device, deviceErr := pathdb.Get[string](session.db, pathDevice)
	if deviceErr != nil {
		return deviceErr
	}

	issueKey := issueMap[issue]

	log.Debugf("Report an issue index %v desc %v level %v email %v, device %v model %v version %v ", issueKey, description, level, email, device, model, osVersion)
	return SendIssueReport(session, issueKey, description, level, email, device, model, osVersion)
}

func checkAdsEnabled(session *SessionModel) error {
	log.Debugf("Check ads enabled")
	hasAllPermisson, err := pathdb.Get[bool](session.db, pathHasAllNetworkPermssion)
	if err != nil {
		return err
	}
	// If the user doesn't have all permissions, disable Google ads:
	if !hasAllPermisson {
		log.Debugf("User has not given all permission")

		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathShouldShowGoogleAds, false, "")
		})
	}
	log.Debugf("User has given all permission")
	isPro, err := session.IsProUser()
	if err != nil {
		return err
	}
	if isPro {
		log.Debugf("Is user pro %v", isPro)
		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathShouldShowGoogleAds, false, "")
		})
	}
	// If the user has all permissions but is not a pro user, enable ads:
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathShouldShowGoogleAds, true, "")
	})

}
