package org.getlantern.mobilesdk.model

import android.AdSettings
import android.Session
import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.provider.Settings.Secure
import android.text.TextUtils
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.gson.GsonBuilder
import com.yariksoffice.lingver.Lingver
import io.lantern.android.model.BaseModel
import io.lantern.android.model.Vpn
import io.lantern.android.model.VpnModel
import io.lantern.db.DB
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.model.Bandwidth
import org.getlantern.lantern.model.Stats
import org.getlantern.lantern.model.Utils
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.Settings
import org.getlantern.mobilesdk.StartResult
import org.greenrobot.eventbus.EventBus
import java.text.DateFormat
import java.util.Locale
import kotlin.collections.HashMap
import kotlin.collections.Map
import kotlin.collections.MutableMap
import kotlin.collections.component1
import kotlin.collections.component2
import kotlin.collections.iterator
import kotlin.collections.listOf
import kotlin.collections.set

abstract class SessionManager(application: Application) : Session {
    // whether or not to configure Lantern to use
    // staging environment
    private var staging = false
    val settings: Settings
    protected val context: Context
    protected val prefs: SharedPreferences
    val db: DB
    protected val vpnModel: VpnModel

    // dynamic settings passed to internal services
    private val internalHeaders: SharedPreferences
    private val appVersion: String
    private var startResult: StartResult? = null
    private var locale: Locale? = null

    fun setStartResult(result: StartResult?) {
        startResult = result
        Logger.debug(
            TAG,
            String.format(
                "Lantern successfully started; HTTP proxy address: %s SOCKS proxy address: %s",
                hTTPAddr, sOCKS5Addr
            )
        )
    }

    fun lanternDidStart(): Boolean {
        return startResult != null
    }

    val hTTPAddr: String
        get() = if (startResult == null) {
            ""
        } else startResult!!.httpAddr
    val sOCKS5Addr: String
        get() = if (startResult == null) {
            ""
        } else startResult!!.socks5Addr
    val dNSGrabAddr: String
        get() = if (startResult == null) {
            ""
        } else startResult!!.dnsGrabAddr

    /**
     * isFrom checks if a user is from a particular country or region
     * it returns true if the country code matches c or if the default locale
     * is contained in a list of locales
     */
    private fun isFrom(c: String?, l: Array<Locale?>): Boolean {
        val locale = Locale(language)
        val country = countryCode
        return country.equals(c, ignoreCase = true) ||
            listOf(*l).contains(locale)
    }

    val isEnglishUser: Boolean
        get() = isFrom("US", englishLocales)
    val isChineseUser: Boolean
        get() = isFrom("CN", chineseLocales)
    val isIranianUser: Boolean
        get() = isFrom("IR", iranLocale)
    val language: String
        get() = prefs.getString(LANG, locale.toString())!!

    override fun getTimeZone(): String {
        return DateFormat.getDateTimeInstance().timeZone.id
    }

    fun setLanguage(lang: String?) {
        if (lang != null) {
            val locale = LocaleInfo(context, lang).locale
            setLocale(locale)
            Lingver.getInstance().setLocale(context, locale)
        }
    }

    private fun setLocale(locale: Locale?) {
        if (locale != null) {
            val oldLocale = prefs.getString(LANG, "")
            prefs.edit().putString(LANG, locale.toString()).apply()
            if (locale.language != oldLocale) {
                EventBus.getDefault().post(locale)
            }
        }
    }

    fun hasAcceptedTerms(): Boolean {
        return prefs.getInt(ACCEPTED_TERMS_VERSION, 0) >= CURRENT_TERMS_VERSION
    }

    fun acceptTerms() {
        prefs.edit().putInt(ACCEPTED_TERMS_VERSION, CURRENT_TERMS_VERSION).apply()
    }

    override fun deviceOS(): String {
        return String.format("Android-%s", Build.VERSION.RELEASE)
    }

    protected fun launchActivity(c: Class<*>?, clearTop: Boolean) {
        val i = Intent(context, c)
        // close all previous activities
        if (clearTop) {
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        i.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        // start sign in activity
        context.startActivity(i)
    }

    var showAdsAfterDays: Long
        get() = prefs.getLong(SHOW_ADS_AFTER_DAYS, 0L)
        set(days) {
            prefs.edit().putLong(SHOW_ADS_AFTER_DAYS, days).apply()
        }

    /**
     * Returns true if the first installation of the app is within
     * some number of days defined by RECENT_INSTALL_THRESHOLD_DAYS.
     */
    val isRecentInstall: Boolean
        get() {
            val appInstalledDate = Utils.getDateAppInstalled(context)
            val daysSinceAppInstall = Utils.daysSince(appInstalledDate)
            return daysSinceAppInstall <= RECENT_INSTALL_THRESHOLD_DAYS
        }

    override fun updateAdSettings(adSettings: AdSettings) {
        EventBus.getDefault().post(adSettings)
    }

    /**
     * Return the system DNS servers of the current device
     */
    override fun getDNSServer(): String {
        try {
            val systemProperties = Class.forName("android.os.SystemProperties")
            val method = systemProperties.getMethod("get", String::class.java)
            for (name in arrayOf("net.dns1", "net.dns2", "net.dns3", "net.dns4")) {
                val value = method.invoke(null, name) as String
                if ("" != value) {
                    return "[$value]"
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Logger.error(TAG, "Fatal error", e)
        }
        // use the default DNS server from settings.yaml if we were unable to
        // detect the system DNS info
        return settings.defaultDnsServer()
    }

    override fun proxyAll(): Boolean {
        return prefs.getBoolean(PROXY_ALL, false)
    }

    fun setProxyAll(proxyAll: Boolean) {
        prefs.edit().putBoolean(PROXY_ALL, proxyAll).apply()
    }

    val serverCountry: String?
        get() = prefs.getString(SERVER_COUNTRY, "")

    override fun getCountryCode(): String {
        val forceCountry = forcedCountryCode
        return if (forceCountry.isNotEmpty()) {
            forceCountry
        } else prefs.getString(GEO_COUNTRY_CODE, "")!!
    }

    override fun getForcedCountryCode(): String {
        return prefs.getString(FORCE_COUNTRY, "")!!
    }

    fun setForceCountry(countryCode: String) {
        prefs.edit().putString(FORCE_COUNTRY, countryCode).apply()
    }

    override fun appVersion(): String {
        return appVersion
    }

    override fun email(): String {
        return prefs.getString(EMAIL_ADDRESS, "")!!
    }

    fun setEmail(email: String?) {
        prefs.edit().putString(EMAIL_ADDRESS, email).apply()
    }

    fun username(): String {
        return prefs.getString(USERNAME, "")!!
    }

    fun setUsername(username: String?) {
        prefs.edit().putString(USERNAME, username).apply()
    }

    fun setUserIdAndToken(userId: Long, token: String) {
        if (userId == 0L || TextUtils.isEmpty(token)) {
            Logger.debug(TAG, "Not setting invalid user ID $userId or token $token")
            return
        }
        Logger.debug(TAG, "Setting user ID to $userId, token to $token")
        prefs.edit().putLong(USER_ID, userId).putString(TOKEN, token).apply()
        FirebaseCrashlytics.getInstance().setUserId(userId.toString())
    }

    private fun setDeviceId(deviceId: String?) {
        prefs.edit().putString(DEVICE_ID, deviceId).apply()
    }

    override fun getDeviceID(): String {
        var deviceId = prefs.getString(DEVICE_ID, null)
        if (deviceId == null) {
            deviceId = Secure.getString(context.contentResolver, Secure.ANDROID_ID)
            setDeviceId(deviceId)
        }
        return deviceId!!
    }

    fun deviceName(): String {
        return Build.MODEL
    }

    override fun getUserID(): Long {
        return userId()
    }

    fun userId(): Long {
        return if (isPaymentTestMode) {
            // When we're testing payments, use a specific test user ID. This is a user in our
            // production environment but that gets special treatment from the proserver to hit
            // payment providers' test endpoints.
            9007199254740992L
        } else getLong(USER_ID, 0)
    }

    override fun getToken(): String {
        return if (isPaymentTestMode) {
            // Auth token corresponding to the specific test user ID
            "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA"
        } else prefs.getString(TOKEN, "")!!
    }

    private val isPaymentTestMode: Boolean
        get() = prefs.getBoolean(PAYMENT_TEST_MODE, false)

    fun setPaymentTestMode(mode: Boolean) {
        prefs.edit().putBoolean(PAYMENT_TEST_MODE, mode).apply()
    }

    fun updateVpnPreference(useVpn: Boolean) {
        prefs.edit().putBoolean(PREF_USE_VPN, useVpn).apply()
    }

    fun updateBootUpVpnPreference(boot: Boolean) {
        prefs.edit().putBoolean(PREF_BOOTUP_VPN, boot).apply()
    }

    override fun locale(): String {
        return Locale.getDefault().toString()
    }

    private fun saveLatestBandwidth(update: Bandwidth) {
        val amount = String.format("%s", update.percent)
        prefs.edit().putString(LATEST_BANDWIDTH, amount).apply()
        vpnModel.saveBandwidth(
            Vpn.Bandwidth.newBuilder()
                .setPercent(update.percent)
                .setRemaining(update.remaining)
                .setAllowed(update.allowed)
                .setTtlSeconds(update.ttlSeconds)
                .build()
        )
    }

    fun savedBandwidth(): String? {
        return prefs.getString(LATEST_BANDWIDTH, "0%")
    }

    override fun bandwidthUpdate(percent: Long, remaining: Long, allowed: Long, ttlSeconds: Long) {
        val b = Bandwidth(percent, remaining, allowed, ttlSeconds)
        saveLatestBandwidth(b)
        EventBus.getDefault().post(b)
    }

    fun setSurveyLinkOpened(url: String?) {
        prefs.edit().putBoolean(url, true).apply()
    }

    fun surveyLinkOpened(url: String?): Boolean {
        return prefs.getBoolean(url, false)
    }

    override fun setStaging(staging: Boolean) {
        this.staging = staging
    }

    fun useStaging(): Boolean {
        return staging
    }

    override fun setCountry(country: String) {
        prefs.edit().putString(GEO_COUNTRY_CODE, country).apply()
    }

    override fun updateStats(
        city: String,
        country: String,
        countryCode: String,
        httpsUpgrades: Long,
        adsBlocked: Long,
    ) {
        val st = Stats(city, country, countryCode, httpsUpgrades, adsBlocked)
        EventBus.getDefault().post(st)

        // save last location received
        prefs.edit().putString(SERVER_COUNTRY, country)
            .putString(SERVER_CITY, city)
            .putString(SERVER_COUNTRY_CODE, countryCode).apply()
        vpnModel.saveServerInfo(
            Vpn.ServerInfo.newBuilder()
                .setCity(city)
                .setCountry(country)
                .setCountryCode(countryCode)
                .build()
        )
    }

    protected fun getInt(name: String?, defaultValue: Int): Int {
        return try {
            prefs.getInt(name, defaultValue)
        } catch (e: ClassCastException) {
            Logger.error(TAG, e.message)
            try {
                prefs.getLong(name, defaultValue.toLong()).toInt()
            } catch (e2: ClassCastException) {
                Logger.error(TAG, e2.message)
                Integer.valueOf(prefs.getString(name, defaultValue.toString())!!)
            }
        }
    }

    private fun getLong(name: String?, defaultValue: Long): Long {
        return try {
            prefs.getLong(name, defaultValue)
        } catch (e: ClassCastException) {
            Logger.error(TAG, e.message)
            try {
                prefs.getInt(name, defaultValue.toInt()).toLong()
            } catch (e2: ClassCastException) {
                Logger.error(TAG, e2.message)
                prefs.getString(name, defaultValue.toString())?.toLong() ?: 0L
            }
        }
    }

    /**
     * hasPrefExpired checks whether or not a particular
     * shared preference has expired (assuming its stored value
     * is a date in milliseconds plus numDays). If the pref hasn't been seen
     * before, false is returned.
     */
    fun hasPrefExpired(name: String?): Boolean {
        val expires = prefs.getLong(name, 0)
        return System.currentTimeMillis() >= expires
    }

    /**
     * saveExpiringPref is used to store a preference with the given name that
     * expires after numSeconds
     */
    fun saveExpiringPref(name: String?, numSeconds: Int) {
        val currentMilliseconds = System.currentTimeMillis()
        prefs.edit().putLong(name, currentMilliseconds + numSeconds * 1000).apply()
    }

    fun getInternalHeaders(): Map<String, String> {
        val headers: MutableMap<String, String> = HashMap()
        for ((key, value) in internalHeaders.all) {
            headers[key] = value.toString()
        }
        return headers
    }

    fun setInternalHeaders(headers: Map<String?, String?>) {
        val e = internalHeaders.edit()
        e.clear()
        for ((key, value) in headers) {
            e.putString(key, value)
        }
        e.apply()
    }

    // headers serialized as a json encoded string->string map
    override fun serializedInternalHeaders(): String {
        val headers = getInternalHeaders()
        val gson = GsonBuilder().disableHtmlEscaping().create()
        return gson.toJson(headers)
    }

    companion object {
        private val TAG = SessionManager::class.java.name
        private const val PREFERENCES_SCHEMA = "session"

        // shared preferences
        protected const val PREF_NAME = "LanternSession"
        protected const val LATEST_BANDWIDTH = "latest_bandwidth"
        protected const val GEO_COUNTRY_CODE = "geo_country_code"
        protected const val SERVER_COUNTRY = "server_country"
        protected const val SERVER_COUNTRY_CODE = "server_country_code"
        protected const val SERVER_CITY = "server_city"
        protected const val DEVICE_ID = "deviceid"

        @JvmStatic
        val USER_ID = "userid"

        @JvmStatic
        val TOKEN = "token"
        protected const val PROXY_ALL = "proxyAll"
        protected const val LANG = "lang"
        protected const val SHOW_ADS_AFTER_DAYS = "showadsafterdays"

        @JvmStatic
        val EMAIL_ADDRESS = "emailAddress"
        val USERNAME      = "username"
        protected const val PREF_USE_VPN = "pref_vpn"
        protected const val PREF_BOOTUP_VPN = "pref_bootup_vpn"
        protected const val ACCEPTED_TERMS_VERSION = "accepted_terms_version"
        protected const val RECENT_INSTALL_THRESHOLD_DAYS: Long = 5
        protected const val CURRENT_TERMS_VERSION = 1
        protected const val INTERNAL_HEADERS_PREF_NAME = "LanternMeta"

        @JvmStatic
        val YINBI_ENABLED = "yinbienabled"
        protected const val DEVELOPMENT_MODE = "developmentMode"
        private const val PAYMENT_TEST_MODE = "paymentTestMode"
        protected const val FORCE_COUNTRY = "forceCountry"
        @JvmStatic
        val PLAY_VERSION = "playVersion"

        private val chineseLocales = arrayOf<Locale?>(
            Locale("zh", "CN"),
            Locale("zh", "TW")
        )
        private val englishLocales = arrayOf<Locale?>(
            Locale("en", "US"),
            Locale("en", "GB")
        )
        private val iranLocale = arrayOf<Locale?>(
            Locale("fa", "IR")
        )
    }

    init {
        val start = System.currentTimeMillis()
        appVersion = Utils.appVersion(application)
        Logger.debug(TAG, "Utils.appVersion finished at ${System.currentTimeMillis() - start}")
        context = application
        vpnModel = VpnModel()
        Logger.debug(TAG, "VpnModel() finished at ${System.currentTimeMillis() - start}")
        val prefsAdapter = BaseModel.masterDB.asSharedPreferences(
            PREFERENCES_SCHEMA, context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        )
        prefs = prefsAdapter
        prefs.edit().putBoolean(DEVELOPMENT_MODE, BuildConfig.DEVELOPMENT_MODE)
            .putBoolean(PAYMENT_TEST_MODE, prefs.getBoolean(PAYMENT_TEST_MODE, false))
            .putBoolean(PLAY_VERSION, prefs.getBoolean(PLAY_VERSION, false))
            .putBoolean(YINBI_ENABLED, prefs.getBoolean(YINBI_ENABLED, false))
            .putString(FORCE_COUNTRY, prefs.getString(FORCE_COUNTRY, "")).apply()
        db = prefsAdapter.db
        db.registerType(2000, Vpn.Device::class.java)
        db.registerType(2001, Vpn.Devices::class.java)
        Logger.debug(TAG, "prefs.edit() finished at ${System.currentTimeMillis() - start}")
        internalHeaders = context.getSharedPreferences(
            INTERNAL_HEADERS_PREF_NAME,
            Context.MODE_PRIVATE
        )
        settings = Settings.init(context)
        Logger.debug(TAG, "Settings.init() finished at ${System.currentTimeMillis() - start}")
        val configuredLocale = prefs.getString(LANG, null)
        Logger.debug(TAG, "get configuredLocale finished at ${System.currentTimeMillis() - start}")
        if (!TextUtils.isEmpty(configuredLocale)) {
            Logger.debug(
                TAG,
                "Configured locale was %1\$s, setting as default locale",
                configuredLocale
            )
            locale = LocaleInfo(context, configuredLocale!!).locale
            Lingver.init(application, locale!!)
            Logger.debug(TAG, "Lingver.init() finished at ${System.currentTimeMillis() - start}")
        } else {
            locale = Lingver.init(application).getLocale()
            Logger.debug(TAG, "Lingver.init() finished at ${System.currentTimeMillis() - start}")
            Logger.debug(TAG, "Configured language was empty, using %1\$s", locale)
            setLocale(locale)
            Logger.debug(TAG, "doSetLanguage() finished at ${System.currentTimeMillis() - start}")
        }
    }
}
