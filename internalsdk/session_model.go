package internalsdk

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/1Password/srp"
	"google.golang.org/protobuf/proto"

	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/logging"
	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/ios"
	iosGeoLookup "github.com/getlantern/lantern-client/internalsdk/ios/geolookup"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	*baseModel
	authClient    auth.AuthClient
	proClient     pro.ProClient
	surveyModel   *SurveyModel
	iosConfigurer *config.Global
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
	pathAuthEnabled            = "authEnabled"
	pathChatEnabled            = "chatEnabled"
	pathDevelopmentMode        = "developmentMode"
	pathGeoCountryCode         = "geo_country_code"
	pathIPAddress              = "ip_address"
	pathServerCountry          = "server_country"
	pathServerCountryCode      = "server_country_code"
	pathServerCity             = "server_city"
	pathHasSucceedingProxy     = "hasSucceedingProxy"
	pathLatestBandwith         = "latest_bandwidth"
	pathBandwidth              = "/bandwidth"
	pathTimezoneID             = "timezone_id"
	pathReferralCode           = "referral"
	pathForceCountry           = "forceCountry"
	pathDNSDetector            = "dns_detector"
	pathProvider               = "provider"
	pathEmailAddress           = "emailAddress"
	pathCurrencyCode           = "currency_Code"
	pathReplicaAddr            = "replicaAddr"
	pathSplitTunneling         = "/splitTunneling"
	pathProxyless              = "/proxyless"
	pathLang                   = "lang"
	pathAcceptedTermsVersion   = "accepted_terms_version"
	pathAdsEnabled             = "adsEnabled"
	pathShowAds                = "showAds"
	pathStoreVersion           = "storeVersion"
	pathTestPlayVersion        = "testPlayVersion"
	pathServerInfo             = "/server_info"
	pathHasAllNetworkPermssion = "/hasAllNetworkPermssion"
	pathPrefVPN                = "pref_vpn"

	pathShouldShowInterstitialAds = "shouldShowGoogleAds"
	pathShouldShowAppOpenAds      = "shouldShowAppOpenAds"
	currentTermsVersion           = 1
	pathUserSalt                  = "user_salt"

	pathPlans          = "/plans/"
	pathPaymentMethods = "/paymentMethods/"
	pathResellerCode   = "resellercode"
	pathExpirydate     = "expirydate"
	pathExpirystr      = "expirydatestr"

	pathIsUserLoggedIn    = "IsUserLoggedIn"
	pathIsFirstTime       = "isFirstTime"
	pathDeviceLinkingCode = "devicelinkingcode"
	pathDeviceCodeExp     = "devicecodeexp"
	pathStripePubKey      = "stripe_api_key"

	group            = srp.RFC5054Group3072
	pathHasConfig    = "hasConfigFetched"
	pathHasProxy     = "hasProxyFetched"
	pathHasonSuccess = "hasOnSuccess"
	pathPlatform     = "platform"
	//Split Tunneling
	pathAppsData = "/appsData/"
)

type SessionModelOpts struct {
	DevelopmentMode bool
	DeviceID        string
	Device          string
	Model           string
	OsVersion       string
	PlayVersion     bool
	Lang            string
	TimeZone        string
	Platform        string
	ConfigPath      string
}

var (
	stasMutex sync.Mutex
)

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(mdb minisql.DB, opts *SessionModelOpts) (*SessionModel, error) {
	base, err := newModel("session", mdb)
	if err != nil {
		return nil, err
	}
	if opts.Platform == "ios" {
		base.db.RegisterType(1000, &protos.ServerInfo{})
		base.db.RegisterType(2000, &protos.Devices{})
		base.db.RegisterType(3000, &protos.Plan{})
		base.db.RegisterType(5000, &protos.Device{})
		base.db.RegisterType(4000, &protos.Plans{})
		base.db.RegisterType(6000, &protos.Bandwidth{})
	} else {
		base.db.RegisterType(1000, &protos.ServerInfo{})
		base.db.RegisterType(2000, &protos.Devices{})
		base.db.RegisterType(3000, &protos.Plan{})
		base.db.RegisterType(4000, &protos.Plans{})
		base.db.RegisterType(5000, &protos.AppData{})
		base.db.RegisterType(6000, &protos.PaymentProviders{})
		base.db.RegisterType(7000, &protos.PaymentMethod{})
		base.db.RegisterType(8000, &protos.Bandwidth{})
		base.db.RegisterType(9000, &protos.Device{})

	}

	m := &SessionModel{baseModel: base}

	deviceID, _ := m.GetDeviceID()
	userID, _ := m.GetUserID()
	token, _ := m.GetToken()
	lang, _ := m.Locale()

	m.proClient = createProClient(m, opts.Platform)

	authUrl := common.DFBaseUrl
	if opts.Platform == "ios" {
		authUrl = common.APIBaseUrl
	}
	m.authClient = auth.NewClient(fmt.Sprintf("https://%s", authUrl), func() common.UserConfig {
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
	})

	m.baseModel.doInvokeMethod = m.doInvokeMethod
	if opts.Platform == "ios" {
		m.iosInit(opts.ConfigPath, int(userID), token, deviceID)
	}
	log.Debugf("SessionModel initialized")
	go m.initSessionModel(context.Background(), opts)
	return m, nil
}

// this method initializes the ios configuration for the session model
// also this method check for geoLookup
func (m *SessionModel) iosInit(configPath string, userId int, token string, deviceId string) error {
	go m.setupIosConfigure(configPath, userId, token, deviceId)
	go func() {
		if <-iosGeoLookup.OnRefresh() {
			country := iosGeoLookup.GetCountry(5 * time.Second)
			//get the country for the user
			log.Debugf("Getting country for user %v", country)
			m.SetCountry(country)
		}
	}()
	return nil
}

// setupIosConfigure sets up the iOS configuration for the session model.
// It continuously checks if the global configuration is available and retries every second if not.
func (m *SessionModel) setupIosConfigure(configPath string, userId int, token string, deviceId string) {
	cf := ios.NewConfigurer(configPath, userId, token, deviceId, "")
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()
	for range ticker.C {
		if cf.HasGlobalConfig() {
			global, _, _, err := cf.OpenGlobal()
			if err != nil {
				log.Errorf("Error while opening global %v", err)
				return
			}
			m.iosConfigurer = global
			log.Debug("Found global config IOS configure done")
			go m.checkAvailableFeatures()
			return // Exit the loop after success
		}
		log.Debugf("global config not available, retrying...")
	}

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
		err := m.SetProUser(arguments.Scalar().Bool())
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
		value := arguments.Get("on").Bool()
		err := setStoreVersion(m.baseModel, value)
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
	case "collectLogs":
		path := arguments.Get("path").String()
		err := collectLogs(path)
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
	case "updateUserDetail":
		err := m.userDetail(context.Background())
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
		checkAdsEnabled(m)
		return true, nil
	case "setDeviceId":
		deviceId := arguments.Get("deviceID").String()
		err := m.setDeviceId(deviceId)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setUserIdAndToken":
		userId := arguments.Get("userId").Int()
		token := arguments.Get("token").String()
		err := m.SetUserIDAndToken(int64(userId), token)
		if err != nil {
			return nil, err
		}
		return true, nil
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

	case "restoreAccount":
		email := arguments.Get("email").String()
		code := arguments.Get("code").String()
		provider := arguments.Get("provider").String()
		err := restorePurchase(m, email, code, provider)
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
	case "validateRecoveryByEmail":
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

	case "userEmailRequest":
		email := arguments.Get("email").String()
		err := userEmailRequest(m, email)
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
	case "updateBandwidth":
		percent := arguments.Get("percent").Int()
		mibUsed := arguments.Get("mibUsed").Int()
		mibAllowed := arguments.Get("mibAllowed").Int()
		ttlSeconds := arguments.Get("ttlSeconds").Int()
		err := m.BandwidthUpdate(percent, mibUsed, mibAllowed, ttlSeconds)
		if err != nil {
			return nil, log.Errorf("Error while updating bandwidth %v", err)
		}
		return true, nil
	case "isUserFirstTimeVisit":
		return checkFirstTimeVisit(m.baseModel)

	case "updateVpnPref":
		useVpn := arguments.Get("useVpn").Bool()
		err := m.updateVpnPref(useVpn)
		if err != nil {
			return nil, err
		}
		return true, nil

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

		//SplitTunneling

	case "appsAllowedAccess":
		apps, err := m.appsAllowedAccess()
		if err != nil {
			return nil, err
		}
		return apps, nil
	case "updateAppsData":
		appsData := arguments.Get("filePath").String()
		err := m.updateAppsData(appsData)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "refreshAppsList":
		appsData := arguments.Get("appsList").String()
		err := m.updateAppsData(appsData)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "setSplitTunneling":
		tunneling := arguments.Get("on").Bool()
		err := m.setSplitTunneling(tunneling)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "setProxyless":
		proxyless := arguments.Get("on").Bool()
		err := m.setProxyless(proxyless)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "denyAppAccess":
		appName := arguments.Get("packageName").String()
		err := m.updateAppData(appName, false)
		if err != nil {
			return nil, err
		}
		return true, nil

	case "allowAppAccess":
		appName := arguments.Get("packageName").String()
		err := m.updateAppData(appName, true)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "chatEnabled":
		return m.ChatEnable(), nil

	case "applyRefCode":
		refCode := arguments.Get("refCode").String()
		err := m.applyRefCode(refCode)
		if err != nil {
			return nil, err
		}
		return true, nil
	case "getStripePubKey":
		return m.getStripePubKey()

	case "submitGooglePlayPayment":
		email := arguments.Get("email").String()
		plandId := arguments.Get("planID").String()
		purchaseToken := arguments.Get("purchaseToken").String()
		err := submitGooglePlayPayment(m, email, plandId, purchaseToken)
		if err != nil {
			log.Errorf("Error while submitting google play payment %v", err)
			return nil, err
		}
		return true, nil

	case "submitStripePlayPayment":
		email := arguments.Get("email").String()
		plandId := arguments.Get("planID").String()
		purchaseToken := arguments.Get("purchaseToken").String()
		err := submitStripePlayPayment(m, email, plandId, purchaseToken)
		if err != nil {
			log.Errorf("Error while submitting google play payment %v", err)
			return nil, err
		}
		return true, nil
	case "generatePaymentRedirectUrl":
		email := arguments.Get("email").String()
		plandId := arguments.Get("planID").String()
		provider := arguments.Get("provider").String()
		url, err := generatePaymentRedirectUrl(m, email, plandId, provider)
		if err != nil {
			log.Errorf("Error while genrating url %v", err)
			return nil, err
		}
		return url, nil

	case "testProviderRequest":
		email := arguments.Get("email").String()
		plandId := arguments.Get("planId").String()
		provider := arguments.Get("provider").String()
		err := testProviderRequest(m, email, provider, plandId)
		if err != nil {
			log.Errorf("Error while calling testProvider %v", err)
			return nil, err
		}
		return true, nil

	case "setTestPlayVesion":
		value := arguments.Get("on").Bool()
		err := m.setTestPlayVesion(value)
		if err != nil {
			return nil, err

		}
		return true, nil
	case "getSurvey":
		surveyString, err := m.getSurvey()
		if err != nil {
			return nil, err
		}
		log.Debugf("Survey String %v", surveyString)
		return surveyString, nil

	case "setSurveyLink":
		err := m.setSurveyLink(arguments.Scalar().String())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "checkIfSurveyLinkOpened":
		return m.checkIfSurveyLinkOpened(arguments.Scalar().String())
	case "checkAvailableFeatures":
		m.checkAvailableFeatures()
		return true, nil

	case "replicaAddr":
		return m.getReplicaAddr(), nil
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
	log.Debugf("my device id %v store version %v", opts.DeviceID, opts.PlayVersion)
	err = pathdb.PutAll(tx, map[string]interface{}{
		pathDevelopmentMode: opts.DevelopmentMode,
		pathDeviceID:        opts.DeviceID,
		pathTimezoneID:      opts.TimeZone,
		pathDevice:          opts.Device,
		pathModel:           opts.Model,
		pathOSVersion:       opts.OsVersion,
		pathStoreVersion:    opts.PlayVersion,
		pathSDKVersion:      SDKVersion(),
		pathPlatform:        opts.Platform,
	})
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
	forceCountry, err := pathdb.Get[string](tx, pathForceCountry)
	if err != nil {
		return err
	}
	countryErr := pathdb.Put(tx, pathForceCountry, forceCountry, "")
	if countryErr != nil {
		log.Errorf("Error while setting force country %v", countryErr)
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
		// Create user
		pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathIsFirstTime, true, "")
		})
		go m.proClient.RetryCreateUser(ctx, m, 10*time.Minute)
	} else {
		go func() {
			// Get all user details
			err = m.userDetail(ctx)
			if err != nil {
				log.Error(err)
			}
			err = m.paymentMethods()
			if err != nil {
				log.Debugf("Plans V3 error: %v", err)
				// return err
			}
		}()
	}
	if opts.Platform == "android" {
		go checkSplitTunneling(m)
	}
	m.surveyModel, _ = NewSurveyModel(*m)
	return nil
}

func (m *SessionModel) checkAvailableFeatures() {
	// Check for auth feature
	authEnabled := m.featureEnabled(config.FeatureAuth)
	m.SetAuthEnabled(authEnabled)
	platfrom, _ := m.platform()
	if platfrom == "ios" {
		m.SetAuthEnabled(true)
	}

	// Check for ads feature
	googleAdsEnabled := m.featureEnabled(config.FeatureInterstitialAds)
	m.SetShowInterstitialAds(googleAdsEnabled)
	if googleAdsEnabled {
		checkAdsEnabled(m)
	}
}

// check if feature is enabled or not
func (m *SessionModel) featureEnabled(feature string) bool {
	userId, err := m.GetUserID()
	if err != nil {
		log.Errorf("Error while getting user id %v", err)
		return false
	}
	isPro, err := m.IsProUser()
	if err != nil {
		log.Errorf("Error while getting user id %v", err)
		return false
	}
	countryCode, err := m.GetCountryCode()
	if err != nil {
		log.Errorf("Error while getting user id %v", err)
		return false
	}
	featureEnabled := m.iosConfigurer.FeatureEnabled(feature, common.Platform, common.DefaultAppName, common.ApplicationVersion, userId, isPro, countryCode)
	log.Debugf("Feature enabled  %s %v with country %s", feature, featureEnabled, countryCode)
	return featureEnabled
}

func (m *SessionModel) platform() (string, error) {
	return pathdb.Get[string](m.db, pathPlatform)
}

func checkSplitTunneling(m *SessionModel) error {
	tunneling, err := pathdb.Get[bool](m.db, pathSplitTunneling)
	if err != nil {
		log.Errorf("Error while getting split tunneling value %v", err)
		m.setSplitTunneling(false)
		return err
	}
	if !tunneling {
		log.Debugf("Split Tunneling already false: %v", tunneling)
	}
	return nil
}

func (session *SessionModel) setSplitTunneling(tunneling bool) error {
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathSplitTunneling, tunneling, "")
	})
}

func (session *SessionModel) setProxyless(proxyless bool) error {
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathProxyless, proxyless, "")
	})
}

func (session *SessionModel) paymentMethods() error {
	plans, err := session.proClient.PaymentMethodsV4(context.Background())
	if err != nil {
		log.Debugf("Plans V4 error: %v", err)
		return err
	}
	log.Debugf("Plans V4 response: %+v", plans)

	/// Process Plans and providers
	err = storePlanDetail(session.baseModel, plans)
	if err != nil {
		return err
	}
	platform, err := session.platform()
	if err != nil {
		return err
	}
	if platform != "ios" {
		storePaymentProviders(session, *plans)
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

func (m *SessionModel) IpAddress() (string, error) {
	return pathdb.Get[string](m.db, pathIPAddress)
}

func (m *SessionModel) UpdateAdSettings(adsetting AdSettings) error {
	// Not using these ads anymore
	return nil
}

// Note - the names of these parameters have to match what's defined on the `Session` interface
func (m *SessionModel) UpdateStats(serverCity string, serverCountry string, serverCountryCode string, p3 int, p4 int, hasSucceedingProxy bool) error {
	if serverCity != "" && serverCountry != "" && serverCountryCode != "" {
		stasMutex.Lock()
		defer stasMutex.Unlock()
		serverInfo := &protos.ServerInfo{
			City:        serverCity,
			Country:     serverCountry,
			CountryCode: serverCountryCode,
		}
		log.Debugf("UpdateStats city %v country %v hasSucceedingProxy %v serverInfo %v", serverCity, serverCountry, hasSucceedingProxy, serverInfo)

		err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathHasSucceedingProxy, hasSucceedingProxy, "")
		})
		if err != nil {
			log.Errorf("Error while setting hasSucceedingProxy %v", err)
		}
		return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put(tx, pathServerInfo, serverInfo, "")
		})
	}
	return nil
}

func (m *SessionModel) SetStaging(staging bool) error {
	// Not using staging anymore
	return nil
}

// Keep name as p1,p2,p3..... percent: Long, mibUsed: Long, mibAllowed: Long, ttlSeconds: Long
// Name become part of Objective c so this is important
func (m *SessionModel) BandwidthUpdate(p1 int, p2 int, p3 int, p4 int) error {
	log.Debugf("BandwidthUpdate percent %v mibUsed %v allowed %v ttl %v", p1, p2, p3, p4)

	bandwidth := &protos.Bandwidth{
		Percent:    int64(p1),
		MibUsed:    int64(p2),
		MibAllowed: int64(p3),
		TtlSeconds: int64(p4),
	}
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathBandwidth, bandwidth, "")
	})
}

func setUserLevel(m *baseModel, userLevel string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathUserLevel, userLevel, "")
	})
}
func (m *SessionModel) SetExpiration(expiration int64) error {
	if expiration == 0 {
		return nil
	}
	log.Debugf("Expiration value %v", expiration)
	expiry := time.Unix(expiration, 0)
	log.Debugf("Expiration value %v", expiry)
	dateFormat := "01/02/2006"
	dateStr := expiry.Format(dateFormat)
	log.Debugf("Expiration value %v", dateStr)

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

func storePaymentProviders(m *SessionModel, paymentMethodsResponse pro.PaymentMethodsResponse) error {
	log.Debugf("Storing Payment Providers")

	logos, err := convertLogoToMapStringSlice(paymentMethodsResponse.Logo)
	if err != nil {
		log.Errorf("Error while converting logo to map %v", err)
		return err
	}
	providers := paymentMethodsResponse.Providers["android"]
	if providers == nil {
		return log.Errorf("Android Providers not found")
	}
	var paymentProviders []*protos.PaymentProviders
	for index, provider := range providers {
		paymentProviders = nil
		path := pathPaymentMethods + ToString(int64(index))
		for _, paymentMethod := range provider.Providers {
			if paymentMethod.Name == paymentProviderStripe {
				m.setStripePubKey(paymentMethod.Data)
			}
			paymentProviders = append(paymentProviders, &protos.PaymentProviders{
				Name:     paymentMethod.Name,
				LogoUrls: logos[paymentMethod.Name],
			})
		}
		payment := &protos.PaymentMethod{
			Method:    provider.Method,
			Providers: paymentProviders,
		}

		log.Debugf("Provider Values %+v path %v", &payment, path)
		if err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
			return pathdb.Put[*protos.PaymentMethod](tx, path, payment, "")
		}); err != nil {
			log.Errorf("Error while adding payment method", err)
			return err
		}
	}
	return nil
}

func (session *SessionModel) setStripePubKey(args map[string]string) error {
	pubKey := args["pubKey"]
	if pubKey == "" {
		return log.Errorf("Stripe public key is empty")
	}
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathStripePubKey, pubKey, "")
	})
}

func (session *SessionModel) getStripePubKey() (string, error) {
	return pathdb.Get[string](session.db, pathStripePubKey)

}

func setPlans(m *baseModel, allPlans []*protos.Plan) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		for _, plans := range allPlans {
			log.Debugf("Plans Values %+v", plans)
			pathPlanId := pathPlans + strings.Split(plans.Id, "-")[0]
			err := pathdb.Put(tx, pathPlanId, plans, "")
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

func (m *SessionModel) SetEmailAddress(email string) error {
	return setEmail(m.baseModel, email)
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

func (m *SessionModel) setDeviceId(deviceId string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathDeviceID, deviceId, "")
	})
}

func (m *SessionModel) IsProUser() (bool, error) {
	return pathdb.Get[bool](m.db, pathProUser)
}

func (m *SessionModel) SetProUser(isPro bool) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathProUser, isPro, "")
	})
}

func (m *SessionModel) SetReferralCode(referralCode string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathReferralCode, referralCode, "")
	})
}

func (m *SessionModel) SetReplicaAddr(replicaAddr string) {
	log.Debugf("Setting replica address %v", replicaAddr)
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathReplicaAddr, replicaAddr, "")
	})
	if err != nil {
		log.Errorf("Error while setting replica address %v", err)
		return
	}
}
func (m *SessionModel) getReplicaAddr() string {
	address, err := pathdb.Get[string](m.db, pathReplicaAddr)
	if err != nil {
		return ""
	}
	return address
}

func (m *SessionModel) ForceReplica() bool {
	// return static for now
	return false
}

func (m *SessionModel) SetAuthEnabled(authEnabled bool) {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathAuthEnabled, authEnabled, "")
	})
	if err != nil {
		log.Errorf("Error while setting auth enabled %v", err)
	}
}

func (m *SessionModel) SetChatEnabled(chatEnabled bool) {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathChatEnabled, chatEnabled, "")
	})
	if err != nil {
		log.Errorf("Error while setting chat enabled %v", err)
	}
}

func (m *SessionModel) ChatEnable() bool {
	chat, err := pathdb.Get[bool](m.db, pathChatEnabled)
	if err != nil {
		return false
	}
	return chat
}

func (m *SessionModel) SplitTunnelingEnabled() (bool, error) {
	return pathdb.Get[bool](m.db, pathSplitTunneling)
}

func (m *SessionModel) ProxylessEnabled() (bool, error) {
	return pathdb.Get[bool](m.db, pathProxyless)
}

func (m *SessionModel) SetShowInterstitialAds(adsEnable bool) {
	log.Debugf("SetShowInterstitialAds %v", adsEnable)
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathShouldShowInterstitialAds, adsEnable, "")
	})
	if err != nil {
		log.Errorf("Error while setting show interstitial ads %v", err)
	}
	if common.Platform == "android" {
		checkAdsEnabled(m)
	}
}

func (m *SessionModel) SetShowAppOpenAds(adsEnable bool) {
	log.Debugf("SetShowAppOpenAds %v", adsEnable)
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathShouldShowAppOpenAds, adsEnable, "")
	})
	if err != nil {
		log.Errorf("Error while setting show app open ads %v", err)
	}
	if common.Platform == "android" {
		checkAdsEnabled(m)
	}
}

func (m *SessionModel) SerializedInternalHeaders() (string, error) {
	// Return static for now
	// Todo implement this method
	return "", nil
}

func (m *SessionModel) setTestPlayVesion(value bool) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathTestPlayVersion, value, "")
	})
}

func saveUserSalt(m *baseModel, salt []byte) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put[[]byte](tx, pathUserSalt, salt, "")
	})
}
func (m *SessionModel) SetHasConfigFetched(fetached bool) {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathHasConfig, fetached, "")
	})
	if err != nil {
		log.Errorf("Error while setting has config fetched %v", err)
	}
}

func (m *SessionModel) SetHasProxyFetched(fetached bool) {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathHasProxy, fetached, "")
	})
	if err != nil {
		log.Errorf("Error while setting has proxy fetched %v", err)
	}
}
func (m *SessionModel) SetOnSuccess(fetached bool) {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathHasonSuccess, fetached, "")
	})
	if err != nil {
		log.Errorf("Error while setting has on success %v", err)
	}
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

func (session *SessionModel) updateVpnPref(prefVPN bool) error {
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathPrefVPN, prefVPN, "")
	})
}

func (m *SessionModel) GetUserFirstVisit() (bool, error) {
	return pathdb.Get[bool](m.db, pathIsFirstTime)
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

// Keep name as p1,p2 somehow is conflicting with objective c
// p1 is userid and p2 is token
func (m *SessionModel) SetUserIDAndToken(p1 int64, p2 string) error {
	log.Debugf("Setting user id %v token %v", p1, p2)
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		if err := pathdb.Put[int64](tx, pathUserID, p1, ""); err != nil {
			log.Errorf("Error while setting user id %v", err)
			return err
		}
		userid, err := pathdb.Get[int64](tx, pathUserID)
		if err != nil {
			return err
		}
		log.Debugf("User id %v", userid)
		return pathdb.Put(tx, pathToken, p2, "")
	})
}

func (m *SessionModel) FetchUserData() error {
	m.proClient.UserData(context.Background())
	return m.paymentMethods()
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
	err = session.SetUserIDAndToken(int64(user.UserId), user.Token)
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
	logged, err := session.isUserLoggedIn()
	if err != nil {
		log.Errorf("Error while checking user login status %v", err)
	}
	// This because we do not want to store email in cache when user is logged in
	// Legacy user can overide there new email
	if logged {
		userDetail.Email = ""
	}
	return session.cacheUserDetail(userDetail)
}

func (session *SessionModel) cacheUserDetail(userDetail *protos.User) error {
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

	err = session.SetExpiration(userDetail.Expiration)
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

	/// Check if user has installed app first time
	firstTime, err := checkFirstTimeVisit(session.baseModel)
	if err != nil {
		log.Debugf("Error while checking first time visit %v", err)
	}
	log.Debugf("First time visit %v", firstTime)
	if userDetail.UserLevel == "pro" && firstTime {
		log.Debugf("User is pro and first time")
		session.SetProUser(true)
	} else if userDetail.UserLevel == "pro" && !firstTime && deviceFound {
		log.Debugf("User is pro and not first time")
		session.SetProUser(true)
	} else if userDetail.UserLevel == "pro" {
		log.Debugf("user is pro and device not found")
		session.SetProUser(true)
	} else {
		session.SetProUser(false)
	}

	//Store all device
	err = setDevices(session.baseModel, userDetail.Devices)
	if err != nil {
		return err
	}
	log.Debugf("User caching successful: %+v", userDetail)
	return session.SetUserIDAndToken(int64(userDetail.UserId), userDetail.Token)
}

func collectLogs(path string) error {
	maxLogSize := 10247680
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	folder := "logs"
	if _, err := logging.ZipLogFiles(f, folder, int64(maxLogSize), int64(maxLogSize)); err != nil {
		return err
	}
	return nil
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
	// Check if ads is enable or not
	isPro, err := session.IsProUser()
	if err != nil {
		return err
	}
	if isPro {
		log.Debug("User is pro ads should be disabled")
		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put[string](tx, pathShowAds, "", "")
		})
	}
	// if user is not pro check if user provdied all permission
	hasAllPermisson, err := pathdb.Get[bool](session.db, pathHasAllNetworkPermssion)
	if err != nil {
		return err
	}
	// If the user doesn't have all permissions, disable Google ads:
	if !hasAllPermisson {
		log.Debugf("User has not given all permission")
		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put[string](tx, pathShowAds, "", "")
		})
	}
	// If the user has all permissions but is not a pro user, enable ads:
	interstitialAdsEnable, err := pathdb.Get[bool](session.db, pathShouldShowInterstitialAds)
	if err != nil {
		return err
	}
	if interstitialAdsEnable {
		log.Debug("interstitialAdsEnable Ads is enabled")
		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put[string](tx, pathShowAds, "interstitial", "")
		})
	}
	// If the user has all permissions but is not a pro user, enable ads:
	appOpenAdsEnable, err := pathdb.Get[bool](session.db, pathShouldShowAppOpenAds)
	if err != nil {
		return err
	}
	if appOpenAdsEnable {
		log.Debug("appOpenAdsEnable Ads is enabled")
		return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
			return pathdb.Put[string](tx, pathShowAds, "appOpen", "")
		})
	}
	return nil

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
	return m.SetProUser(true)
}

// Payment Methods

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
	return m.SetProUser(true)
}

func restorePurchase(session *SessionModel, email string, code string, provider string) error {
	deviceName, err := pathdb.Get[string](session.db, pathDevice)
	if err != nil {
		return err
	}

	requData := map[string]interface{}{
		"verified_email":          email,
		"provider":                provider,
		"deviceName":              deviceName,
		"email_verification_code": code,
	}
	okResponse, err := session.proClient.RestorePurchase(context.Background(), requData)
	if err != nil {
		return err
	}
	if okResponse.Status != "ok" {
		return errors.New("error restoring purchase")
	}
	session.SetProUser(true)
	return nil
}

func submitGooglePlayPayment(m *SessionModel, email string, planId string, purchaseToken string) error {
	log.Debugf("Submit Google Pay Payment planId %v purchaseToken %v email %v", planId, purchaseToken, email)
	err, purchaseData := createPurchaseData(m, email, paymentProviderGooglePlay, "", purchaseToken, planId)
	if err != nil {
		log.Errorf("Error while creating  purchase data %v", err)
		return err
	}
	log.Debugf("Purchase data %+v", purchaseData)
	purchase, err := m.proClient.PurchaseRequest(context.Background(), purchaseData)
	if err != nil {
		return err
	}
	if purchase.Status != "ok" {
		return errors.New("Purchase Request failed")
	}
	log.Debugf("Purchase response %v", purchase)

	// Set user to pro
	return m.SetProUser(true)
}

func submitStripePlayPayment(m *SessionModel, email string, planId string, purchaseToken string) error {
	log.Debugf("Submit Stripe Payment planId %v purchaseToken %v email %v", planId, purchaseToken, email)
	err, purchaseData := createPurchaseData(m, email, paymentProviderStripe, "", purchaseToken, planId)
	if err != nil {
		log.Errorf("Error while creating  purchase data %v", err)
		return err
	}
	log.Debugf("Purchase data %+v", purchaseData)
	purchase, err := m.proClient.PurchaseRequest(context.Background(), purchaseData)
	if err != nil {
		return err
	}

	if purchase.Status != "ok" {
		return errors.New("Purchase Request failed")
	}
	log.Debugf("Purchase response %v", purchase)
	// Set user to pro
	return m.SetProUser(true)
}

func (session *SessionModel) applyRefCode(refCode string) error {
	_, err := session.proClient.ReferralAttach(context.Background(), refCode)
	if err != nil {
		return err
	}
	return nil
}

func generatePaymentRedirectUrl(m *SessionModel, email string, planId string, provider string) (string, error) {
	deviceModel, err := pathdb.Get[string](m.db, pathModel)
	if err != nil {
		return "", err
	}

	redirectUrl, err := m.proClient.PaymentRedirect(context.Background(), &protos.PaymentRedirectRequest{
		Plan:       planId,
		Provider:   provider,
		Email:      email,
		DeviceName: deviceModel,
	})
	if err != nil {
		return "", err
	}
	return redirectUrl.Redirect, nil
}

func testProviderRequest(session *SessionModel, email string, paymentProvider string, plan string) error {
	puchaseData := map[string]interface{}{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       paymentProvider,
		"email":          email,
		"plan":           plan,
	}
	_, err := session.proClient.PurchaseRequest(context.Background(), puchaseData)
	if err != nil {
		return err
	}
	return session.SetProUser(true)
}

/// Auth APIS

// Authenticates the user with the given email and password.
//
//	Note-: On Sign up Client needed to generate 16 byte slat
//	Then use that salt, password and email generate encryptedKey once you created encryptedKey pass it to srp.NewSRPClient
//	Then use srpClient.Verifier() to generate verifierKey
func signup(session *SessionModel, email string, password string) error {
	lowerCaseEmail := strings.ToLower(email)
	salt, err := session.authClient.SignUp(email, password)
	if err != nil {
		// log.Errorf("Error while signing up %v", err)
		return err
	}
	//Request successfull then save salt
	dbErr := pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.PutAll(tx, map[string]interface{}{
			pathUserSalt:     salt,
			pathEmailAddress: lowerCaseEmail,
		})
	})
	if dbErr != nil {
		return dbErr
	}
	go session.paymentMethods()
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
	return nil
}

// Todo find way to optimize this method
func login(session *SessionModel, email string, password string) error {
	start := time.Now()
	deviceId, err := session.GetDeviceID()
	if err != nil {
		return err
	}
	login, salt, err := session.authClient.Login(email, password, deviceId)
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
	err = session.cacheUserDetail(userData)
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
	return session.SetUserIDAndToken(login.LegacyID, login.LegacyToken)
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
	// lowerCaseEmail := strings.ToLower(email)
	prepareRequestBody := &protos.ValidateRecoveryCodeRequest{
		Email: email,
		Code:  code,
	}
	recovery, err := session.authClient.ValidateEmailRecoveryCode(context.Background(), prepareRequestBody)
	if err != nil {
		return err
	}
	if !recovery.Valid {
		return log.Errorf("invalid_code Error")
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
	if logoutErr != nil {
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
			pathBandwidth:    nil,
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
			pathEmailAddress: "",
			pathUserID:       0,
			pathProUser:      false,
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
	err = session.SetUserIDAndToken(linkRedeemResponse.UserID, linkRedeemResponse.Token)
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

func userEmailRequest(session *SessionModel, email string) error {
	okResponse, err := session.proClient.EmailRequest(context.Background(), email)
	if err != nil {
		return err
	}
	if okResponse.Status != "ok" {
		return errors.New("Email request failed")
	}
	return nil
}

// Add device for LINK WITH EMAIL method
func requestRecoveryEmail(session *SessionModel, email string) error {
	linkResponse, err := session.proClient.UserLinkCodeRequest(context.Background(), email)
	if err != nil {
		return err
	}
	log.Debugf("requestRecoveryEmail response %v", linkResponse)
	return nil
}

// Validate code for LINK WITH EMAIL method
func validateDeviceRecoveryCode(session *SessionModel, code string) error {
	linkResponse, err := session.proClient.UserLinkValidate(context.Background(), code)
	if err != nil {
		return err
	}
	log.Debugf("ValidateRecovery code response %v", linkResponse)
	err = session.SetUserIDAndToken(linkResponse.UserID, linkResponse.Token)
	if err != nil {
		return err
	}
	pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put[bool](tx, pathIsUserLoggedIn, true, "")
	})
	// Update user detail to reflact on UI
	return session.userDetail(context.Background())
}

//Split Tunneling

func (session *SessionModel) appsAllowedAccess() (string, error) {
	// Get the list of apps that are allowed to access the network.
	installedApps, err := pathdb.List[*protos.AppData](session.db, &pathdb.QueryParams{
		Path: pathAppsData + "%",
	})
	if err != nil {
		return "", err
	}
	var allowedAccess []string
	for _, v := range installedApps {
		if v.Value.AllowedAccess {
			allowedAccess = append(allowedAccess, v.Value.PackageName)
		}
	}
	return strings.Join(allowedAccess, ","), nil
}

// Define the struct to match the JSON structure
type AppInfo struct {
	PackageName string `json:"packageName"`
	Name        string `json:"name"`
	Icon        []int  `json:"icon"`
}

func (session *SessionModel) updateAppsData(filePath string) error {
	// Read the JSON file
	fileContent, err := os.ReadFile(filePath)
	if err != nil {
		log.Debugf("Error opening file: %v", err)
		return err
	}

	log.Debugf("Successfully fileContent %v ", len(fileContent))
	var appsList = &protos.AppsData{}
	parseErr := proto.Unmarshal(fileContent, appsList)
	if parseErr != nil {
		log.Errorf("Error decoding JSON: %v", parseErr)
		return parseErr
	}

	log.Debugf("Successfully loaded %d apps\n", len(appsList.AppsList))

	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		for _, app := range appsList.AppsList {
			path := pathAppsData + app.PackageName
			pathdb.PutIfAbsent(tx, path, app, "")
		}
		return nil
	})
}

func (session *SessionModel) updateAppData(appName string, allowedAccess bool) error {
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		appData, err := pathdb.Get[*protos.AppData](session.db, pathAppsData+appName)
		if err != nil {
			log.Errorf("error getting app data: %v", err)
			return err
		}
		return pathdb.Put[*protos.AppData](tx, pathAppsData+appName, &protos.AppData{
			PackageName:   appData.PackageName,
			Name:          appData.Name,
			Icon:          appData.Icon,
			AllowedAccess: allowedAccess,
		}, "")
	})
}

// Surveys
func (session *SessionModel) getSurvey() (string, error) {
	availableSurvey, err := session.surveyModel.IsSurveyAvalible()
	if err != nil {
		return "", err
	}
	surveyMap := map[string]string{
		"url":     availableSurvey.URL,
		"message": availableSurvey.Message,
		"button":  availableSurvey.Button,
	}
	surveyJSON, err := json.Marshal(surveyMap)
	if err != nil {
		log.Errorf("Error while marshalling survey %v", err)
		return "", err
	}
	return string(surveyJSON), nil
}

func (session *SessionModel) setSurveyLink(surveyLink string) error {
	return pathdb.Mutate(session.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, surveyLink, true, "")
	})
}
func (session *SessionModel) checkIfSurveyLinkOpened(surveyLink string) (bool, error) {
	return pathdb.Get[bool](session.db, surveyLink)

}
