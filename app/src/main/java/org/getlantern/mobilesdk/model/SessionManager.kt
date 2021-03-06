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
import io.lantern.observablemodel.ObservableModel
import io.lantern.observablemodel.Transaction
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.model.Bandwidth
import org.getlantern.lantern.model.Stats
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.Settings
import org.getlantern.mobilesdk.StartResult
import org.greenrobot.eventbus.EventBus
import java.io.File
import java.text.DateFormat
import java.util.*

abstract class SessionManager(application: Application) : Session {
    // The configs in this map will override the configs in BuildConfig
    private val configMap = HashMap<String, Any>()

    // whether or not to configure Lantern to use
    // staging environment
    private var staging = false
    val settings: Settings
    protected val context: Context

    protected val prefsModel = ObservableModel.build(application, File(File(application.filesDir, ".lantern"), "prefsdb").absolutePath, "password") // TODO: make the password random and save it as an encrypted preference
    init {
        prefsModel.registerType(20, PreferencesOuterClass.Preferences::class.java)
    }

    // dynamic settings passed to internal services
    private val internalHeaders: SharedPreferences
    private val appVersion: String
    private var startResult: StartResult? = null
    private var locale: Locale? = null

    protected fun getPrefs(tx: Transaction? = null): PreferencesOuterClass.Preferences {
        val prefs: PreferencesOuterClass.Preferences? = if (tx == null) prefsModel.get(PREF_NAME) else tx.get(PREF_NAME)
        return prefs ?: PreferencesOuterClass.Preferences.getDefaultInstance()
    }

    protected fun updatePrefs(fn: (PreferencesOuterClass.Preferences.Builder) -> Unit): PreferencesOuterClass.Preferences {
        var prefs: PreferencesOuterClass.Preferences? = null
        prefsModel.mutate { tx ->
            prefs = getPrefs(tx)
            val builder = prefs!!.toBuilder()
            fn(builder)
            tx.put(PREF_NAME, builder.build())
        }
        return prefs!!
    }

    fun overrideConfig(configKey: String, configValue: Any) {
        configMap[configKey] = configValue
    }

    fun setStartResult(result: StartResult?) {
        startResult = result
        Logger.debug(TAG, String.format("Lantern successfully started; HTTP proxy address: %s SOCKS proxy address: %s",
                hTTPAddr, sOCKS5Addr))
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
    fun isFrom(c: String?, l: Array<Locale?>): Boolean {
        val locale = Locale(language)
        val country = countryCode
        return country.equals(c, ignoreCase = true) ||
                Arrays.asList(*l).contains(locale)
    }

    val isEnglishUser: Boolean
        get() = isFrom("US", englishLocales)
    val isChineseUser: Boolean
        get() = isFrom("CN", chineseLocales)
    val isIranianUser: Boolean
        get() = isFrom("IR", iranLocale)
    val language: String?
        get() = getPrefs().lang ?: locale.toString()

    override fun getTimeZone(): String {
        return DateFormat.getDateTimeInstance().timeZone.id
    }

    fun setLanguage(locale: Locale?) {
        if (locale != null) {
            doSetLanguage(locale)
            Lingver.getInstance().setLocale(context, locale)
        }
    }

    private fun doSetLanguage(locale: Locale?) {
        if (locale != null) {
            var localeChanged = false
            updatePrefs { prefs ->
                val oldLocale = prefs.lang ?: ""
                prefs.lang = locale.toString()
                localeChanged = locale.toString() != oldLocale
            }
            if (localeChanged) {
                EventBus.getDefault().post(locale)
            }
        }
    }

    fun hasAcceptedTerms(): Boolean {
        return getPrefs().acceptedTermsVersion ?: 0 >= CURRENT_TERMS_VERSION
    }

    fun acceptTerms() {
        updatePrefs { prefs -> prefs.acceptedTermsVersion = CURRENT_TERMS_VERSION }
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
        get() = getPrefs().showAdsAfterDays ?: 0
        set(days) {
            updatePrefs { prefs -> prefs.showAdsAfterDays = days }
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
            val SystemProperties = Class.forName("android.os.SystemProperties")
            val method = SystemProperties.getMethod("get", String::class.java)
            for (name in arrayOf("net.dns1", "net.dns2", "net.dns3", "net.dns4")) {
                val value = method.invoke(null, name) as String
                if (value != null && "" != value) {
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

    override fun isPlayVersion(): Boolean {
        return Utils.isPlayVersion(context)
    }

    override fun proxyAll(): Boolean {
        return getPrefs().proxyAll
    }

    fun setProxyAll(proxyAll: Boolean) {
        updatePrefs { prefs -> prefs.proxyAll = proxyAll }
    }

    val serverCountryCode: String?
        get() = getPrefs().serverCountryCode ?: "N/A"
    val serverCountry: String?
        get() = getPrefs().serverCountry ?: ""
    val serverCity: String?
        get() = getPrefs().serverCity ?: ""

    override fun getCountryCode(): String {
        val forceCountry = forcedCountryCode
        return if (!forceCountry.isEmpty()) {
            forceCountry
        } else getPrefs().geoCountryCode ?: ""
    }

    override fun getForcedCountryCode(): String {
        return BuildConfig.FORCE_COUNTRY.trim { it <= ' ' }
    }

    override fun appVersion(): String {
        return appVersion
    }

    override fun email(): String {
        return getPrefs().emailAddress ?: ""
    }

    fun setEmail(email: String?) {
        updatePrefs { prefs -> prefs.emailAddress = email }
    }

    fun setUserIdAndToken(userId: Int, token: String) {
        if (userId == 0 || TextUtils.isEmpty(token)) {
            Logger.debug(TAG, "Not setting invalid user ID $userId or token $token")
            return
        }
        Logger.debug(TAG, "Setting user ID to $userId, token to $token")
        updatePrefs { prefs -> prefs.userId = userId; prefs.proToken = token }
        FirebaseCrashlytics.getInstance().setUserId(userId.toString())
    }

    private fun setDeviceId(deviceId: String?) {
        updatePrefs { prefs -> prefs.deviceId = deviceId }
    }

    override fun getDeviceID(): String {
        val prefs = updatePrefs { prefs ->
            prefs.deviceId = prefs.deviceId
                    ?: Secure.getString(context.contentResolver, Secure.ANDROID_ID)
        }
        return prefs.deviceId!!
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
        } else getPrefs().userId.toLong()
    }

    override fun getToken(): String {
        return if (isPaymentTestMode) {
            // Auth token corresponding to the specific test user ID
            "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA"
        } else getPrefs().proToken ?: ""
    }

    val isPaymentTestMode: Boolean
        get() = if (configMap.containsKey(CONFIG_PAYMENT_TEST_MODE) && configMap[CONFIG_PAYMENT_TEST_MODE] is Boolean) {
            configMap[CONFIG_PAYMENT_TEST_MODE] as Boolean
        } else BuildConfig.PAYMENT_TEST_MODE

    fun useVpn(): Boolean {
        return getPrefs().useVpn
    }

    fun updateVpnPreference(useVpn: Boolean) {
        updatePrefs { prefs -> prefs.useVpn = useVpn }
    }

    fun clearVpnPreference() {
        updatePrefs { prefs -> prefs.useVpn = false }
    }

    fun bootUpVpn(): Boolean {
        return getPrefs().bootupVpn
    }

    fun updateBootUpVpnPreference(boot: Boolean) {
        updatePrefs { prefs -> prefs.bootupVpn = boot }
    }

    override fun locale(): String {
        return Locale.getDefault().toString()
    }

    fun saveLatestBandwidth(update: Bandwidth) {
        val amount = String.format("%s", update.percent)
        updatePrefs { prefs -> prefs.latestBandwidth = amount }
    }

    fun savedBandwidth(): String? {
        return getPrefs().latestBandwidth ?: "0%"
    }

    override fun bandwidthUpdate(percent: Long, remaining: Long, allowed: Long, ttlSeconds: Long) {
        val b = Bandwidth(percent, remaining, allowed, ttlSeconds)
        saveLatestBandwidth(b)
        EventBus.getDefault().post(b)
    }

    fun setSurveyLinkOpened(url: String?) {
        updatePrefs { prefs -> prefs.putSurveyLinksOpened(url, true) }
    }

    fun surveyLinkOpened(url: String?): Boolean {
        return getPrefs().getSurveyLinksOpenedOrDefault(url, false)
    }

    override fun setStaging(staging: Boolean) {
        this.staging = staging
    }

    fun useStaging(): Boolean {
        return staging
    }

    override fun setCountry(country: String) {
        updatePrefs { prefs -> prefs.geoCountryCode = country }
    }

    override fun updateStats(
            city: String, country: String,
            countryCode: String, httpsUpgrades: Long, adsBlocked: Long,
    ) {
        val st = Stats(city, country, countryCode, httpsUpgrades, adsBlocked)
        EventBus.getDefault().post(st)

        // save last location received
        updatePrefs { prefs ->
            prefs.serverCountry = country
            prefs.serverCity = city
            prefs.serverCountryCode = countryCode
        }
    }

    fun popupAddEligible(): Boolean {
        return System.currentTimeMillis() > getPrefs().popupAdExpiration
    }

    fun setPopupAdExpiration(numSeconds: Int) {
        val currentMilliseconds = System.currentTimeMillis()
        updatePrefs { prefs -> prefs.popupAdExpiration = currentMilliseconds + numSeconds * 1000 }
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
        e.commit()
    }

    // headers serialized as a json encoded string->string map
    override fun serializedInternalHeaders(): String {
        val headers = getInternalHeaders()
        val gson = GsonBuilder().disableHtmlEscaping().create()
        return gson.toJson(headers)
    }

    companion object {
        @JvmStatic
        protected val TAG = SessionManager::class.java.name
        const val CONFIG_PAYMENT_TEST_MODE = "config_payment_test_mode"

        // shared preferences
        protected const val PREF_NAME = "LanternSession"

        protected const val RECENT_INSTALL_THRESHOLD_DAYS: Long = 5
        protected const val CURRENT_TERMS_VERSION = 1
        protected const val INTERNAL_HEADERS_PREF_NAME = "LanternMeta"
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
        appVersion = Utils.appVersion(application)
        context = application
        internalHeaders = context.getSharedPreferences(INTERNAL_HEADERS_PREF_NAME,
                Context.MODE_PRIVATE)
        settings = Settings.init(context)
        val resources = context.resources
        val configuredLocale = getPrefs().lang
        if (!TextUtils.isEmpty(configuredLocale)) {
            Logger.debug(TAG, "Configured locale was %1\$s, setting as default locale", configuredLocale)
            locale = LocaleInfo(context, configuredLocale!!).locale
            Lingver.init(application, locale!!)
        } else {
            locale = Lingver.init(application).getLocale()
            Logger.debug(TAG, "Configured language was empty, using %1\$s", locale)
            doSetLanguage(locale)
        }
    }
}