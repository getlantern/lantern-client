package org.getlantern.lantern.model;

import android.AdSettings;
import android.Session;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.provider.Settings.Secure;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.firebase.crashlytics.FirebaseCrashlytics;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.AddDeviceActivity;
import org.getlantern.lantern.activity.LanternPlansActivity;
import org.getlantern.lantern.activity.WelcomeActivity_;
import org.getlantern.lantern.activity.yinbi.YinbiPlansActivity;
import org.getlantern.lantern.activity.yinbi.YinbiRenewActivity;
import org.getlantern.lantern.activity.yinbi.YinbiWelcomeActivity_;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;
import org.getlantern.mobilesdk.model.LocaleInfo;
import org.greenrobot.eventbus.EventBus;
import org.joda.time.LocalDateTime;

import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Currency;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class SessionManager implements Session {

    private static final String TAG = SessionManager.class.getName();
    // shared preferences
    private static final String PREF_NAME = "LanternSession";
    private static final String DEVICE_LINKED = "DeviceLinked";
    private static final String REFERRAL_CODE = "referral";
    private static final String LATEST_BANDWIDTH = "latest_bandwidth";
    private static final String GEO_COUNTRY_CODE = "geo_country_code";
    private static final String SERVER_COUNTRY = "server_country";
    private static final String SERVER_COUNTRY_CODE = "server_country_code";
    private static final String SERVER_CITY = "server_city";
    private static final String DEVICE_ID = "deviceid";
    private static final String IS_BOOT_UP = "isbootup";
    private static final String PW_SIGNATURE = "pwsignature";
    private static final String DEVICE_LINKING_CODE = "devicelinkingcode";
    private static final String DEVICE_CODE_EXP = "devicecodeexp";
    private static final String USER_ID = "userid";
    private static final String YINBI_ENABLED = "yinbienabled";
    private static final String YINBI_USER_ID = "yinbiuserid";
    private static final String YINBI_THANKS_PURCHASE = "showyinbithankspurchase";
    private static final String SHOW_YINBI_REDEMPTION = "showyinbiredemption";
    private static final String PRO_USER = "prouser";
    private static final String PRO_EXPIRED = "proexpired";
    private static final String REMOTE_CONFIG_PAYMENT_PROVIDER = "remoteConfigPaymentProvider";
    private static final String USER_PAYMENT_GATEWAY = "userPaymentGateway";
    private static final String PROXY_ALL = "proxyAll";
    private static final String PRO_PLAN = "proplan";
    private static final String LANG = "lang";
    private static final String SHOW_RENEWAL_PREF = "renewalpref";
    private static final String SHOW_ADS_AFTER_DAYS = "showadsafterdays";
    private static final String WELCOME_LAST_SEEN = "welcomeseen";
    private static final String RENEWAL_LAST_SEEN = "renewalseen";
    private static final String EMAIL_ADDRESS = "emailAddress";
    private static final String RESELLER_CODE = "resellercode";
    private static final String PROVIDER = "provider";
    private static final String ACCOUNT_ID = "accountid";
    private static final String EXPIRY_DATE = "expirydate";
    private static final String PRO_MONTHS_LEFT = "promonthsleft";
    private static final String PRO_DAYS_LEFT = "prodaysleft";
    private static final String EXPIRY_DATE_STR = "expirydatestr";
    private static final String STRIPE_TOKEN = "stripe_token";
    private static final String STRIPE_API_KEY = "stripe_api_key";
    private static final String TOKEN = "token";
    private static final String PREF_USE_VPN = "pref_vpn";
    private static final String PREF_BOOTUP_VPN = "pref_bootup_vpn";
    private static final String DEFAULT_CURRENCY_CODE = "usd";
    private static final String ACCEPTED_TERMS_VERSION = "accepted_terms_version";

    private static final long DEFAULT_ONE_YEAR_COST = 3200;
    private static final long DEFAULT_TWO_YEAR_COST = 4800;
    private static final long RECENT_INSTALL_THRESHOLD_DAYS = 5;

    private static final int CURRENT_TERMS_VERSION = 1;

    private static final String INTERNAL_HEADERS_PREF_NAME = "LanternMeta";

    // whether or not to configure Lantern to use
    // staging environment
    private boolean staging = false;

    @NonNull
    private final Settings settings;

    @NonNull
    private final Context context;

    @NonNull
    private final SharedPreferences prefs;

    @NonNull
    private final Editor editor;

    // dynamic settings passed to internal services
    @NonNull
    private final SharedPreferences internalHeaders;

    @NonNull
    private final String appVersion;

    private ProPlan selectedPlan;

    // the devices associated with a user's Pro account
    private Map<String, Device> devices = new HashMap<String, Device>();

    private static final Locale enLocale = new Locale("en", "US");
    private static final Locale[] chineseLocales = {
        new Locale("zh", "CN"),
        new Locale("zh", "TW")
    };
    private static final Locale[] englishLocales = {
        new Locale("en", "US"),
        new Locale("en", "GB")
    };
    private static final Locale[] iranLocale = {
        new Locale("fa", "IR")
    };

    private StartResult startResult = null;
    private String referral;
    private String verifyCode;
    private Locale locale;

    public SessionManager(Context context) {

        this.appVersion = Utils.appVersion(context);
        this.context = context;
        this.prefs = context.getSharedPreferences(PREF_NAME,
                Context.MODE_PRIVATE);
        this.editor = prefs.edit();

        this.internalHeaders = context.getSharedPreferences(INTERNAL_HEADERS_PREF_NAME,
                Context.MODE_PRIVATE);
        this.settings = Settings.init(context);

        final Resources resources = context.getResources();
        String configuredLocale = prefs.getString(LANG, null);
        if (!TextUtils.isEmpty(configuredLocale)) {
            Logger.debug(TAG, "Configured locale was %1$s, setting as default locale", configuredLocale);
            this.locale = new LocaleInfo(context, configuredLocale).getLocale();
            updateLocale(locale);
        } else {
            if (resources != null && resources.getConfiguration() != null) {
                this.locale = resources.getConfiguration().locale;
            } else {
                this.locale = Locale.getDefault();
            }
            Logger.debug(TAG, "Configured language was empty, using %1$s", locale);
            setLanguage(locale);
        }
    }

    public Settings getSettings() {
        return settings;
    }

    public void setStartResult(final StartResult result) {
        this.startResult = result;
        Logger.debug(TAG, String.format("Lantern successfully started; HTTP proxy address: %s SOCKS proxy address: %s",
                this.getHTTPAddr(), this.getSOCKS5Addr()));
    }

    public boolean lanternDidStart() {
        return startResult != null;
    }

    public String getHTTPAddr() {
        if (startResult == null) {
            return "";
        }
        return startResult.getHttpAddr();
    }

    public String getSOCKS5Addr() {
        if (startResult == null) {
            return "";
        }
        return startResult.getSocks5Addr();
    }

    public String getDNSGrabAddr() {
        if (startResult == null) {
            return "";
        }
        return startResult.getDnsGrabAddr();
    }

    /**
     * isFrom checks if a user is from a particular country or region
     * it returns true if the country code matches c or if the default locale
     * is contained in a list of locales
     */
    public boolean isFrom(final String c, final Locale[] l) {
        final Locale locale = new Locale(getLanguage());
        final String country = getCountryCode();
        return country.equalsIgnoreCase(c) ||
            Arrays.asList(l).contains(locale);
    }

    public boolean isEnglishUser() {
        return isFrom("US", englishLocales);
    }

    public boolean isChineseUser() {
        return isFrom("CN", chineseLocales);
    }

    public boolean isIranianUser() {
        return isFrom("IR", iranLocale);
    }

    public String getLanguage() {
        return prefs.getString(LANG, locale.toString());
    }

    public void setLanguage(final Locale locale) {
        if (locale != null) {
            String oldLocale = prefs.getString(LANG, "");
            editor.putString(LANG, locale.toString()).commit();
            updateLocale(locale);
            if (!locale.equals(oldLocale)) {
                EventBus.getDefault().post(locale);
            }
        }
    }

    private void updateLocale(final Locale locale) {
        Logger.debug(TAG, "Updating locale to %1$s", locale);
        Configuration config = new Configuration(context.getResources().getConfiguration());
        Locale.setDefault(locale);
        config.setLocale(locale);
        context.getResources().updateConfiguration(config, context.getResources().getDisplayMetrics());
    }

    public boolean hasAcceptedTerms() {
        return prefs.getInt(ACCEPTED_TERMS_VERSION, 0) >= CURRENT_TERMS_VERSION;
    }

    public void acceptTerms() {
        editor.putInt(ACCEPTED_TERMS_VERSION, CURRENT_TERMS_VERSION).commit();
    }

    public Currency getCurrency() {
        try {
            final String lang = getLanguage();
            final String[] parts = lang.split("_");
            if (parts.length > 0) {
                return Currency.getInstance(new Locale(parts[0], parts[1]));
            }
            return Currency.getInstance(Locale.getDefault());
        } catch (Exception e) {
            Logger.error(TAG, e.getMessage());
        }
        return Currency.getInstance("USD");
    }

    /**
     * When Stripe Checkout is used, this determines whether or not Bitcoin
     * should be enabled. Currently only enabled for Iranian users.
     */
    public boolean useBitcoin() {
        return isIranianUser();
    }

    /**
     * When Stripe Checkout is used, this determines whether or not Alipay
     * should be enabled. Currently only enabled for Chinese users.
     */
    public boolean useAlipay() {
        return isChineseUser();
    }

    private boolean isDeviceLinked() {
        return prefs.getBoolean(DEVICE_LINKED, false);
    }

    public boolean isProUser() {
        return prefs.getBoolean(PRO_USER, false);
    }

    public boolean isExpired() {
        return prefs.getBoolean(PRO_EXPIRED, false);
    }

    public String currency() {
        ProPlan plan = getSelectedPlan();
        if (plan != null) {
            return plan.getCurrency();
        }
        return DEFAULT_CURRENCY_CODE;
    }

    public String deviceOS() {
        return String.format("Android-%s", android.os.Build.VERSION.RELEASE);
    }

    private void launchActivity(Class c, boolean clearTop) {
        Intent i = new Intent(this.context, c);
        // close all previous activities
        if (clearTop) {
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        }
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        // start sign in activity
        this.context.startActivity(i);
    }

    public ProPlan getSelectedPlan() {
        Logger.debug(TAG, "Current plan is " + selectedPlan);
        return selectedPlan;
    }

    public long getSelectedPlanCost() {
        ProPlan plan = getSelectedPlan();
        if (plan != null) {
            Long price = plan.getCurrencyPrice();
            if (price != null) {
                return price.longValue();
            }
        }
        return DEFAULT_ONE_YEAR_COST;
    }

    public String[] getReferralArray(Resources res) {
        ProPlan plan = getSelectedPlan();
        if (plan == null) {
            Logger.debug(TAG, "Selected plan is null. Returning default referral instructions");
            return res.getStringArray(R.array.referral_promotion_list);
        }
        if (plan.numYears() == 1) {
            return res.getStringArray(R.array.referral_promotion_list);
        } else {
            return res.getStringArray(R.array.referral_promotion_list_two_year);
        }
    }

    public String getSelectedPlanCurrency() {
        ProPlan plan = getSelectedPlan();
        if (plan != null) {
            return plan.getCurrency();
        }
        return "usd";
    }

    public boolean defaultToAlipay() {
        // Currently we default to Alipay for Yuan purchases
        return "cny".equals(getSelectedPlanCurrency());
    }

    public long getShowAdsAfterDays() {
        return prefs.getLong(SHOW_ADS_AFTER_DAYS, 0L);
    }

    public void setShowAdsAfterDays(long days) {
        editor.putLong(SHOW_ADS_AFTER_DAYS, days).commit();
    }

    /**
     * Returns true if the first installation of the app is within
     * some number of days defined by RECENT_INSTALL_THRESHOLD_DAYS.
     */
    public boolean isRecentInstall() {
        final Date appInstalledDate = Utils.getDateAppInstalled(context);
        final long daysSinceAppInstall = Utils.daysSince(appInstalledDate);
        return daysSinceAppInstall <= RECENT_INSTALL_THRESHOLD_DAYS;
    }

    public void updateAdSettings(final AdSettings adSettings) {
        EventBus.getDefault().post(adSettings);
    }

    public void setRemoteConfigPaymentProvider(final String provider) {
        editor.putString(REMOTE_CONFIG_PAYMENT_PROVIDER, provider).commit();
    }

    public String getRemoteConfigPaymentProvider() {
        return prefs.getString(REMOTE_CONFIG_PAYMENT_PROVIDER, "");
    }

    public void setPaymentProvider(final String provider) {
        editor.putString(USER_PAYMENT_GATEWAY, provider).commit();
    }

    public String getPaymentProvider() {
        return prefs.getString(USER_PAYMENT_GATEWAY, "paymentwall");
    }

    public void setSignature(String sig) {
        editor.putString(PW_SIGNATURE, sig).commit();
    }

    public String getPwSignature() {
        return prefs.getString(PW_SIGNATURE, "");
    }

    public void addDevice(final Device device) {
        devices.put(device.getId(), device);
    }

    public void removeDevice(String id) {
        devices.remove(id);
    }

    public Map<String, Device> getDevices() {
        return devices;
    }

    public void setStripePubKey(final String key) {
        editor.putString(STRIPE_API_KEY, key).commit();
    }

    public String stripePubKey() {
        return prefs.getString(STRIPE_API_KEY, "");
    }

    public void setIsBootUp(final boolean isBootUp) {
        editor.putBoolean(IS_BOOT_UP, isBootUp).commit();
    }

    public boolean isBootUp() {
        return prefs.getBoolean(IS_BOOT_UP, false);
    }

    public Class<?> plansActivity() {
        if (!isPlayVersion() && yinbiEnabled()) {
            if (isProUser()) {
                return YinbiRenewActivity.class;
            } else {
                return YinbiPlansActivity.class;
            }
        } else {
            return LanternPlansActivity.class;
        }
    }

    public Class<?> welcomeActivity() {
        if (yinbiEnabled()) {
            return YinbiWelcomeActivity_.class;
        } else {
            return WelcomeActivity_.class;
        }
    }

    /**
     * Return the system DNS servers of the current device
     */
    public String getDNSServer() {
        try {
            Class<?> SystemProperties = Class.forName("android.os.SystemProperties");
            Method method = SystemProperties.getMethod("get", String.class);

            for (String name : new String[]{"net.dns1", "net.dns2", "net.dns3", "net.dns4",}) {
                String value = (String) method.invoke(null, name);
                if (value != null && !"".equals(value)) {
                    return "[" + value + "]";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            Logger.error(TAG, "Fatal error", e);
        }
        // use the default DNS server from settings.yaml if we were unable to
        // detect the system DNS info
        return settings.defaultDnsServer();
    }

    public boolean isPlayVersion() {
        return Utils.isPlayVersion(context);
    }

    public boolean deviceLinked() {
        if (!this.isDeviceLinked()) {
            launchActivity(AddDeviceActivity.class, false);
            return false;
        }
        return true;
    }

    public void setVerifyCode(String code) {
        Logger.debug(TAG, "Verify code set to " + code);
        this.verifyCode = code;
    }

    public String verifyCode() {
        return this.verifyCode;
    }

    public boolean proxyAll() {
        return prefs.getBoolean(PROXY_ALL, false);
    }

    public void setProxyAll(boolean proxyAll) {
        editor.putBoolean(PROXY_ALL, proxyAll).commit();
    }

    public void setDeviceCode(String code, long expiration) {
        editor.putLong(DEVICE_CODE_EXP, expiration * 1000).commit();
        editor.putString(DEVICE_LINKING_CODE, code).commit();
    }

    public String deviceCode() {
        return prefs.getString(DEVICE_LINKING_CODE, "");
    }

    public String getServerCountryCode() {
        return prefs.getString(SERVER_COUNTRY_CODE, "N/A");
    }

    public String getServerCountry() {
        return prefs.getString(SERVER_COUNTRY, "");
    }

    public String getServerCity() {
        return prefs.getString(SERVER_CITY, "");
    }

    public String getCountryCode() {
        String forceCountry = getForcedCountryCode();
        if (!forceCountry.isEmpty()) {
            return forceCountry;
        }
        return prefs.getString(GEO_COUNTRY_CODE, "");
    }

    public String getForcedCountryCode() {
        return BuildConfig.FORCE_COUNTRY.trim();
    }

    public Long getDeviceExp() {
        return prefs.getLong(DEVICE_CODE_EXP, 0);
    }

    public void storeUserData(final ProUser user) {
        setUserIdAndToken(user.getUserId(), user.getToken());

        if (user.getEmail() != null && !user.getEmail().equals("")) {
            setEmail(user.getEmail());
        }

        setYinbiEnabled(user.getYinbiEnabled());

        if (!TextUtils.isEmpty(user.getCode())) {
            setCode(user.getCode());
        }

        if (user.isActive()) {
            linkDevice();
            setShowRedemptionTable(true);
        } else if (isProUser()) {
            setShowRedemptionTable(true);
        }

        setExpiration(user.getExpiration());
        setExpired(user.isExpired());
        setIsProUser(user.isProUser());

        if (user.isProUser()) {
            EventBus.getDefault().post(new UserStatus(user.isActive(), user.monthsLeft()));
            editor.putInt(PRO_MONTHS_LEFT, user.monthsLeft()).commit();
            editor.putInt(PRO_DAYS_LEFT, user.daysLeft()).commit();
        }
    }

    public boolean yinbiEnabled() {
        return BuildConfig.YINBI_ENABLED || prefs.getBoolean(YINBI_ENABLED, false);
    }

    public void setYinbiEnabled(final boolean enabled) {
        editor.putBoolean(YINBI_ENABLED, enabled).commit();
    }

    public boolean showYinbiThanksPurchase() {
        return prefs.getBoolean(YINBI_THANKS_PURCHASE, false);
    }

    public void setThanksPurchase(final boolean v) {
        editor.putBoolean(YINBI_THANKS_PURCHASE, v).commit();
    }

    public boolean showYinbiRedemptionTable() {
        return prefs.getBoolean(SHOW_YINBI_REDEMPTION, false);
    }

    public void setShowRedemptionTable(final boolean v) {
        editor.putBoolean(SHOW_YINBI_REDEMPTION, v).commit();
    }

    public Integer getProDaysLeft() {
        return getInt(PRO_DAYS_LEFT, 0);
    }

    private void setExpiration(final Long expiration) {
        if (expiration == null) {
            return;
        }
        Date expiry = new Date(expiration * 1000);
        SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");
        String dateToStr = dateFormat.format(expiry);
        Logger.debug(TAG, "Lantern pro expiration date: " + dateToStr);
        editor.putLong(EXPIRY_DATE, expiration);
        editor.putString(EXPIRY_DATE_STR, dateToStr).commit();
    }

    public LocalDateTime getExpiration() {
        final long expiration = prefs.getLong(EXPIRY_DATE, 0L);
        if (expiration == 0L) {
            return null;
        }
        return new LocalDateTime(expiration * 1000);
    }

    public String getExpirationStr() {
        return prefs.getString(EXPIRY_DATE_STR, "");
    }

    /**
     * hasPrefExpired checks whether or not a particular
     * shared preference has expired (assuming its stored value
     * is a date in milliseconds plus numDays). If the pref hasn't been seen
     * before, false is returned.
     */
    public boolean hasPrefExpired(final String name) {
        final long expires = prefs.getLong(name, 0);
        return System.currentTimeMillis() >= expires;
    }

    /**
     * saveExpiringPref is used to store a preference with the given name that
     * expires after numSeconds
    */
    public void saveExpiringPref(final String name, final Integer numSeconds) {
        final long currentMilliseconds = System.currentTimeMillis();
        editor.putLong(name, currentMilliseconds + numSeconds * 1000).commit();
    }

    public boolean showWelcomeScreen() {
        if (isExpired()) {
            return showRenewalPref();
        }
        if (isProUser()) {
            final Integer daysLeft = getProDaysLeft();
            if (daysLeft == null) {
                return false;
            }
            return daysLeft < 45 && showRenewalPref();
        }

        // Show only once to free users. (If set, don't show)
        // Also, if the install isn't new-ish, we won't start showing them a welcome.
        return isRecentInstall() && prefs.getLong(WELCOME_LAST_SEEN, 0) == 0;
    }

    public String getProTimeLeft() {
        final int numMonths = numProMonths();
        if (numMonths < 1) {
            final int numDays = getInt(PRO_DAYS_LEFT, 0);
            if (numDays == 0) {
                return "";
            }
            return String.format("%dD", numDays);
        }
        return String.format("%dMO",
                numMonths);
    }

    public int numProMonths() {
        return getInt(PRO_MONTHS_LEFT, 0);
    }

    public void setWelcomeLastSeen() {
        final String name = isProUser() ?
            RENEWAL_LAST_SEEN : WELCOME_LAST_SEEN;
        editor.putLong(name, System.currentTimeMillis()).commit();
    }

    public void setRenewalPref(final boolean dontShow) {
        editor.putBoolean(SHOW_RENEWAL_PREF, dontShow).commit();
    }

    public boolean showRenewalPref() {
        return prefs.getBoolean(SHOW_RENEWAL_PREF, true);
    }

    public void proUserStatus(String status) {
        if (status.equals("active")) {
            editor.putBoolean(PRO_USER, true).commit();
        }
    }

    public void setProPlan(final ProPlan plan) {
        this.selectedPlan = plan;
    }

    public void setIsProUser(boolean isProUser) {
        editor.putBoolean(PRO_USER, isProUser).commit();
    }

    public void setExpired(boolean expired) {
        editor.putBoolean(PRO_EXPIRED, expired).commit();
    }

    public void setEmail(String email) {
        editor.putString(EMAIL_ADDRESS, email).commit();
    }

    public void setResellerCode(String code) {
        editor.putString(RESELLER_CODE, code).commit();
    }

    public void setProvider(String provider) {
        editor.putString(PROVIDER, provider).commit();
    }

    public void setAccountId(String accountId) {
        editor.putString(ACCOUNT_ID, accountId).commit();
    }

    public String accountId() {
        return prefs.getString(ACCOUNT_ID, "");
    }

    public void setCode(String referral) {
        editor.putString(REFERRAL_CODE, referral).commit();
    }

    public String appVersion() {
        return appVersion;
    }

    public void setStripeToken(final String token) {
        editor.putString(STRIPE_TOKEN, token).commit();
    }

    public String stripeToken() {
        return prefs.getString(STRIPE_TOKEN, "");
    }

    public String email() {
        return prefs.getString(EMAIL_ADDRESS, "");
    }

    public String resellerCode() {
        return prefs.getString(RESELLER_CODE, "");
    }

    public String provider() {
        return prefs.getString(PROVIDER, "");
    }

    public void setUserIdAndToken(final Integer userId, final String token) {
        if (userId == 0 || TextUtils.isEmpty(token)) {
            Logger.debug(TAG, "Not setting invalid user ID " + userId + " or token " + token);
            return;
        }
        Logger.debug(TAG, "Setting user ID to " + userId + ", token to " + token);
        editor.putInt(USER_ID, userId).putString(TOKEN, token).commit();
        FirebaseCrashlytics.getInstance().setUserId(String.valueOf(userId));
    }

    private void setDeviceId(String deviceId) {
        editor.putString(DEVICE_ID, deviceId).commit();
    }

    public String getDeviceID() {
        String deviceId = prefs.getString(DEVICE_ID, null);
        if (deviceId == null) {
            deviceId = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);
            setDeviceId(deviceId);
        }
        return deviceId;
    }

    public String deviceName() {
        return android.os.Build.MODEL;
    }

    public String code() {
        return prefs.getString(REFERRAL_CODE, "");
    }

    public long getUserID() {
        return userId().longValue();
    }

    public Long userId() {
        if (isPaymentTestMode()) {
            // When we're testing payments, use a specific test user ID. This is a user in our
            // production environment but that gets special treatment from the proserver to hit
            // payment providers' test endpoints.
            return 9007199254740992l;
        }
        return new Long(getInt(USER_ID, 0));
    }

    public String getToken() {
        if (isPaymentTestMode()) {
            // Auth token corresponding to the specific test user ID
            return "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA";
        }
        return prefs.getString(TOKEN, "");
    }

    public boolean isPaymentTestMode() {
        return BuildConfig.PAYMENT_TEST_MODE;
    }

    public boolean useVpn() {
        return prefs.getBoolean(PREF_USE_VPN, false);
    }

    public void updateVpnPreference(boolean useVpn) {
        editor.putBoolean(PREF_USE_VPN, useVpn).commit();
    }

    public void clearVpnPreference() {
        editor.putBoolean(PREF_USE_VPN, false).commit();
    }

    public boolean bootUpVpn() {
        return prefs.getBoolean(PREF_BOOTUP_VPN, false);
    }

    public void updateBootUpVpnPreference(boolean boot) {
        editor.putBoolean(PREF_BOOTUP_VPN, boot).commit();
    }

    public void setReferral(String referralCode) {
        this.referral = referralCode;
    }

    public String referral() {
        return referral;
    }

    public String locale() {
        return Locale.getDefault().toString();
    }

    public void unlinkDevice(boolean newUser) {
        devices.clear();

        setIsProUser(false);
        editor.putBoolean(PRO_USER, false);
        editor.putBoolean(DEVICE_LINKED, false);
        editor.remove(TOKEN);
        editor.remove(EMAIL_ADDRESS);
        editor.remove(USER_ID);
        editor.remove(DEVICE_CODE_EXP);
        editor.remove(DEVICE_LINKING_CODE);
        editor.remove(PRO_PLAN);
        editor.commit();
    }

    public void linkDevice() {
        editor.putBoolean(DEVICE_LINKED, true);
        editor.commit();
    }

    public void saveLatestBandwidth(Bandwidth update) {
        String amount = String.format("%s", update.getPercent());
        editor.putString(LATEST_BANDWIDTH, amount).commit();
    }

    public String savedBandwidth() {
        return prefs.getString(LATEST_BANDWIDTH, "0%");
    }

    public void bandwidthUpdate(long percent, long remaining, long allowed) {
        final Bandwidth b = new Bandwidth(percent, remaining, allowed);
        saveLatestBandwidth(b);
        EventBus.getDefault().post(b);
    }

    public void setSurveyLinkOpened(String url) {
        editor.putBoolean(url, true).commit();
    }

    public boolean surveyLinkOpened(final String url) {
        return prefs.getBoolean(url, false);
    }

    public void setStaging(boolean staging) {
        this.staging = staging;
    }

    public boolean useStaging() {
        return staging;
    }

    public void setCountry(String country) {
        editor.putString(GEO_COUNTRY_CODE, country).commit();
    }

    public void updateStats(String city, String country,
            String countryCode, long httpsUpgrades, long adsBlocked) {

        final Stats st = new Stats(city, country, countryCode, httpsUpgrades, adsBlocked);
        EventBus.getDefault().post(st);

        // save last location received
        editor.putString(SERVER_COUNTRY, country).commit();
        editor.putString(SERVER_CITY, city).commit();
        editor.putString(SERVER_COUNTRY_CODE, countryCode).commit();
    }

    private int getInt(String name, int defaultValue) {
        try {
            return prefs.getInt(name, defaultValue);
        } catch (ClassCastException e) {
            Logger.error(TAG, e.getMessage());
            try {
                return (int) prefs.getLong(name, (long) defaultValue);
            } catch (ClassCastException e2) {
                Logger.error(TAG, e2.getMessage());
                return Integer.valueOf(prefs.getString(name, String.valueOf(defaultValue)));
            }
        }
    }

    public Map<String, String> getInternalHeaders() {
        Map<String,String> headers = new HashMap<>();
        for (Map.Entry<String, ?> header : internalHeaders.getAll().entrySet()) {
            headers.put(header.getKey(), String.valueOf(header.getValue()));
        }
        return headers;
    }

    public void setInternalHeaders(final Map<String, String> headers) {
        Editor e = internalHeaders.edit();
        e.clear();
        for (Map.Entry<String, String> header : headers.entrySet()) {
            e.putString(header.getKey(), header.getValue());
        }
        e.commit();
    }

    // headers serialized as a json encoded string->string map
    public String serializedInternalHeaders() {
        Map<String, String> headers = getInternalHeaders();
        Gson gson = new GsonBuilder().disableHtmlEscaping().create();
        return gson.toJson(headers);
    }
}
