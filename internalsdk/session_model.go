package internalsdk

import (
	"context"
	"fmt"
	"math/big"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/1Password/srp"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/proxied"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/lantern-client/internalsdk/webclient"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	*baseModel
	authClient auth.AuthClient
	proClient  pro.ProClient
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
	pathStoreVersion           = "storeVersion"
	pathServerInfo             = "/server_info"
	pathHasAllNetworkPermssion = "/hasAllNetworkPermssion"
	pathShouldShowGoogleAds    = "shouldShowGoogleAds"
	currentTermsVersion        = 1
	pathUserSalt               = "user_salt"

	pathPlans        = "/plans/"
	pathResellerCode = "resellercode"
	pathExpirydate   = "expirydate"
	pathExpirystr    = "expirydatestr"

	pathIsAccountVerified = "isAccountVerified"
	pathIsUserLoggedIn    = "IsUserLoggedIn"
	pathIsFirstTime       = "isFirstTime"
	pathDeviceLinkingCode = "devicelinkingcode"
	pathDeviceCodeExp     = "devicecodeexp"

	group            = srp.RFC5054Group3072
	pathHasConfig    = "hasConfigFetched"
	pathHasProxy     = "hasProxyFetched"
	pathHasonSuccess = "hasOnSuccess"
)

type SessionModelOpts struct {
	DevelopmentMode bool
	// ProUser         bool
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
	dialTimeout := 30 * time.Second
	if opts.Platform == "ios" {
		dialTimeout = 20 * time.Second
		base.db.RegisterType(1000, &protos.ServerInfo{})
		base.db.RegisterType(2000, &protos.Devices{})
		base.db.RegisterType(5000, &protos.Device{})
		base.db.RegisterType(3000, &protos.Plan{})
		base.db.RegisterType(4000, &protos.Plans{})
	}

	m := &SessionModel{baseModel: base}

	userConfig := func() common.UserConfig {
		deviceID, _ := m.GetDeviceID()
		userID, _ := m.GetUserID()
		token, _ := m.GetToken()
		lang, _ := m.Locale()
		internalHeaders := map[string]string{
			common.PlatformHeader:   opts.Platform,
			common.AppVersionHeader: common.ApplicationVersion,
		}
		return common.NewUserConfig(
			common.DefaultAppName,
			deviceID,
			userID,
			token,
			internalHeaders,
			lang,
		)
	}

	webclientOpts := &webclient.Opts{
		// Use proxied.Fronted for IOS client since ChainedThenFronted it does not work with ios due to (chained proxy unavailable)
		// because we are not using the flashlight on ios
		// We need to figure out where to put proxied SetProxyAddr
		HttpClient: &http.Client{
			Transport: proxied.Fronted(dialTimeout),
			Timeout:   dialTimeout,
		},
		UserConfig: userConfig,
	}
	m.proClient = pro.NewClient(fmt.Sprintf("https://%s", common.ProAPIHost), webclientOpts)
	m.authClient = auth.NewClient(fmt.Sprintf("https://%s", common.V1BaseUrl), webclientOpts)

	m.baseModel.doInvokeMethod = m.doInvokeMethod
	go m.initSessionModel(context.Background(), opts)
	return m, nil
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
		err := setProUser(m.baseModel, arguments.Scalar().Bool())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setLanguage":
		err := setLanguage(m, arguments.Get("lang").String())
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
	case "createUser":
		err := m.userCreate(context.Background())
		if err != nil {
			log.Error(err)
		}
		return true, nil
	case "hasAllNetworkPermssion":
		err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put[bool](tx, pathHasAllNetworkPermssion, true, "")
		})
		if err != nil {
			return nil, err
		}
		return true, nil // Add return statement here
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
	case "validateRecoveryCode":
		email := arguments.Get("email").String()
		code := arguments.Get("code").String()
		err := validateRecoveryByEmail(m, email, code)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "startChangeEmail":
		email := arguments.Get("email").String()
		newEmail := arguments.Get("newEmail").String()
		password := arguments.Get("password").String()
		err := startChangeEmail(*m, email, newEmail, password)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "completeChangeEmail":
		email := arguments.Get("email").String()
		newEmail := arguments.Get("newEmail").String()
		password := arguments.Get("password").String()
		code := arguments.Get("code").String()
		err := completeChangeEmail(*m, email, newEmail, password, code)
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

		// Device Linking
	case "requestLinkCode":
		err := linkCodeRequest(m)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "redeemLinkCode":
		err := linkCodeRedeem(m)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "authorizeViaEmail":
		email := arguments.Get("emailAddress").String()
		err := requestRecoveryEmail(m, email)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "approveDevice":
		code := arguments.Get("code").String()
		err := linkCodeApprove(m, code)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "removeDevice":
		deviceId := arguments.Get("deviceId").String()
		err := userLinkRemove(m, deviceId)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "validateDeviceRecoveryCode":
		code := arguments.Get("code").String()
		err := validateDeviceRecoveryCode(m, code)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "updateStats":
		city := arguments.Get("city").String()
		country := arguments.Get("country").String()
		serverCountryCode := arguments.Get("serverCountryCode").String()
		httpsUpgrades := arguments.Get("httpsUpgrades").Int()
		adsBlocked := arguments.Get("adsBlocked").Int()
		hasSucceedingProxy := arguments.Get("hasSucceedingProxy").Bool()
		err := m.UpdateStats(city, country, serverCountryCode, httpsUpgrades, adsBlocked, hasSucceedingProxy)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "isUserFirstTimeVisit":
		return checkFirstTimeVisit(m.baseModel)
	case "setFirstTimeVisit":
		err := isShowFirstTimeUserVisit(m.baseModel)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "updatePaymentPlans":
		err := m.paymentMethods()
		if err != nil {
			return nil, err
		}
		return true, nil
	default:
		return m.methodNotImplemented(method)
	}
}

// InvokeMethod handles method invocations on the SessionModel.
func (m *SessionModel) initSessionModel(ctx context.Context, opts *SessionModelOpts) error {
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
	log.Debugf("my device id %v", opts.DeviceID)
	err = pathdb.PutAll(tx, map[string]interface{}{
		pathDevelopmentMode: opts.DevelopmentMode,
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
		log.Debugf("Error while commiting transaction %v", err)
		return err
	}
	// Check if user is already registered or not
	userId, err := m.GetUserID()
	if err != nil {
		return err
	}
	log.Debugf("UserId is %v", userId)
	if userId == 0 {
		// Create user
		pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathIsFirstTime, true, "")
		})
		err = m.userCreate(ctx)
		if err != nil {
			log.Error(err)
		}
	}

	// Get all user details
	err = m.userDetail(ctx)
	if err != nil {
		log.Error(err)
	}

	go func() {
		err = m.paymentMethods()
		if err != nil {
			log.Debugf("Plans V3 error: %v", err)
			// return err
		}
	}()

	return checkAdsEnabled(m)
}

func (session *SessionModel) paymentMethods() error {
	plans, err := session.proClient.PaymentMethodsV4(context.Background())
	if err != nil {
		log.Debugf("Plans V3 error: %v", err)
		return err
	}
	log.Debugf("Plans V4 response: %+v", plans)

	/// Process Plans and providers
	err = storePlanDetail(session.baseModel, plans)
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

func (m *SessionModel) isUserLoggedIn() (bool, error) {
	return pathdb.Get[bool](m.baseModel.db, pathIsUserLoggedIn)
}

func setLanguage(m *SessionModel, lang string) error {
	go func() {
		err := m.paymentMethods()
		if err != nil {
			log.Errorf("Plans V4 error: %v", err)
			// return
		}
	}()
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathLang, lang, "")
	})
}

func setDevices(m *baseModel, devices []*protos.Device) error {
	if len(devices) == 0 {
		log.Debugf("No devices to found")
		return nil
	}
	log.Debugf("Device list %v", devices)
	var protoDevices []*protos.Device
	for _, device := range devices {
		protoDevice := &protos.Device{
			Id:      device.Id,
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

func storePlanDetail(m *baseModel, plan *pro.PaymentMethodsResponse) error {
	log.Debugf("Storing Plan details ")
	err := setPlans(m, plan.Plans)
	if err != nil {
		return err
	}
	log.Debugf("Plan details stored successful")
	return nil
}

func setPlans(m *baseModel, plans []protos.Plan) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		for _, plans := range plans {
			log.Debugf("Plans Values %+v", &plans)
			pathPlanId := pathPlans + strings.Split(plans.Id, "-")[0]
			err := pathdb.Put(tx, pathPlanId, &plans, "")
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
func (m *SessionModel) SetHasConfigFetched(fetached bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathHasConfig, fetached, "")
	}))
}

func (m *SessionModel) SetHasProxyFetched(fetached bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathHasProxy, fetached, "")
	}))
}
func (m *SessionModel) SetOnSuccess(fetached bool) {
	panicIfNecessary(pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathHasonSuccess, fetached, "")
	}))
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

func checkFirstTimeVisit(m *baseModel) (bool, error) {
	firsttime, err := pathdb.Get[bool](m.db, pathIsFirstTime)
	if err != nil {
		return false, err
	}
	log.Debugf("First time visit %v", firsttime)
	return firsttime, nil
}

func isShowFirstTimeUserVisit(m *baseModel) error {
	log.Debugf("Setting first time visit to false")
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathIsFirstTime, false, "")
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

func getUserSalt(m *SessionModel, email string) ([]byte, error) {
	lowerCaseEmail := strings.ToLower(email)
	userSalt, err := pathdb.Get[[]byte](m.db, pathUserSalt)
	if err != nil {
		return nil, err
	}
	if len(userSalt) == 16 {
		log.Debugf("salt return from cache %v", userSalt)
		return userSalt, nil
	}
	log.Debugf("Salt not found calling api for %s", email)
	salt, err := m.authClient.GetSalt(context.Background(), lowerCaseEmail)
	if err != nil {
		return nil, err
	}
	log.Debugf("Salt Response-> %v", salt.Salt)
	return salt.Salt, nil
}

// userCreate creates a new user and stores it in pathdb
func (session *SessionModel) userCreate(ctx context.Context) error {
	resp, err := session.proClient.UserCreate(ctx)
	if err != nil {
		log.Errorf("Error sending request: %v", err)
		return err
	}
	user := resp.User
	if user == nil || user.UserId == 0 {
		log.Errorf("User not found in response")
		return errors.New("User not found in response")
	}

	//Save user id and token
	err = setUserIdAndToken(session.baseModel, int64(user.UserId), user.Token)
	if err != nil {
		return err
	}
	log.Debugf("Created new Lantern user: %+v", user)
	return nil
}

func (session *SessionModel) userDetail(ctx context.Context) error {
	resp, err := session.proClient.UserData(ctx)
	if err != nil {
		return nil
	}
	if resp.User == nil {
		return errors.New("User data not found")
	}
	userDetail := resp.User
	log.Debugf("User detail: %+v", userDetail)

	logged, err := session.isUserLoggedIn()
	if err != nil {
		log.Errorf("Error while checking user login status %v", err)
	}
	// This because we do not want to store email in cache when user is logged in
	// Legacy user can overide there new email
	if logged {
		userDetail.Email = ""
	}
	log.Debugf("User detail: %+v", userDetail)
	err = cacheUserDetail(session, userDetail)
	if err != nil {
		return err
	}
	return nil
}

func cacheUserDetail(session *SessionModel, userDetail *protos.User) error {
	if userDetail.Email != "" {
		setEmail(session.baseModel, userDetail.Email)
	}
	//Save user refferal code
	if userDetail.Referral != "" {
		err := setReferalCode(session.baseModel, userDetail.Referral)
		if err != nil {
			return err
		}
	}

	err := setUserLevel(session.baseModel, userDetail.UserLevel)
	if err != nil {
		return err
	}

	err = setExpiration(session.baseModel, userDetail.Expiration)
	if err != nil {
		return err
	}

	currentDevice, err := session.GetDeviceID()
	if err != nil {
		log.Debugf("Error while getting device id %v", err)
	}
	// Check if devuce id is connect to same device if not create new user
	// this is for the case when user removed device from other device
	deviceFound := false
	if userDetail.Devices != nil {
		for _, device := range userDetail.Devices {
			if device.Id == currentDevice {
				deviceFound = true
				break
			}
		}
	}
	log.Debugf("Device found %v", deviceFound)
	// if !deviceFound {
	// 	// Device has not found in the list
	// 	// Switch to free user
	// 	signOut(*session)
	// 	log.Debugf("Device has not found in the list creating new user")
	// 	err = session.userCreate(context.Background())
	// 	if err != nil {
	// 		return err
	// 	}
	// 	return nil
	// }

	/// Check if user has installed app first time
	firstTime, err := checkFirstTimeVisit(session.baseModel)
	if err != nil {
		log.Debugf("Error while checking first time visit %v", err)
	}
	log.Debugf("First time visit %v", firstTime)

	if userDetail.UserLevel == "pro" && firstTime {
		log.Debugf("User is pro and first time")
		setProUser(session.baseModel, true)
	} else if userDetail.UserLevel == "pro" && !firstTime && deviceFound {
		log.Debugf("User is pro and not first time")
		setProUser(session.baseModel, true)
	} else {
		log.Debugf("User is not pro")
		setProUser(session.baseModel, false)
	}

	//Store all device
	err = setDevices(session.baseModel, userDetail.Devices)
	if err != nil {
		return err
	}
	log.Debugf("User caching successful: %+v", userDetail)
	return setUserIdAndToken(session.baseModel, int64(userDetail.UserId), userDetail.Token)
}

func reportIssue(session *SessionModel, email string, issue string, description string) error {
	// Check if email is there is yes then store it
	if email != "" {
		pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathEmailAddress, email, "")
		})
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
func redeemResellerCode(m *SessionModel, email string, resellerCode string) error {
	lowerCaseEmail := strings.ToLower(email)
	err := setEmail(m.baseModel, lowerCaseEmail)
	if err != nil {
		log.Errorf("Error while setting email %v", err)
		return err
	}
	setResellerCode(m.baseModel, resellerCode)
	if err != nil {
		log.Errorf("Error while setting resellerCode %v", err)
		return err
	}

	err, purchaseData := createPurchaseData(m, lowerCaseEmail, paymentProviderResellerCode, resellerCode, "", "")
	if err != nil {
		log.Errorf("Error while creating  purchase data %v", err)
		return err
	}

	purchase, err := m.proClient.PurchaseRequest(context.Background(), purchaseData)
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
	log.Debugf("Purchase data %+v", purchaseData)
	purchase, err := m.proClient.PurchaseRequest(context.Background(), purchaseData)
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

/// Auth APIS

// Authenticates the user with the given email and password.
//
//	Note-: On Sign up Client needed to generate 16 byte slat
//	Then use that salt, password and email generate encryptedKey once you created encryptedKey pass it to srp.NewSRPClient
//	Then use srpClient.Verifier() to generate verifierKey
func signup(session *SessionModel, email string, password string) error {
	lowerCaseEmail := strings.ToLower(email)
	err := setEmail(session.baseModel, lowerCaseEmail)
	if err != nil {
		return err
	}
	salt, err := GenerateSalt()
	if err != nil {
		return err
	}

	srpClient := srp.NewSRPClient(srp.KnownGroups[group], GenerateEncryptedKey(password, lowerCaseEmail, salt), nil)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return err
	}
	signUpRequestBody := &protos.SignupRequest{
		Email:                 lowerCaseEmail,
		Salt:                  salt,
		Verifier:              verifierKey.Bytes(),
		SkipEmailConfirmation: true,
	}
	log.Debugf("Sign up request email %v, salt %v verifier %v verifiter in bytes %v", lowerCaseEmail, salt, verifierKey, verifierKey.Bytes())
	signupResponse, err := session.authClient.SignUp(context.Background(), signUpRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("sign up response %v", signupResponse)
	//Request successfull then save salt
	err = pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathUserSalt:          salt,
			pathIsAccountVerified: false,
			pathEmailAddress:      lowerCaseEmail,
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
	salt, err := getUserSalt(session, email)
	if err != nil {
		return err
	}

	signUpEmailResendRequestBody := &protos.SignupEmailResendRequest{
		Email: email,
		Salt:  salt,
	}

	signupEmailResendResponse, err := session.authClient.SignupEmailResendCode(context.Background(), signUpEmailResendRequestBody)
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
	signupEmailResendResponse, err := session.authClient.SignupEmailConfirmation(context.Background(), signUpEmailResendRequestBody)
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
	lowerCaseEmail := strings.ToLower(email)
	start := time.Now()
	// Get the salt
	salt, err := getUserSalt(session, lowerCaseEmail)
	if err != nil {
		return err
	}

	encryptedKey := GenerateEncryptedKey(password, lowerCaseEmail, salt)
	log.Debugf("Encrypted key %v Login", encryptedKey)
	// Prepare login request body
	client := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)
	//Send this key to client
	A := client.EphemeralPublic()
	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: lowerCaseEmail,
		A:     A.Bytes(),
	}
	srpB, err := session.authClient.LoginPrepare(context.Background(), prepareRequestBody)
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
	if !client.GoodServerProof(salt, lowerCaseEmail, srpB.Proof) {
		return log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return log.Errorf("user_not_found error while generating client proof %v", err)
	}
	deviceId, err := session.GetDeviceID()
	if err != nil {
		return err
	}
	loginRequestBody := &protos.LoginRequest{
		Email:    lowerCaseEmail,
		Proof:    clientProof,
		DeviceId: deviceId,
	}
	log.Debugf("Login request body %v", loginRequestBody)

	login, err := session.authClient.Login(context.Background(), loginRequestBody)
	if err != nil {
		return err
	}
	if !login.Success {
		err := deviceLimitFlow(session, login)
		if err != nil {
			return log.Errorf("error while starting device limit flow %v", err)
		}
		return log.Errorf("too-many-devices %v", err)
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

	//Store all the user details
	userData := ConvertToUserDetailsResponse(login)
	// once login is successfull save user details
	// but overide there email with login email
	userData.Email = email
	err = cacheUserDetail(session, userData)
	if err != nil {
		log.Errorf("Error while caching user details %v", err)
		return err
	}
	end := time.Now()

	log.Debugf("Login took %v", end.Sub(start))
	return nil
}

// Add device to user currect device list
// this gets called when user to login
func deviceAdd(session *SessionModel, deviceName string) error {
	device, err := pathdb.Get[string](session.db, pathDevice)
	if err != nil {
		log.Errorf("Error while getting device %v", err)
		return err
	}
	addDevice, err := session.proClient.DeviceAdd(context.Background(), device)
	if err != nil {
		log.Errorf("Error while adding device %v", err)
	}
	log.Debugf("Add device response %v", addDevice)
	return nil
}

func deviceLimitFlow(session *SessionModel, login *protos.LoginResponse) error {
	// User has reached device limit
	// Save latest device
	var protoDevices []*protos.Device
	for _, device := range login.Devices {
		protoDevice := &protos.Device{
			Id:      device.Id,
			Name:    device.Name,
			Created: device.Created,
		}
		protoDevices = append(protoDevices, protoDevice)
	}

	userDevice := &protos.Devices{Devices: protoDevices}
	err := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		pathdb.Put(tx, pathDevices, userDevice, "")
		return nil
	})
	if err != nil {
		return err
	}
	return setUserIdAndToken(session.baseModel, login.LegacyID, login.LegacyToken)
}

func startRecoveryByEmail(session *SessionModel, email string) error {
	//Create body
	lowerCaseEmail := strings.ToLower(email)
	prepareRequestBody := &protos.StartRecoveryByEmailRequest{
		Email: lowerCaseEmail,
	}
	recovery, err := session.authClient.StartRecoveryByEmail(context.Background(), prepareRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("StartRecoveryByEmail response %v", recovery)
	return nil
}

func completeRecoveryByEmail(session *SessionModel, email string, code string, password string) error {
	//Create body
	lowerCaseEmail := strings.ToLower(email)
	newsalt, err := GenerateSalt()
	if err != nil {
		return err
	}
	log.Debugf("Slat %v and length %v", newsalt, len(newsalt))

	encryptedKey := GenerateEncryptedKey(password, lowerCaseEmail, newsalt)
	log.Debugf("Encrypted key %v completeRecoveryByEmail", encryptedKey)
	srpClient := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return err
	}

	prepareRequestBody := &protos.CompleteRecoveryByEmailRequest{
		Email:       lowerCaseEmail,
		Code:        code,
		NewSalt:     newsalt,
		NewVerifier: verifierKey.Bytes(),
	}

	log.Debugf("new Verifier %v and salt %v", verifierKey.Bytes(), newsalt)
	recovery, err := session.authClient.CompleteRecoveryByEmail(context.Background(), prepareRequestBody)
	if err != nil {
		return err
	}
	//User has been recovered successfully
	//Save new salt
	saveUserSalt(session.baseModel, newsalt)
	log.Debugf("CompleteRecoveryByEmail response %v", recovery)
	//refresh the user details
	go func() {
		session.userDetail(context.Background())
	}()
	return nil
}

// This will validate code send by server
func validateRecoveryByEmail(session *SessionModel, email string, code string) error {
	lowerCaseEmail := strings.ToLower(email)
	prepareRequestBody := &protos.ValidateRecoveryCodeRequest{
		Email: lowerCaseEmail,
		Code:  code,
	}
	recovery, err := session.authClient.ValidateEmailRecoveryCode(context.Background(), prepareRequestBody)
	if err != nil {
		return err
	}
	if !recovery.Valid {
		return log.Errorf("invalid_code Error: %v", err)
	}
	log.Debugf("Validate code response %v", recovery.Valid)
	return nil
}

// Change Email flow

func startChangeEmail(session SessionModel, email string, newEmail string, password string) error {
	lowerCaseEmail := strings.ToLower(email)
	lowerCaseNewEmail := strings.ToLower(newEmail)
	salt, err := getUserSalt(&session, lowerCaseEmail)
	if err != nil {
		return err
	}

	// Prepare login request body
	client := srp.NewSRPClient(srp.KnownGroups[group], GenerateEncryptedKey(password, lowerCaseEmail, salt), nil)

	//Send this key to client
	A := client.EphemeralPublic()

	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: lowerCaseEmail,
		A:     A.Bytes(),
	}
	srpB, err := session.authClient.LoginPrepare(context.Background(), prepareRequestBody)
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
	if !client.GoodServerProof(salt, lowerCaseEmail, srpB.Proof) {
		return log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return log.Errorf("user_not_found error while generating client proof %v", err)
	}

	changeEmailRequestBody := &protos.ChangeEmailRequest{
		OldEmail: lowerCaseEmail,
		NewEmail: lowerCaseNewEmail,
		Proof:    clientProof,
	}

	isEmailChanged, err := session.authClient.ChangeEmail(context.Background(), changeEmailRequestBody)
	if err != nil {
		return err
	}
	log.Debugf("Change Email response %v", isEmailChanged)
	return nil
}

func completeChangeEmail(session SessionModel, email string, newEmail string, password string, code string) error {
	// Create new salt and verifier with new email and new slat
	newsalt, err := GenerateSalt()
	if err != nil {
		return err
	}
	log.Debugf("Slat %v and length %v", newsalt, len(newsalt))

	srpClient := srp.NewSRPClient(srp.KnownGroups[group], GenerateEncryptedKey(password, newEmail, newsalt), nil)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return err
	}

	completeChangeEmail := &protos.CompleteChangeEmailRequest{
		OldEmail:    email,
		NewEmail:    newEmail,
		NewSalt:     newsalt,
		NewVerifier: verifierKey.Bytes(),
		Code:        code,
	}

	isEmailChanged, err := session.authClient.CompleteChangeEmail(context.Background(), completeChangeEmail)
	if err != nil {
		return err
	}
	log.Debugf("Compelte Change Email response %v", isEmailChanged)
	return setEmail(session.baseModel, newEmail)
}

// Clear slat and change accoutn state
func signOut(session SessionModel) error {
	email, err := session.Email()
	if err != nil {
		return log.Errorf("Email not found %v", err)
	}

	deviceId, err := session.GetDeviceID()
	if err != nil {
		return log.Errorf("deviceId not found %v", err)
	}

	token, err := session.GetToken()
	if err != nil {
		return log.Errorf("token not found %v", err)
	}

	userId, err := session.GetUserID()
	if err != nil {
		return log.Errorf("userid not found %v", err)
	}

	signoutData := &protos.LogoutRequest{
		Email:        email,
		DeviceId:     deviceId,
		LegacyToken:  token,
		LegacyUserID: userId,
	}

	log.Debugf("Sign out request %+v", signoutData)

	loggedOut, logoutErr := session.authClient.SignOut(context.Background(), signoutData)
	if err != nil {
		return log.Errorf("Error while signing out %v", logoutErr)
	}

	if !loggedOut {
		return log.Errorf("Error while signing out %v", logoutErr)
	}

	err = clearLocalUserData(session)
	if err != nil {
		return log.Errorf("Error while clearing local data %v", err)
	}
	return session.userCreate(context.Background())
}

func clearLocalUserData(session SessionModel) error {
	err1 := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathUserSalt:     nil,
			pathEmailAddress: "",
		})
	})
	if err1 != nil {
		return err1
	}
	_ = pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsUserLoggedIn, false, "")
	})

	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathProUser, false, "")

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

	lowerCaseEmail := strings.ToLower(email)
	salt, err := getUserSalt(&session, lowerCaseEmail)
	if err != nil {
		return err
	}

	// Prepare login request body
	client := srp.NewSRPClient(srp.KnownGroups[group], GenerateEncryptedKey(password, lowerCaseEmail, salt), nil)

	//Send this key to client
	A := client.EphemeralPublic()

	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: lowerCaseEmail,
		A:     A.Bytes(),
	}
	log.Debugf("Login prepare request  email %v, a bytes %v", lowerCaseEmail, A.Bytes())
	srpB, err := session.authClient.LoginPrepare(context.Background(), prepareRequestBody)
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
	if !client.GoodServerProof(salt, lowerCaseEmail, srpB.Proof) {
		return log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return log.Errorf("user_not_found error while generating client proof %v", err)
	}

	deviceId, err := session.GetDeviceID()
	if err != nil {
		return err
	}
	changeEmailRequestBody := &protos.DeleteUserRequest{
		Email:     lowerCaseEmail,
		Proof:     clientProof,
		Permanent: true,
		DeviceId:  deviceId,
	}

	log.Debugf("Delete Account request email %v prooof %v deviceId %v", lowerCaseEmail, clientProof, deviceId)
	isAccountDeleted, err := session.authClient.DeleteAccount(context.Background(), changeEmailRequestBody)
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
	err = clearLocalUserData(session)
	if err != nil {
		return err
	}
	return session.userCreate(context.Background())
}

// Device Linking methods

// Request code for linking device for LINK WITH PIN method
func linkCodeRequest(session *SessionModel) error {
	log.Debug("LinkCodeRequest")
	device, err := pathdb.Get[string](session.db, pathDevice)
	if err != nil {
		log.Errorf("Error while getting device %v", err)
		return err
	}
	log.Debugf("Device %v", device)

	linkResponse, err := session.proClient.LinkCodeRequest(context.Background(), device)
	if err != nil {
		return err
	}
	log.Debugf("LinkCodeRequest response %v", linkResponse)
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		err := pathdb.Put[int64](tx, pathDeviceCodeExp, (linkResponse.ExpireAt * 1000), "")
		if err != nil {
			return err
		}
		return pathdb.Put[string](tx, pathDeviceLinkingCode, linkResponse.Code, "")
	})
}

// Approve code for linking device for LINK WITH PIN method
func linkCodeRedeem(session *SessionModel) error {
	device, err := pathdb.Get[string](session.db, pathDevice)
	if err != nil {
		log.Errorf("Error while getting device %v", err)
		return err
	}
	deviceCode, err := pathdb.Get[string](session.db, pathDeviceLinkingCode)
	if err != nil {
		log.Errorf("Error while getting device %v", err)
		return err
	}
	if deviceCode == "" || device == "" {
		return errors.New("Device code or device not found")
	}
	log.Debugf("Device %v deviceCode %v", device, deviceCode)
	linkRedeemResponse, err := session.proClient.LinkCodeRedeem(context.Background(), device, deviceCode)
	if err != nil {
		return err
	}
	log.Debugf("linkCodeRedeem response %+v", linkRedeemResponse)
	err = setUserIdAndToken(session.baseModel, linkRedeemResponse.UserID, linkRedeemResponse.Token)
	if err != nil {
		return log.Errorf("Error while setting user id and token %v", err)
	}
	return session.userDetail(context.Background())
}

// Approve code for linking device for LINK WITH PIN method
func linkCodeApprove(session *SessionModel, code string) error {
	linkResponse, err := session.proClient.LinkCodeApprove(context.Background(), code)
	if err != nil {
		return err
	}
	log.Debugf("LinkCodeApprove response %v", linkResponse)
	// refresh user detail in background
	go func() {
		session.userDetail(context.Background())
	}()
	return nil
}

// Remove device for LINK WITH PIN method
func userLinkRemove(session *SessionModel, deviceId string) error {
	linkResponse, err := session.proClient.DeviceRemove(context.Background(), deviceId)
	if err != nil {
		return err
	}
	log.Debugf("UserLink Remove response %v", linkResponse)
	return session.userDetail(context.Background())
}

// Add device for LINK WITH EMAIL method
func requestRecoveryEmail(session *SessionModel, email string) error {
	deviceId, err := pathdb.Get[string](session.db, pathDeviceID)
	if err != nil {
		log.Errorf("Error while getting deviceId %v", err)
		return err
	}

	linkResponse, err := session.proClient.UserLinkCodeRequest(context.Background(), deviceId)
	if err != nil {
		return err
	}
	log.Debugf("requestRecoveryEmail response %v", linkResponse)
	return nil
}

// Validate code for LINK WITH EMAIL method
func validateDeviceRecoveryCode(session *SessionModel, code string) error {
	deviceId, err := pathdb.Get[string](session.db, pathDeviceID)
	if err != nil {
		log.Errorf("Error while getting deviceId %v", err)
		return err
	}

	linkResponse, err := session.proClient.UserLinkValidate(context.Background(), deviceId)
	if err != nil {
		return err
	}
	log.Debugf("ValidateRecovery code response %v", linkResponse)
	err = setUserIdAndToken(session.baseModel, linkResponse.UserID, linkResponse.Token)
	if err != nil {
		return err
	}
	pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsUserLoggedIn, true, "")
	})
	// Update user detail to reflact on UI
	return session.userDetail(context.Background())
}
