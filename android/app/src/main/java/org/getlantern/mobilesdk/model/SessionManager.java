package org.getlantern.mobilesdk.model;

import android.AdSettings;
import android.Session;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Resources;
import android.provider.Settings.Secure;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.firebase.crashlytics.FirebaseCrashlytics;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.yariksoffice.lingver.Lingver;

import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.model.Bandwidth;
import org.getlantern.lantern.model.Stats;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;
import org.greenrobot.eventbus.EventBus;

import java.lang.reflect.Method;
import java.text.DateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public abstract class SessionManager implements Session {

    protected static final String TAG = SessionManager.class.getName();

    public static final String CONFIG_PAYMENT_TEST_MODE = "config_payment_test_mode";

    // The configs in this map will override the configs in BuildConfig
    private final HashMap<String, Object> configMap = new HashMap<>();

    // shared preferences
    protected static final String PREF_NAME = "LanternSession";
    protected static final String LATEST_BANDWIDTH = "latest_bandwidth";
    protected static final String GEO_COUNTRY_CODE = "geo_country_code";
    protected static final String SERVER_COUNTRY = "server_country";
    protected static final String SERVER_COUNTRY_CODE = "server_country_code";
    protected static final String SERVER_CITY = "server_city";
    protected static final String DEVICE_ID = "deviceid";
    protected static final String USER_ID = "userid";
    protected static final String TOKEN = "token";
    protected static final String PROXY_ALL = "proxyAll";
    protected static final String LANG = "lang";
    protected static final String SHOW_ADS_AFTER_DAYS = "showadsafterdays";
    protected static final String EMAIL_ADDRESS = "emailAddress";
    protected static final String PREF_USE_VPN = "pref_vpn";
    protected static final String PREF_BOOTUP_VPN = "pref_bootup_vpn";
    protected static final String ACCEPTED_TERMS_VERSION = "accepted_terms_version";

    protected static final long RECENT_INSTALL_THRESHOLD_DAYS = 5;

    protected static final int CURRENT_TERMS_VERSION = 1;

    protected static final String INTERNAL_HEADERS_PREF_NAME = "LanternMeta";

    // whether or not to configure Lantern to use
    // staging environment
    private boolean staging = false;

    @NonNull
    private final Settings settings;

    @NonNull
    protected final Context context;

    @NonNull
    protected final SharedPreferences prefs;

    @NonNull
    protected final Editor editor;

    // dynamic settings passed to internal services
    @NonNull
    private final SharedPreferences internalHeaders;

    @NonNull
    private final String appVersion;

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
    private Locale locale;

    public SessionManager(Application application) {

        this.appVersion = Utils.appVersion(application);
        this.context = application;
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
            Lingver.init(application, locale);
        } else {
            this.locale = Lingver.init(application).getLocale();
            Logger.debug(TAG, "Configured language was empty, using %1$s", locale);
            doSetLanguage(locale);
        }
    }

    public void overrideConfig(String configKey, Object configValue) {
        configMap.put(configKey, configValue);
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

    public String getTimeZone() {
        return DateFormat.getDateTimeInstance().getTimeZone().getID();
    }

    public void setLanguage(final Locale locale) {
        if (locale != null) {
            doSetLanguage(locale);
            Lingver.getInstance().setLocale(context, locale);
        }
    }

    private void doSetLanguage(final Locale locale) {
        if (locale != null) {
            String oldLocale = prefs.getString(LANG, "");
            editor.putString(LANG, locale.toString()).commit();
            if (!locale.equals(oldLocale)) {
                EventBus.getDefault().post(locale);
            }
        }
    }

    public boolean hasAcceptedTerms() {
        return prefs.getInt(ACCEPTED_TERMS_VERSION, 0) >= CURRENT_TERMS_VERSION;
    }

    public void acceptTerms() {
        editor.putInt(ACCEPTED_TERMS_VERSION, CURRENT_TERMS_VERSION).commit();
    }

    public String deviceOS() {
        return String.format("Android-%s", android.os.Build.VERSION.RELEASE);
    }

    protected void launchActivity(Class c, boolean clearTop) {
        Intent i = new Intent(this.context, c);
        // close all previous activities
        if (clearTop) {
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        }
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        // start sign in activity
        this.context.startActivity(i);
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

    public boolean proxyAll() {
        return prefs.getBoolean(PROXY_ALL, false);
    }

    public void setProxyAll(boolean proxyAll) {
        editor.putBoolean(PROXY_ALL, proxyAll).commit();
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

    public String appVersion() {
        return appVersion;
    }

    public String email() {
        return prefs.getString(EMAIL_ADDRESS, "");
    }

    public void setEmail(String email) {
        editor.putString(EMAIL_ADDRESS, email).commit();
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
        if (configMap.containsKey(CONFIG_PAYMENT_TEST_MODE) && configMap.get(CONFIG_PAYMENT_TEST_MODE) instanceof Boolean) {
            return (Boolean) configMap.get(CONFIG_PAYMENT_TEST_MODE);
        }
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

    public String locale() {
        return Locale.getDefault().toString();
    }

    public void saveLatestBandwidth(Bandwidth update) {
        String amount = String.format("%s", update.getPercent());
        editor.putString(LATEST_BANDWIDTH, amount).commit();
    }

    public String savedBandwidth() {
        return prefs.getString(LATEST_BANDWIDTH, "0%");
    }

    public void bandwidthUpdate(long percent, long remaining, long allowed, long ttlSeconds) {
        final Bandwidth b = new Bandwidth(percent, remaining, allowed, ttlSeconds);
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

    protected int getInt(String name, int defaultValue) {
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
