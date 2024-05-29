package org.getlantern.lantern.model

import android.app.Application
import android.content.Context
import android.content.res.Resources
import android.os.Build
import io.lantern.model.Vpn
import org.getlantern.lantern.util.PlansUtil
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.SessionManager
import org.greenrobot.eventbus.EventBus
import org.joda.time.LocalDateTime
import java.text.SimpleDateFormat
import java.util.Currency
import java.util.Date
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

class LanternSessionManager(application: Application) : SessionManager(application) {
    private var plans: ConcurrentHashMap<String, ProPlan> = ConcurrentHashMap<String, ProPlan>()

    private var referral: String? = null
    private var verifyCode: String? = null
    private var supportedCurrencyList: List<String> = listOf()

    override fun isProUser(): Boolean {
        return prefs.getBoolean(PRO_USER, false)
    }

    fun getUserLevel(): String? {
        return prefs.getString(USER_LEVEL, "")
    }

    fun setUserLevel(userLevel: String?) {
        prefs.edit().putString(USER_LEVEL, userLevel).apply()
    }

    fun isExpired(): Boolean {
        return prefs.getBoolean(PRO_EXPIRED, false)
    }

    private fun getCurrency(): Currency {
        try {
            val lang = language
            val parts = lang.split("_".toRegex()).toTypedArray()
            return if (parts.isNotEmpty()) {
                Currency.getInstance(Locale(parts[0], parts[1]))
            } else {
                Currency.getInstance(Locale.getDefault())
            }
        } catch (e: Exception) {
            Logger.error(TAG, e.message)
        }
        return Currency.getInstance("USD")
    }

    override fun currency(): String {
        return getCurrency().currencyCode ?: "usd"
    }

    fun deviceCurrencyCode(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val localList = Resources.getSystem().configuration.locales
            for (i in 0 until localList.size()) {
                val locale = localList.get(i)
                val tempLocal = Currency.getInstance(locale).currencyCode.lowercase()
                return if (supportedCurrencyList.contains(tempLocal)) {
                    tempLocal
                } else {
                    "usd"
                }
            }
            "usd" // Default to "usd" if no supported currency found
        } else {
            val local = Resources.getSystem().configuration.locale
            val deviceLocal = Currency.getInstance(local).currencyCode.lowercase()

            return if (supportedCurrencyList.contains(deviceLocal)) {
                deviceLocal
            } else {
                "usd"
            }
        }
    }

    fun setCurrencyList(currencyList: List<String>) {
        supportedCurrencyList = currencyList
    }

    fun getCurrencyList(): List<String> {
        return supportedCurrencyList
    }

    fun setRemoteConfigPaymentProvider(provider: String?) {
        prefs.edit().putString(REMOTE_CONFIG_PAYMENT_PROVIDER, provider).apply()
    }

    fun getRemoteConfigPaymentProvider(): String? {
        return prefs.getString(REMOTE_CONFIG_PAYMENT_PROVIDER, "")
    }

    fun setPaymentProvider(provider: String?) {
        prefs.edit().putString(USER_PAYMENT_GATEWAY, provider).apply()
    }

    fun getPaymentProvider(): String? {
        return prefs.getString(USER_PAYMENT_GATEWAY, "stripe")
    }

    fun setSignature(sig: String?) {
        prefs.edit().putString(PW_SIGNATURE, sig).apply()
    }

    fun getPwSignature(): String? {
        return prefs.getString(PW_SIGNATURE, "")
    }

    fun setStripePubKey(key: String?) {
        prefs.edit().putString(STRIPE_API_KEY, key).apply()
    }

    fun stripePubKey(): String? {
        return prefs.getString(STRIPE_API_KEY, "")
    }

    fun setVerifyCode(code: String) {
        Logger.debug(TAG, "Verify code set to $code")
        verifyCode = code
    }

    fun verifyCode(): String? {
        return verifyCode
    }

    fun setDeviceCode(code: String?, expiration: Long) {
        prefs.edit().putLong(DEVICE_CODE_EXP, expiration * 1000)
            .putString(DEVICE_LINKING_CODE, code)
            .apply()
    }

    fun deviceCode(): String? {
        return prefs.getString(DEVICE_LINKING_CODE, "")
    }

    fun deviceID(): String? {
        return prefs.getString(DEVICE_ID, "")
    }

    fun userID(): Long {
        return prefs.getLong(USER_ID, 0)
    }

    fun getDeviceExp(): Long {
        return prefs.getLong(DEVICE_CODE_EXP, 0)
    }

    fun getProDaysLeft(): Int {
        return prefs.getInt(PRO_DAYS_LEFT, 0)
    }

    private fun setExpiration(expiration: Long?) {
        if (expiration == null || expiration == 0L) {
            prefs.edit().putLong(EXPIRY_DATE, 0)
                .putString(EXPIRY_DATE_STR, "")
                .apply()
            return
        }
        val expiry = Date(expiration * 1000)
        val dateFormat = SimpleDateFormat("MM/dd/yyyy")
        val dateToStr = dateFormat.format(expiry)
        Logger.debug(TAG, "Lantern pro expiration date: $dateToStr")
        prefs.edit().putLong(EXPIRY_DATE, expiration)
            .putString(EXPIRY_DATE_STR, dateToStr)
            .apply()
    }

    fun getExpiration(): LocalDateTime? {
        val expiration = prefs.getLong(EXPIRY_DATE, 0L)
        return if (expiration == 0L) {
            null
        } else {
            LocalDateTime(expiration * 1000)
        }
    }

    fun showWelcomeScreen(): Boolean {
        if (isExpired()) {
            return showRenewalPref()
        }
        if (isProUser) {
            val daysLeft = getProDaysLeft()
            return daysLeft < 45 && showRenewalPref()
        }

        // Show only once to free users. (If set, don't show)
        // Also, if the install isn't new-ish, we won't start showing them a welcome.
        return isRecentInstall && prefs.getLong(WELCOME_LAST_SEEN, 0) == 0L
    }

    fun numProMonths(): Int {
        return prefs.getInt(PRO_MONTHS_LEFT, 0)
    }

    fun setWelcomeLastSeen() {
        val name = if (isProUser) RENEWAL_LAST_SEEN else WELCOME_LAST_SEEN
        prefs.edit().putLong(name, System.currentTimeMillis()).apply()
    }

    fun setRenewalPref(dontShow: Boolean) {
        prefs.edit().putBoolean(SHOW_RENEWAL_PREF, dontShow).apply()
    }

    fun showRenewalPref(): Boolean {
        return prefs.getBoolean(SHOW_RENEWAL_PREF, true)
    }

    // appsAllowedAccess returns a list of package names for those applications that are allowed
    // to access the VPN connection. If split tunneling is enabled, and any app is added to
    // the list, only those applications (and no others) are allowed access.
    fun appsAllowedAccess(): List<String> {
        var installedApps = db.list<Vpn.AppData>(PATH_APPS_DATA + "%")
        val apps = mutableListOf<String>()
        for (appData in installedApps) {
            if (appData.value.allowedAccess) apps.add(appData.value.packageName)
        }
        return apps
    }

    override fun splitTunnelingEnabled(): Boolean {
        return prefs.getBoolean(SPLIT_TUNNELING, false)
    }

    fun setIsProUser(isProUser: Boolean) {
        prefs.edit().putBoolean(PRO_USER, isProUser).apply()
    }

    fun setExpired(expired: Boolean) {
        prefs.edit().putBoolean(PRO_EXPIRED, expired).apply()
    }

    fun setResellerCode(code: String?) {
        prefs.edit().putString(RESELLER_CODE, code).apply()
    }

    fun setProvider(provider: String?) {
        prefs.edit().putString(PROVIDER, provider).apply()
    }

    override fun code(): String? {
        return prefs.getString(REFERRAL_CODE, "")
    }

    fun setCode(referral: String?) {
        prefs.edit().putString(REFERRAL_CODE, referral).apply()
    }


    fun resellerCode(): String? {
        return prefs.getString(RESELLER_CODE, "")
    }

    override fun provider(): String? {
        return prefs.getString(PROVIDER, "")
    }

    fun setReferral(referralCode: String?) {
        referral = referralCode
    }

    fun referral(): String? {
        return referral
    }

    fun logout() {
        prefs.edit().putBoolean(PRO_USER, false)
            .putBoolean(DEVICE_LINKED, false)
            .remove(DEVICES)
            .remove(PLANS)
            .remove(TOKEN)
            .remove(EMAIL_ADDRESS)
            .remove(USER_ID)
            .remove(DEVICE_CODE_EXP)
            .remove(DEVICE_LINKING_CODE)
            .remove(PRO_PLAN)
            .apply()
    }

    fun linkDevice() {
        prefs.edit().putBoolean(DEVICE_LINKED, true).apply()
    }

    fun storeUserData(user: ProUser) {
        Logger.debug(TAG, "Storing user data $user")
        if (!user.email.isNullOrEmpty()) {
            setEmail(user.email)
        }

        if (!user.code.isNullOrEmpty()) {
            setCode(user.code)
        }

        if (user.isActive) {
            linkDevice()
        }

        setExpiration(user.expiration)
        setExpired(user.isExpired)
        setIsProUser(user.isProUser)

        val devices = Vpn.Devices.newBuilder().addAllDevices(
            user.devices.map {
                Vpn.Device.newBuilder().setId(it.id)
                    .setName(it.name).setCreated(it.created).build()
            },
        ).build()
        db.mutate { tx ->
            tx.put(DEVICES, devices)
        }

        if (user.isProUser) {
            EventBus.getDefault().post(UserStatus(user.isActive, user.monthsLeft().toLong()))
            prefs.edit().putInt(PRO_MONTHS_LEFT, user.monthsLeft())
                .putInt(PRO_DAYS_LEFT, user.daysLeft())
                .apply()
        }
    }

    fun planByID(planID: String): ProPlan? {
        for (plan in plans.values) {
            if (plan.id == planID) return plan
        }
        return null
    }

    fun setUserPlans(context: Context, proPlans: Map<String, ProPlan>) {
        for (planId in proPlans.keys) {
            proPlans[planId]?.let { PlansUtil.updatePrice(context, it) }
        }

        plans.clear()
        plans.putAll(proPlans)
        db.mutate { tx ->
            proPlans.values.forEach {
                try {
                    val planID = it.id.substringBefore('-')
                    val path = PLANS + planID

                    val planItem = Vpn.Plan.newBuilder().setId(it.id)
                        .setDescription(it.description).setBestValue(it.bestValue)
                        .putAllPrice(it.price).setTotalCostBilledOneTime(it.totalCostBilledOneTime)
                        .setOneMonthCost(it.oneMonthCost)
                        .setTotalCost(it.totalCost).setFormattedBonus(it.formattedBonus)
                        .setRenewalText(it.renewalText).build()

                    tx.put(
                        path,
                        planItem,
                    )
                } catch (e: Exception) {
                    Logger.error(TAG, e.message)
                }
            }
        }
    }

    fun setPaymentMethods(paymentMethods: List<PaymentMethods>) {
        if (paymentMethods.isEmpty()) {
            return
        }

        db.mutate { tx ->
            paymentMethods.forEachIndexed { index, methods ->
                // Check if payment method or  provider is empty then return
                if (methods.providers.isEmpty()) {
                    return@forEachIndexed
                }

                val path = PAYMENT_METHODS + index
                val planItem =
                    Vpn.PaymentMethod.newBuilder().setMethod(methods.method.toString().lowercase())
                        .addAllProviders(
                            methods.providers.map {
                                // Check if payment provider is stipe add pubkey
                                if (it.name == PaymentProvider.Stripe) {
                                    setStripePubKey(it.data["pubKey"] as String)
                                }
                                Vpn.PaymentProviders.newBuilder()
                                    .setName(it.name.toString().lowercase())
                                    .addAllLogoUrls(it.logoUrl)
                                    .build()
                            },
                        ).build()

                tx.put(
                    path,
                    planItem,
                )
            }
        }
    }

    fun setStoreVersion(storeVersion: Boolean) {
        prefs.edit().putBoolean(PLAY_VERSION, storeVersion).apply()
    }

    companion object {
        private val TAG = LanternSessionManager::class.java.name

        // shared preferences
        private const val USER_LEVEL = "userLevel"
        private const val PRO_USER = "prouser"
        private const val DEVICES = "devices"
        private const val PATH_APPS_DATA = "/appsData/"
        private const val SPLIT_TUNNELING = "/splitTunneling"
        private const val PLANS = "/plans/"
        private const val PAYMENT_METHODS = "/paymentMethods/"
        private const val PRO_EXPIRED = "proexpired"
        private const val PRO_PLAN = "proplan"
        private const val SHOW_RENEWAL_PREF = "renewalpref"
        private const val EXPIRY_DATE = "expirydate"
        private const val PRO_MONTHS_LEFT = "promonthsleft"
        private const val PRO_DAYS_LEFT = "prodaysleft"
        private const val EXPIRY_DATE_STR = "expirydatestr"
        private const val STRIPE_API_KEY = "stripe_api_key"
        private const val DEFAULT_CURRENCY_CODE = "usd"
        private const val DEVICE_LINKED = "DeviceLinked"
        private const val DEVICE_ID = "deviceid"
        private const val USER_ID = "userid"
        private const val REFERRAL_CODE = "referral"
        private const val PW_SIGNATURE = "pwsignature"
        private const val DEVICE_LINKING_CODE = "devicelinkingcode"
        private const val DEVICE_CODE_EXP = "devicecodeexp"
        private const val REMOTE_CONFIG_PAYMENT_PROVIDER = "remoteConfigPaymentProvider"
        private const val USER_PAYMENT_GATEWAY = "userPaymentGateway"
        private const val WELCOME_LAST_SEEN = "welcomeseen"
        private const val RENEWAL_LAST_SEEN = "renewalseen"
        private const val PROVIDER = "provider"
        private const val RESELLER_CODE = "resellercode"

        // other constants
        private const val DEFAULT_ONE_YEAR_COST: Long = 3200
    }
}
