package internalsdk

import (
	"fmt"
	"math/big"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/1Password/srp"
	"github.com/getlantern/android-lantern/internalsdk/apimodels"
	"github.com/getlantern/android-lantern/internalsdk/protos"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/logging"
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

// Expose payment providers
const (
	paymentProviderStripe       = "stripe"
	paymentProviderFreekassa    = "freekassa"
	paymentProviderGooglePlay   = "googleplay"
	paymentProviderApplePay     = "applepay"
	paymentProviderBTCPay       = "btcpay"
	paymentProviderResellerCode = "reseller-code"
)

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
	pathCASAdsEnabled          = "casAsEnabled"
	pathStoreVersion           = "storeVersion"
	pathSelectedTab            = "/selectedTab"
	pathServerInfo             = "/server_info"
	pathHasAllNetworkPermssion = "/hasAllNetworkPermssion"
	pathShouldShowCasAds       = "shouldShowCASAds"
	pathShouldShowGoogleAds    = "shouldShowGoogleAds"
	currentTermsVersion        = 1
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
	pathCASAdsEnabled          = "casAsEnabled"
	pathStoreVersion           = "storeVersion"
	pathSelectedTab            = "/selectedTab"
	pathServerInfo             = "/server_info"
	pathUserSalt               = "user_salt"
	pathDeviceID             = "deviceid"
	pathDevice               = "device"
	pathDevices              = "devices"
	pathModel                = "model"
	pathOSVersion            = "os_version"
	pathPaymentTestMode      = "paymentTestMode"
	pathUserID               = "userid"
	pathToken                = "token"
	pathProUser              = "prouser"
	pathSDKVersion           = "sdkVersion"
	pathUserLevel            = "userLevel"
	pathChatEnabled          = "chatEnabled"
	pathDevelopmentMode      = "developmentMode"
	pathGeoCountryCode       = "geo_country_code"
	pathServerCountry        = "server_country"
	pathServerCountryCode    = "server_country_code"
	pathServerCity           = "server_city"
	pathHasSucceedingProxy   = "hasSucceedingProxy"
	pathLatestBandwith       = "latest_bandwidth"
	pathTimezoneID           = "timezone_id"
	pathReferralCode         = "referral"
	pathForceCountry         = "forceCountry"
	pathDNSDetector          = "dns_detector"
	pathProvider             = "provider"
	pathEmailAddress         = "emailAddress"
	pathCurrencyCode         = "currency_Code"
	pathReplicaAddr          = "replicaAddr"
	pathSplitTunneling       = "splitTunneling"
	pathLang                 = "lang"
	pathAcceptedTermsVersion = "accepted_terms_version"
	pathAdsEnabled           = "adsEnabled"
	pathCASAdsEnabled        = "casAsEnabled"
	pathStoreVersion         = "storeVersion"
	pathSelectedTab          = "/selectedTab"
	pathServerInfo           = "/server_info"
	pathPlans                = "/plans/"
	pathResellerCode         = "resellercode"
	pathExpirydate           = "expirydate"
	pathExpirystr            = "expirydatestr"
	pathUserSalt             = "user_salt"
	pathIsAccountVerified    = "isAccountVerified"
	pathIsUserLoggedIn       = "IsUserLoggedIn"

	currentTermsVersion = 1
	group               = srp.RFC5054Group3072
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
	base.db.RegisterType(1000, &protos.ServerInfo{})
	base.db.RegisterType(2000, &protos.Devices{})
	base.db.RegisterType(5000, &protos.Device{})
	base.db.RegisterType(3000, &protos.Plan{})
	base.db.RegisterType(4000, &protos.Plans{})
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
		//Todo find way to call PLans api everytime user chnage lang
		//So plans will apper in there local lang
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
	case "redeemResellerCode":
		email := arguments.Get("email").String()
		resellerCode := arguments.Get("resellerCode").String()
		err := redeemResellerCode(m, email, resellerCode)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "signup":
		email := arguments.Get("email").String()
		password := arguments.Get("password").String()
		err := signup(m, email, password)
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
	case "signupEmailResendCode":
		email := arguments.Get("email").String()
		err := signupEmailResend(m, email)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "signupEmailConfirmation":
		email := arguments.Get("email").String()
		code := arguments.Get("code").String()
		err := signupEmailConfirmation(m, email, code)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "login":
		email := arguments.Get("email").String()
		password := arguments.Get("password").String()
		err := login(m, email, password)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "submitApplePayPayment":
		plandId := arguments.Get("planID").String()
		purchaseId := arguments.Get("purchaseId").String()
		email := arguments.Get("email").String()
		err := submitApplePayPayment(m, email, plandId, purchaseId)
		if err != nil {
			return nil, err
		}
		return true, nil

		//Recovery
	case "startRecoveryByEmail":
		email := arguments.Get("email").String()
		err := startRecoveryByEmail(m, email)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "completeRecoveryByEmail":
		email := arguments.Get("email").String()
		code := arguments.Get("code").String()
		password := arguments.Get("password").String()
		err := completeRecoveryByEmail(m, email, code, password)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "changeEmail":
		email := arguments.Get("email").String()
		newEmail := arguments.Get("newEmail").String()
		password := arguments.Get("password").String()
		err := changeEmail(*m, email, newEmail, password)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "signOut":
		err := signOut(*m)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "deleteAccount":
		password := arguments.Get("password").String()
		err := deleteAccount(*m, password)
		if err != nil {
			return nil, err
		}
		return true, nil

	default:
		return m.methodNotImplemented(method)
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
	// Check if user is already registered or not
	userId, err := m.GetUserID()
	if err != nil {
		return err
	}
	log.Debugf("UserId is %v", userId)
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


	token, err := m.GetToken()
	if err != nil {
		return err
	}
	countryCode, err := m.GetCountryCode()
	if err != nil {
		return err
	}
	//Get all the Plans
	userIdStr := fmt.Sprintf("%d", userId)
	if userId == 0 {
		tempUserId, err := m.GetUserID()
		if err != nil {
			return err
		}
		userIdStr = fmt.Sprintf("%d", tempUserId)
	}

	err = getPlansV3(m.baseModel, opts.DeviceID, userIdStr, lang, token, countryCode)
	if err != nil {
		log.Debugf("Plans V3 error: %v", err)
		return err
	}
	

	isAccountVerified, err := pathdb.Get[bool](m.db, pathIsAccountVerified)
	if err != nil {
		log.Debugf("error while getting account stautus: %v", err)
	}
	// Call API only when status is not verified
	if !isAccountVerified {
		verified, err := apimodels.IsEmailVerified(userIdStr, token)
		if err != nil {
			log.Debugf("Plans V3 error: %v", err)
			return err
		}
		log.Debugf("User account is verified %v", verified)

		pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put[bool](tx, pathIsAccountVerified, verified, "")
		})
	}
	return checkAdsEnabled(m)
}

func getPlansV3(m *baseModel, deviceId string, userId string, lang string, token string, countyCode string) error {
	//
	log.Debugf("Request data deviceID %v userId %v lang %v token %v countyCode %v", deviceId, userId, lang, token, countyCode)
	plans, err := apimodels.PlansV3(deviceId, userId, lang, token, countyCode)
	if err != nil {
		log.Debugf("Plans V3 error: %v", err)
		return err
	}
	log.Debugf("Plans V3 response: %+v", plans)

	/// Process Plans and providers
	err = storePlanDetail(m, *plans)
	if err != nil {
		return err
	}
	return nil
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
func setExpiration(m *baseModel, expiration int64) error {
	if expiration == 0 {
		return nil
	}

	expiry := time.Unix(0, expiration*int64(time.Second))
	dateFormat := "01/02/2006"
	dateStr := expiry.Format(dateFormat)

	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		err := pathdb.Put[string](tx, pathExpirystr, dateStr, "")
		if err != nil {
			return err
		}
		return pathdb.Put[int64](tx, pathExpirydate, expiration, "")
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
	log.Debugf("Device list %v", devices)
	var protoDevices []*protos.Device
	for _, device := range devices {
		protoDevice := &protos.Device{
			Id:      device.ID,
			Name:    device.Name,
			Created: device.Created,
		}
		protoDevices = append(protoDevices, protoDevice)
	}

	userDevice := &protos.Devices{Devices: protoDevices}
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put(tx, pathDevices, userDevice, "")
		return nil
	})
	log.Debugf("Device stored successfully")
	return nil
}

func storePlanDetail(m *baseModel, plan apimodels.PlansResponse) error {
	log.Debugf("Storing Plan details ")
	err := setPlans(m, plan.Plans)
	if err != nil {
		return err
	}
	log.Debugf("Plan details stored successful")
	return nil
}

func setPlans(m *baseModel, plans []apimodels.Plan) error {

	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		//Get local from user
		lang, err := pathdb.Get[string](tx, pathLang)
		if err != nil {
			return err
		}

		for _, plans := range plans {
			// Update priceing for each plan
			err := updatePrice(&plans, lang)
			if err != nil {
				log.Debugf("Error while updateing price")
				return err
			}
			log.Debugf("Plans Values %+v", plans)
			pathPlanId := pathPlans + strings.Split(plans.ID, "-")[0]
			protoPlan := &protos.Plan{
				Id:                     plans.ID,
				Description:            plans.Description,
				BestValue:              plans.BestValue,
				UsdPrice:               plans.UsdPrice,
				TotalCostBilledOneTime: plans.TotalCostBilledOneTime,
				Price:                  plans.Price,
				OneMonthCost:           plans.OneMonthCost,
				TotalCost:              plans.TotalCost,
				FormattedBonus:         plans.FormattedBonus,
				RenewalText:            "",
			}
			err = pathdb.Put(tx, pathPlanId, protoPlan, "")
			if err != nil {
				log.Debugf("Error while addding price")
				return err
			}
		}
		return nil
	})
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

func (m *SessionModel) SetCASShowInterstitialAdsEnabled(casEnable bool) {
	log.Debugf("SetCASShowInterstitialAdsEnabled %v", casEnable)
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathCASAdsEnabled, casEnable, "")
	}))
}

func (m *SessionModel) SerializedInternalHeaders() (string, error) {
	// Return static for now
	// Todo implement this method
	return "", nil
}

func saveUserSalt(m *baseModel, salt []byte) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put[[]byte](tx, pathUserSalt, salt, "")
	})
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

func setUserIdAndToken(m *baseModel, userId int64, token string) error {
	log.Debugf("Setting user id %v token %v", userId, token)
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		if err := pathdb.Put[int64](tx, pathUserID, userId, ""); err != nil {
			log.Errorf("Error while setting user id %v", err)
			return err
		}
		userid, err := pathdb.Get[int64](tx, pathUserID)
		if err != nil {
			return err
		}
		log.Debugf("User id %v", userid)
		return pathdb.Put(tx, pathToken, token, "")
	})
}
func setResellerCode(m *baseModel, resellerCode string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathResellerCode, resellerCode, "")
	})
}

func getUserSalt(m *baseModel, email string) ([]byte, error) {
	userSalt, err := pathdb.Get[[]byte](m.db, pathUserSalt)
	if err != nil {
		return nil, err
	}
	if len(userSalt) == 16 {
		log.Debugf("salt return from cache %v", userSalt)
		return userSalt, nil
	}
	salt, err := apimodels.GetSalt(email)
	if err != nil {
		return nil, err
	}
	log.Debugf("Salt Response-> %v", salt.Salt)
	return salt.Salt, nil
}

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
	err = setUserIdAndToken(m, int64(userResponse.UserID), userResponse.Token)
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
	if userDetail.Email != "" {
		setEmail(m, userDetail.Email)
	}
	//Save user refferal code
	if userDetail.Referral != "" {
		err := setReferalCode(m, userDetail.Referral)
		if err != nil {
			return err
		}
	}
	if userDetail.UserLevel == "pro" {
		setProUser(m, true)
	} else {
		setProUser(m, false)
	}
	err := setUserLevel(m, userDetail.UserLevel)
	if err != nil {
		return err
	}

	err = setExpiration(m, userDetail.Expiration)
	if err != nil {
		return err
	}

	//Store all device
	err = setDevices(m, userDetail.Devices)
	if err != nil {
		return err
	}
	log.Debugf("User caching successful: %+v", userDetail)
	return setUserIdAndToken(m, int64(userDetail.UserID), userDetail.Token)
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
	if !hasAllPermisson {
		log.Debugf("User has not given all permission")
		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.PutAll(tx, map[string]interface{}{
				pathShouldShowGoogleAds: false,
				pathShouldShowCasAds:    false,
			})
		})
	}
	log.Debugf("User has given all permission")
	isPro, err := session.IsProUser()
	if err != nil {
		return err
	}
	log.Debugf("Is user pro %v", isPro)
	if isPro {
		err := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			err = pathdb.Put(tx, pathShouldShowCasAds, false, "")
			if err != nil {
				return err
			}
			return pathdb.Put(tx, pathShouldShowCasAds, false, "")
		})
		if err != nil {
			return err
		}
		return nil
	}
	isGoogleAdsEnable, err := pathdb.Get[bool](session.db, pathAdsEnabled)
	if err != nil {
		log.Debugf("Error while getting google ads value %v", err)
		return err
	}

	isCasAdsEnable, err := pathdb.Get[bool](session.db, pathCASAdsEnabled)
	if err != nil {
		log.Debugf("Error while getting cas ads value %v", err)
		return err
	}

	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathAdsEnabled:    isGoogleAdsEnable,
			pathCASAdsEnabled: isCasAdsEnable,
		})
	})
func redeemResellerCode(m *SessionModel, email string, resellerCode string) error {
	err := setEmail(m.baseModel, email)
	if err != nil {
		log.Errorf("Error while setting email %v", err)
		return err
	}
	setResellerCode(m.baseModel, resellerCode)
	if err != nil {
		log.Errorf("Error while setting resellerCode %v", err)
		return err
	}

	err, purchaseData := createPurchaseData(m, email, paymentProviderResellerCode, resellerCode, "", "")
	if err != nil {
		log.Errorf("Error while creating  purchase data %v", err)
		return err
	}

	deviecId, err := m.GetDeviceID()
	if err != nil {
		return err
	}
	userId, err := m.GetUserID()
	if err != nil {
		return err
	}
	userIdStr := fmt.Sprintf("%d", userId)

	token, err := m.GetToken()
	if err != nil {
		return err
	}
	purchase, err := apimodels.PurchaseRequest(purchaseData, deviecId, userIdStr, token)
	if err != nil {
		return err
	}
	log.Debugf("Purchase Request response %v", purchase)

	// Set user to pro
	return setProUser(m.baseModel, true)
}

func submitApplePayPayment(m *SessionModel, email string, planId string, purchaseToken string) error {
	log.Debugf("Submit Apple Pay Payment planId %v purchaseToken %v email %v", planId, purchaseToken, email)
	err, purchaseData := createPurchaseData(m, email, paymentProviderApplePay, "", purchaseToken, planId)
	if err != nil {
		log.Errorf("Error while creating  purchase data %v", err)
		return err
	}
	deviecId, err := m.GetDeviceID()
	if err != nil {
		return err
	}
	userId, err := m.GetUserID()
	if err != nil {
		return err
	}
	userIdStr := fmt.Sprintf("%d", userId)

	token, err := m.GetToken()
	if err != nil {
		return err
	}
	purchase, err := apimodels.PurchaseRequest(purchaseData, deviecId, userIdStr, token)
	if err != nil {
		return err
	}
	log.Debugf("Purchase response %+v", purchase)

	if purchase.Status != "ok" {
		return errors.New("Purchase Request failed")
	}
	// Set user to pro
	return setProUser(m.baseModel, true)
}

// Authenticates the user with the given email and password.
//  Note-: On Sign up Client needed to generate 16 byte slat
//  Then use that salt, password and email generate encryptedKey once you created encryptedKey pass it to srp.NewSRPClient
//  Then use srpClient.Verifier() to generate verifierKey

func signup(session *SessionModel, email string, password string) error {
	err := setEmail(session.baseModel, email)
	if err != nil {
		return err
	}
	slat, err := GenerateSalt()
	if err != nil {
		return err
	}
	log.Debugf("Slat %v and length %v", slat, len(slat))

	encryptedKey := srp.KDFRFC5054(slat, email, password)
	srpClient := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return err
	}
	signUpRequestBody := &protos.SignupRequest{
		Email:    email,
		Salt:     slat,
		Verifier: verifierKey.Bytes(),
	}

	userId, err := session.GetUserID()
	if err != nil {
		return err
	}
	token, err := session.GetToken()
	if err != nil {
		return err
	}
	signupResponse, err := apimodels.Signup(signUpRequestBody, ToString(userId), token)
	if err != nil {
		return err
	}
	log.Debugf("sign up response %v", signupResponse)
	//Request successfull then save salt
	err = pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathUserSalt:          slat,
			pathIsAccountVerified: false,
			pathEmailAddress:      email,
		})
	})
	if err != nil {
		return err
	}
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsUserLoggedIn, true, "")
	})
}

func signupEmailResend(session *SessionModel, email string) error {
	salt, err := getUserSalt(session.baseModel, email)
	if err != nil {
		return err
	}

	signUpEmailResendRequestBody := &protos.SignupEmailResendRequest{
		Email: email,
		Salt:  salt,
	}

	signupEmailResendResponse, err := apimodels.SignupEmailResendCode(signUpEmailResendRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Signup email resend %v", signupEmailResendResponse)
	return nil
}

func signupEmailConfirmation(session *SessionModel, email string, code string) error {
	signUpEmailResendRequestBody := &protos.ConfirmSignupRequest{
		Email: email,
		Code:  code,
	}

	log.Debugf("Signup verfication request body %v", signUpEmailResendRequestBody)
	signupEmailResendResponse, err := apimodels.SignupEmailConfirmation(signUpEmailResendRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Signup verfication response %v", signupEmailResendResponse)
	//Chaneg account status
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsAccountVerified, true, "")
	})
}

// Todo find way to optimize this method
func login(session *SessionModel, email string, password string) error {
	start := time.Now()
	// Get the salt
	salt, err := getUserSalt(session.baseModel, email)
	if err != nil {
		return err
	}

	// Prepare login request body
	encryptedKey := srp.KDFRFC5054(salt, email, password)
	client := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)

	//Send this key to client
	A := client.EphemeralPublic()

	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: email,
		A:     A.Bytes(),
	}
	log.Debugf("A Bytes %v", A.Bytes())
	srpB, err := apimodels.LoginPrepare(prepareRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Login prepare response %v", srpB)

	// // Once the client receives B from the server Client should check error status here as defense against
	// // a malicious B sent from server
	B := big.NewInt(0).SetBytes(srpB.B)

	if err = client.SetOthersPublic(B); err != nil {
		log.Errorf("Error while setting srpB %v", err)
		return err
	}

	// client can now make the session key
	clientKey, err := client.Key()
	if err != nil || clientKey == nil {
		return log.Errorf("user_not_found error while generating Client key %v", err)
	}

	// // Step 3

	// // check if the server proof is valid
	if !client.GoodServerProof(salt, email, srpB.Proof) {
		return log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return log.Errorf("user_not_found error while generating client proof %v", err)
	}

	loginRequestBody := &protos.LoginRequest{
		Email: email,
		Proof: clientProof,
	}
	log.Debugf("Login request body %v", loginRequestBody)

	login, err := apimodels.Login(loginRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Login response %+v", login)

	err = pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsAccountVerified, login.EmailConfirmed, "")
	})
	if err != nil {
		log.Errorf("Error while saving user status %v", err)
	}

	err = pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsUserLoggedIn, true, "")
	})
	if err != nil {
		log.Errorf("Error while saving user status %v", err)
	}
	err = saveUserSalt(session.baseModel, salt)
	if err != nil {
		log.Errorf("Error while saving user salt %v", err)
	}
	end := time.Now()
	log.Debugf("Login took %v", end.Sub(start))
	//Store all the user details
	userData := ConvertToUserDetailsResponse(login)
	err = cacheUserDetail(session.baseModel, &userData)
	if err != nil {
		log.Errorf("Error while caching user details %v", err)
		return err
	}
	return nil
}

func startRecoveryByEmail(session *SessionModel, email string) error {
	//Create body
	prepareRequestBody := &protos.StartRecoveryByEmailRequest{
		Email: email,
	}

	recovery, err := apimodels.StartRecoveryByEmail(prepareRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("StartRecoveryByEmail response %v", recovery)
	return nil
}

func completeRecoveryByEmail(session *SessionModel, email string, code string, password string) error {
	//Create body
	newsalt, err := GenerateSalt()
	if err != nil {
		return err
	}
	log.Debugf("Slat %v and length %v", newsalt, len(newsalt))

	encryptedKey := srp.KDFRFC5054(newsalt, email, password)
	srpClient := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return err
	}

	prepareRequestBody := &protos.CompleteRecoveryByEmailRequest{
		Email:       email,
		Code:        code,
		NewSalt:     newsalt,
		NewVerifier: verifierKey.Bytes(),
	}

	recovery, err := apimodels.CompleteRecoveryByEmail(prepareRequestBody)
	if err != nil {
		return err
	}
	//User has been recovered successfully
	//Save new salt
	saveUserSalt(session.baseModel, newsalt)
	log.Debugf("CompleteRecoveryByEmail response %v", recovery)
	return nil
}

func changeEmail(session SessionModel, email string, newEmail string, password string) error {
	salt, err := getUserSalt(session.baseModel, email)
	if err != nil {
		return err
	}

	// Prepare login request body
	encryptedKey := srp.KDFRFC5054(salt, email, password)
	client := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)

	//Send this key to client
	A := client.EphemeralPublic()

	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: email,
		A:     A.Bytes(),
	}
	log.Debugf("A Bytes %v", A.Bytes())
	srpB, err := apimodels.LoginPrepare(prepareRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Login prepare response %v", srpB)

	// // Once the client receives B from the server Client should check error status here as defense against
	// // a malicious B sent from server
	B := big.NewInt(0).SetBytes(srpB.B)

	if err = client.SetOthersPublic(B); err != nil {
		log.Errorf("Error while setting srpB %v", err)
		return err
	}

	// client can now make the session key
	clientKey, err := client.Key()
	if err != nil || clientKey == nil {
		return log.Errorf("user_not_found error while generating Client key %v", err)
	}

	// // check if the server proof is valid
	if !client.GoodServerProof(salt, email, srpB.Proof) {
		return log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return log.Errorf("user_not_found error while generating client proof %v", err)
	}

	changeEmailRequestBody := &protos.ChangeEmailRequest{
		OldEmail: email,
		NewEmail: newEmail,
		Proof:    clientProof,
	}

	isEmailChanged, err := apimodels.ChangeEmail(changeEmailRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Change Email response %v", isEmailChanged)
	return setEmail(session.baseModel, newEmail)
}

// Clear slat and change accoutn state
func signOut(session SessionModel) error {
	err := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathUserSalt:     nil,
			pathEmailAddress: "",
		})
	})
	if err != nil {
		return err
	}
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsUserLoggedIn, false, "")
	})
}

func deleteAccount(session SessionModel, password string) error {
	email, err := session.Email()
	if err != nil {
		return err
	}
	if email == "" {
		return errors.New("Email not found")
	}

	salt, err := getUserSalt(session.baseModel, email)
	if err != nil {
		return err
	}

	// Prepare login request body
	encryptedKey := srp.KDFRFC5054(salt, email, password)
	client := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)

	//Send this key to client
	A := client.EphemeralPublic()

	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: email,
		A:     A.Bytes(),
	}
	log.Debugf("A Bytes %v", A.Bytes())
	srpB, err := apimodels.LoginPrepare(prepareRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Login prepare response %v", srpB)

	B := big.NewInt(0).SetBytes(srpB.B)

	if err = client.SetOthersPublic(B); err != nil {
		log.Errorf("Error while setting srpB %v", err)
		return err
	}

	clientKey, err := client.Key()
	if err != nil || clientKey == nil {
		return log.Errorf("user_not_found error while generating Client key %v", err)
	}

	// // check if the server proof is valid
	if !client.GoodServerProof(salt, email, srpB.Proof) {
		return log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return log.Errorf("user_not_found error while generating client proof %v", err)
	}

	changeEmailRequestBody := &protos.DeleteUserRequest{
		Email:     email,
		Proof:     clientProof,
		Permanent: true,
	}

	isAccountDeleted, err := apimodels.DeleteAccount(changeEmailRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Account Delted response %v", isAccountDeleted)

	// Clear Local DB
	err = pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathIsAccountVerified: false,
			pathEmailAddress:      "",
			pathUserID:            0,
			pathProUser:           false,
		})
	})
	if err != nil {
		return err
	}
	err = signOut(session)
	if err != nil {
		return err
	}
	// Create New user
	local, err := session.Locale()
	if err != nil {
		return err
	}
	return userCreate(session.baseModel, local)
}
