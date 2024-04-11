package org.getlantern.mobilesdk.model

import android.app.Application
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Proxy
import android.os.Build
import android.provider.Settings.Secure
import android.text.TextUtils
import android.util.ArrayMap
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import com.google.gson.GsonBuilder
import com.yariksoffice.lingver.Lingver
import internalsdk.AdSettings
import internalsdk.Session
import io.lantern.db.DB
import io.lantern.model.BaseModel
import io.lantern.model.Vpn
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.Bandwidth
import org.getlantern.lantern.model.Stats
import org.getlantern.lantern.model.Utils
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.Settings
import org.getlantern.mobilesdk.StartResult
import org.getlantern.mobilesdk.util.DnsDetector
import org.getlantern.mobilesdk.util.LanguageHelper
import org.greenrobot.eventbus.EventBus
import java.io.PrintWriter
import java.io.StringWriter
import java.lang.reflect.InvocationTargetException
import java.text.DateFormat
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.collections.component1
import kotlin.collections.component2
import kotlin.collections.set

abstract class SessionManager(application: Application) : Session {
    // whether or not to configure Lantern to use
    // staging environment
    private var staging = false
    val settings: Settings
    protected val context: Context
    protected val prefs: SharedPreferences
    val db: DB

    // dynamic settings passed to internal services
    private val internalHeaders: SharedPreferences
    private val appVersion: String
    private var startResult: StartResult? = null
    private var locale: Locale? = null
    val dnsDetector = DnsDetector(application, fakeDnsIP)

    fun setStartResult(result: StartResult?) {
        startResult = result
        setWebViewProxy()

        Logger.debug(
            TAG,
            String.format(
                "Lantern successfully started; HTTP proxy address: %s SOCKS proxy address: %s",
                hTTPAddr,
                sOCKS5Addr,
            ),
        )
    }

    fun lanternDidStart(): Boolean {
        return startResult != null
    }

    val hTTPAddr: String
        get() = if (startResult == null) {
            ""
        } else {
            startResult!!.httpAddr
        }
    val sOCKS5Addr: String
        get() = if (startResult == null) {
            ""
        } else {
            startResult!!.socks5Addr
        }
    val dNSGrabAddr: String
        get() = if (startResult == null) {
            ""
        } else {
            startResult!!.dnsGrabAddr
        }

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
    val isRussianUser: Boolean
        get() = isFrom("RU", russianLocale)
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
        return dnsDetector.dnsServer
    }

    override fun splitTunnelingEnabled(): Boolean {
        return prefs.getBoolean(SPLIT_TUNNELING, false)
    }

    val serverCountry: String?
        get() = prefs.getString(SERVER_COUNTRY, "")

    val ipAddress: String?
        get() = prefs.getString(IP_ADDRESS, "")

    override fun getCountryCode(): String {
        val forceCountry = forcedCountryCode
        return if (forceCountry.isNotEmpty()) {
            forceCountry
        } else {
            prefs.getString(GEO_COUNTRY_CODE, "")!!
        }
    }

    override fun getForcedCountryCode(): String {
        return prefs.getString(FORCE_COUNTRY, "")!!
    }

    fun setForceCountry(countryCode: String) {
        prefs.edit().putString(FORCE_COUNTRY, countryCode).apply()
    }

    override fun forceReplica(): Boolean {
        return prefs.getBoolean("DEVELOPMENT_MODE", BuildConfig.DEVELOPMENT_MODE)
    }

    val replicaAddr: String
        get() = prefs.getString(REPLICA_ADDR, "")!!

    override fun setReplicaAddr(replicaAddr: String?) {
        Logger.d(TAG, "Setting $REPLICA_ADDR to $replicaAddr")
        prefs.edit().putString(REPLICA_ADDR, replicaAddr ?: "").apply()
    }

    override fun setChatEnabled(enabled: Boolean) {
//        val isDevMode = prefs.getBoolean("DEVELOPMENT_MODE", BuildConfig.DEVELOPMENT_MODE)
//        val actuallyEnabled = enabled || isDevMode
        Logger.d(TAG, "Setting $CHAT_ENABLED to $enabled")
        prefs.edit().putBoolean(CHAT_ENABLED, enabled).apply()
    }

    override fun setShowInterstitialAdsEnabled(enabled: Boolean) {
        Logger.d(TAG, "Setting $ADS_ENABLED to $enabled")
        prefs.edit().putBoolean(ADS_ENABLED, enabled).apply()
    }

    fun shouldShowAdsEnabled(): Boolean {
        return prefs.getBoolean(ADS_ENABLED, false)
    }

    fun chatEnabled(): Boolean = prefs.getBoolean(CHAT_ENABLED, false)

    fun appVersion(): String {
        return appVersion
    }

    override fun email(): String {
        return prefs.getString(EMAIL_ADDRESS, "")!!
    }

    fun setEmail(email: String?) {
        prefs.edit().putString(EMAIL_ADDRESS, email).apply()
    }

    fun setUserIdAndToken(userId: Long, token: String?) {
        if (userId == 0L) {
            Logger.debug(TAG, "Not setting invalid user ID $userId")
            return
        }
        Logger.debug(TAG, "Setting user ID to $userId")
        prefs.edit().putLong(USER_ID, userId).apply()
        if (token != null && !TextUtils.isEmpty(token)) {
            Logger.debug(TAG, "Setting token to $token")
            prefs.edit().putString(TOKEN, token).apply()
        }
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
        } else {
            prefs.getLong(USER_ID, 0)
        }
    }

    override fun getToken(): String {
        return if (isPaymentTestMode) {
            // Auth token corresponding to the specific test user ID
            "OyzvkVvXk7OgOQcx-aZpK5uXx6gQl5i8BnOuUkc0fKpEZW6tc8uUvA"
        } else {
            prefs.getString(TOKEN, "")!!
        }
    }

    val isPaymentTestMode: Boolean
        get() {
            val paymentTestMode = prefs.getBoolean(PAYMENT_TEST_MODE, false)
            val ciValue = BuildConfig.FLAVOR == "appiumTest"
            return ciValue || paymentTestMode
        }

    fun setPaymentTestMode(mode: Boolean) {
        prefs.edit().putBoolean(PAYMENT_TEST_MODE, mode).apply()
    }

    fun updateVpnPreference(useVpn: Boolean) {
        prefs.edit().putBoolean(PREF_USE_VPN, useVpn).apply()
    }

    fun updateBootUpVpnPreference(boot: Boolean) {
        prefs.edit().putBoolean(PREF_BOOTUP_VPN, boot).apply()
    }

    override fun getAppName(): String {
        return "Lantern"
    }

    override fun locale(): String {
        return language
    }

    private fun saveLatestBandwidth(update: Bandwidth) {
        val amount = String.format("%s", update.percent)
        prefs.edit().putString(LATEST_BANDWIDTH, amount).apply()
    }

    fun savedBandwidth(): String? {
        return prefs.getString(LATEST_BANDWIDTH, "0%")
    }

    override fun bandwidthUpdate(percent: Long, remaining: Long, allowed: Long, ttlSeconds: Long) {
        val b = Bandwidth(percent, remaining, allowed, ttlSeconds)
        Logger.debug("bandwidth", b.toString())
        saveLatestBandwidth(b)
        EventBus.getDefault().postSticky(b)
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

    override fun setIP(ipAddress: String) {
        prefs.edit().putString(IP_ADDRESS, ipAddress).apply()
    }

    override fun setCountry(country: String) {
        prefs.edit().putString(GEO_COUNTRY_CODE, country).apply()
    }

    private val hasUpdatedStats = AtomicBoolean()

    override fun updateStats(
        city: String,
        country: String,
        countryCode: String,
        httpsUpgrades: Long,
        adsBlocked: Long,
        hasSucceedingProxy: Boolean,
    ) {
        Logger.debug("updateStats", "city $city, country $country, countryCode $countryCode")
        if (hasUpdatedStats.compareAndSet(false, true)) {
            // The first time that we get the stats, hasSucceedingProxy is always false because we
            // haven't hit any proxies yet. So, we just ignore the stats.
            return
        }

        val st = Stats(city, country, countryCode, httpsUpgrades, adsBlocked, hasSucceedingProxy)
        EventBus.getDefault().postSticky(st)

        // save last location received
        prefs.edit().putString(SERVER_COUNTRY, country)
            .putString(SERVER_CITY, city)
            .putString(SERVER_COUNTRY_CODE, countryCode)
            .putBoolean(HAS_SUCCEEDING_PROXY, hasSucceedingProxy).apply()
    }

    fun resetHasSucceedingProxy() {
        prefs.edit().remove(HAS_SUCCEEDING_PROXY).apply()
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

    /**this preference is used for checking we want to show ads or not
     * we are only after first session
     */
    fun setHasFirstSessionCompleted(status: Boolean) {
        prefs.edit().putBoolean(HAS_FIRST_SESSION_COMPLETED, status).apply()
    }

    fun hasFirstSessionCompleted(): Boolean {
        return prefs.getBoolean(HAS_FIRST_SESSION_COMPLETED, false)
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

    // isPlayVersion checks whether or not the user installed Lantern via the Google Play store
    override fun isStoreVersion(): Boolean {
        if (BuildConfig.PLAY_VERSION || prefs.getBoolean(PLAY_VERSION, false)) {
            return true
        }
        try {
            val validInstallers: List<String> = ArrayList(
                listOf(
                    "com.android.vending",
                    "com.google.android.feedback"
                )
            )
            val installer = context.packageManager
                .getInstallerPackageName(context.packageName)
            return installer != null && validInstallers.contains(installer)
        } catch (e: java.lang.Exception) {
            Logger.error(TAG, "Error fetching package information: " + e.message)
        }
        return false
    }

    companion object {
        private val TAG = SessionManager::class.java.name
        const val PREFERENCES_SCHEMA = "session"

        // shared preferences
        protected const val PREF_NAME = "LanternSession"
        protected const val LATEST_BANDWIDTH = "latest_bandwidth"
        protected const val GEO_COUNTRY_CODE = "geo_country_code"
        protected const val IP_ADDRESS = "ip_address"
        protected const val SERVER_COUNTRY = "server_country"
        protected const val SERVER_COUNTRY_CODE = "server_country_code"
        protected const val SERVER_CITY = "server_city"
        protected const val HAS_SUCCEEDING_PROXY = "hasSucceedingProxy"
        protected const val HAS_FIRST_SESSION_COMPLETED = "hasFirstSessionCompleted"
        protected const val DEVICE_ID = "deviceid"

        @JvmStatic
        val fakeDnsIP = "1.1.1.1"

        @JvmStatic
        val USER_ID = "userid"

        @JvmStatic
        val TOKEN = "token"
        protected const val SPLIT_TUNNELING = "splitTunneling"
        protected const val LANG = "lang"
        protected const val SHOW_ADS_AFTER_DAYS = "showadsafterdays"

        @JvmStatic
        val EMAIL_ADDRESS = "emailAddress"
        protected const val PREF_USE_VPN = "pref_vpn"
        protected const val PREF_BOOTUP_VPN = "pref_bootup_vpn"
        protected const val ACCEPTED_TERMS_VERSION = "accepted_terms_version"
        protected const val RECENT_INSTALL_THRESHOLD_DAYS: Long = 5
        protected const val CURRENT_TERMS_VERSION = 1
        protected const val INTERNAL_HEADERS_PREF_NAME = "LanternMeta"

        protected const val DEVELOPMENT_MODE = "developmentMode"
        private const val PAYMENT_TEST_MODE = "paymentTestMode"
        protected const val FORCE_COUNTRY = "forceCountry"

        @JvmStatic
        val PLAY_VERSION = "playVersion"

        private const val REPLICA_ADDR = "replicaAddr"
        const val CHAT_ENABLED = "chatEnabled"
        const val ADS_ENABLED = "adsEnabled"
        const val CAS_ADS_ENABLED = "casAsEnabled"

        private val chineseLocales = arrayOf<Locale?>(
            Locale("zh", "CN"),
            Locale("zh", "TW"),
        )
        private val englishLocales = arrayOf<Locale?>(
            Locale("en", "US"),
            Locale("en", "GB"),
        )
        private val iranLocale = arrayOf<Locale?>(
            Locale("fa", "IR"),
        )
        private val russianLocale = arrayOf<Locale?>(
            Locale("ru", "RU"),
        )
    }

    init {
        val start = System.currentTimeMillis()
        appVersion = Utils.appVersion(application)
        Logger.debug(TAG, "Utils.appVersion finished at ${System.currentTimeMillis() - start}")
        context = application
        db = BaseModel.masterDB.withSchema(PREFERENCES_SCHEMA)
        db.registerType(2000, Vpn.Device::class.java)
        db.registerType(2001, Vpn.Devices::class.java)
        db.registerType(2002, Vpn.Plan::class.java)
        db.registerType(2004, Vpn.PaymentProviders::class.java)
        db.registerType(2005, Vpn.PaymentMethod::class.java)
        db.registerType(2006, Vpn.AppData::class.java)
        db.registerType(2007, Vpn.ServerInfo::class.java)

        Logger.debug(TAG, "register types finished at ${System.currentTimeMillis() - start}")
        var prefsAdapter:SharedPreferences
        try {
            prefsAdapter = db.asSharedPreferences(
                context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE),
            )
        } catch (e:java.lang.reflect.InvocationTargetException) {
            // Handles InvocationTargetException exception that occurs because the Plans protobuf message changed
            // and can be fixed by clearing pre-existing plans
            db.mutate { tx ->
                tx.listPaths("/plans/%").forEach { tx.delete(it) }
            }
            prefsAdapter = db.asSharedPreferences(
                context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE),
            )
        }
        prefs = prefsAdapter
        prefs.edit().putBoolean(DEVELOPMENT_MODE, BuildConfig.DEVELOPMENT_MODE)
            .putBoolean(PAYMENT_TEST_MODE, prefs.getBoolean(PAYMENT_TEST_MODE, false))
            .putBoolean(PLAY_VERSION, isStoreVersion())
            .putString(FORCE_COUNTRY, prefs.getString(FORCE_COUNTRY, "")).apply()

        // initialize email address to empty string (if it doesn't already exist)
        if (email().isEmpty()) setEmail("")

        // this condition is unnecessary
        // Todo remove this soon
        if (prefs.getInt(ACCEPTED_TERMS_VERSION, 0) == 0) prefs.edit()
            .putInt(ACCEPTED_TERMS_VERSION, 0).apply()

        Logger.debug(TAG, "prefs.edit() finished at ${System.currentTimeMillis() - start}")
        internalHeaders = context.getSharedPreferences(
            INTERNAL_HEADERS_PREF_NAME,
            Context.MODE_PRIVATE,
        )
        settings = Settings.init(context)
        Logger.debug(TAG, "Settings.init() finished at ${System.currentTimeMillis() - start}")
        val configuredLocale = prefs.getString(LANG, null)
        Logger.debug(TAG, "get configuredLocale finished at ${System.currentTimeMillis() - start}")
        if (!TextUtils.isEmpty(configuredLocale)) {
            Logger.debug(
                TAG,
                "Configured locale was %1\$s, setting as default locale",
                configuredLocale,
            )
            locale = LocaleInfo(context, configuredLocale!!).locale
            Lingver.init(application, locale!!)
            Logger.debug(TAG, "Lingver.init() finished at ${System.currentTimeMillis() - start}")
        } else {
            locale = Lingver.init(application).getLocale()
            // Here check if we support device language localization
            // if not then set default language to English
            locale =
                if (LanguageHelper.supportLanguages.contains("${locale!!.language}_${locale!!.country}")) {
                    locale
                } else {
                    // Default language is English
                    Locale("en", "US")
                }
            Logger.debug(TAG, "Lingver.init() finished at ${System.currentTimeMillis() - start}")
            Logger.debug(TAG, "Configured language was empty, using %1\$s", locale)
            setLocale(locale)
            Logger.debug(TAG, "doSetLanguage() finished at ${System.currentTimeMillis() - start}")
        }
    }

    private fun setWebViewProxy() {
        // We set ourselves as the WebView proxy if and only if WebViewFeature.PROXY_OVERRIDE
        // is supported.
        if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
            val proxyConfig = ProxyConfig.Builder()
                .addProxyRule("http://${LanternApp.getSession().hTTPAddr}")
                .build()
            ProxyController.getInstance().setProxyOverride(
                proxyConfig,
                ContextCompat.getMainExecutor(context),
            ) {}
        } else {
            // Below code based on suggestion here - https://stackoverflow.com/a/18453384
            try {
                val appContext = context.applicationContext
                val addressParts = LanternApp.getSession().hTTPAddr.split(":")
                val host = addressParts[0]
                val port = addressParts[1]
                System.setProperty("http.proxyHost", host)
                System.setProperty("http.proxyPort", port)
                System.setProperty("https.proxyHost", host)
                System.setProperty("https.proxyPort", port)
                val applicationClass = LanternApp::class.java
                val loadedApkField = applicationClass.getField("mLoadedApk")
                loadedApkField.isAccessible = true
                val loadedApk: Any = loadedApkField.get(appContext)
                val loadedApkCls = Class.forName("android.app.LoadedApk")
                val receiversField = loadedApkCls.getDeclaredField("mReceivers")
                receiversField.isAccessible = true
                val receivers =
                    receiversField.get(loadedApk) as ArrayMap<Context, ArrayMap<BroadcastReceiver, Any>>
                for (receiverMap in receivers.values) {
                    for (rec in (receiverMap as ArrayMap).keys) {
                        val clazz: Class<*> = rec.javaClass
                        if (clazz.name.contains("ProxyChangeListener")) {
                            val onReceiveMethod = clazz.getDeclaredMethod(
                                "onReceive",
                                Context::class.java,
                                Intent::class.java,
                            )
                            val intent = Intent(Proxy.PROXY_CHANGE_ACTION)
                            onReceiveMethod.invoke(rec, appContext, intent)
                        }
                    }
                }
                Log.d(TAG, "Setting proxy with >= 4.4 API successful!")
            } catch (e: ClassNotFoundException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: NoSuchFieldException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: IllegalAccessException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: IllegalArgumentException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: NoSuchMethodException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: InvocationTargetException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            }
        }
    }
}
