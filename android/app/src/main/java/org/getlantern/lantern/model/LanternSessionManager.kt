package org.getlantern.lantern.model

import android.app.Application
import android.content.res.Resources
import android.text.TextUtils
import io.lantern.android.model.Vpn
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.PlansActivity_
import org.getlantern.lantern.activity.WelcomeActivity_
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.SessionManager
import org.greenrobot.eventbus.EventBus
import org.joda.time.LocalDateTime
import java.text.SimpleDateFormat
import java.util.Currency
import java.util.Date
import java.util.Locale

class LanternSessionManager(application: Application) : SessionManager(application) {
    private var selectedPlan: ProPlan? = null

    private var referral: String? = null
    private var verifyCode: String? = null

    override fun isProUser(): Boolean {
        return prefs.getBoolean(PRO_USER, false)
    }

    fun getUserLevel(): String? {
        return prefs.getString(USER_LEVEL, "")
    }

    fun setUserLevel(userLevel: String?) {
        prefs.edit().putString(USER_LEVEL, userLevel).apply()
    }

    fun setUserPlans(plans: String) {
        prefs.edit().putString(PLANS, plans).apply()
    }

    fun getUserPlans(): String? {
        return prefs.getString(PLANS, "")
    }

    fun isExpired(): Boolean {
        return prefs.getBoolean(PRO_EXPIRED, false)
    }

    fun getCurrency(): Currency? {
        try {
            val lang = language
            val parts = lang.split("_".toRegex()).toTypedArray()
            return if (parts.isNotEmpty()) {
                Currency.getInstance(Locale(parts[0], parts[1]))
            } else Currency.getInstance(Locale.getDefault())
        } catch (e: Exception) {
            Logger.error(TAG, e.message)
        }
        return Currency.getInstance("USD")
    }

    override fun currency(): String {
        return selectedPlan?.currency ?: DEFAULT_CURRENCY_CODE
    }

    fun getSelectedPlan(): ProPlan? {
        Logger.debug(TAG, "Current plan is $selectedPlan")
        return selectedPlan
    }

    fun getSelectedPlanCost(): Long {
        val plan = getSelectedPlan()
        if (plan != null) {
            val price = plan.currencyPrice
            if (price != null) {
                return price.toLong()
            }
        }
        return DEFAULT_ONE_YEAR_COST
    }

    fun getReferralArray(res: Resources): Array<String?> {
        val plan = getSelectedPlan()
        if (plan == null) {
            Logger.debug(TAG, "Selected plan is null. Returning default referral instructions")
            return res.getStringArray(R.array.referral_promotion_list)
        }
        return if (plan.numYears() == 1) {
            res.getStringArray(R.array.referral_promotion_list)
        } else {
            res.getStringArray(R.array.referral_promotion_list_two_year)
        }
    }

    fun getSelectedPlanCurrency(): String {
        val plan = getSelectedPlan()
        return if (plan != null) {
            plan.currency
        } else "usd"
    }

    fun defaultToAlipay(): Boolean {
        // Currently we default to Alipay for Yuan purchases
        return "cny" == getSelectedPlanCurrency()
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
        return prefs.getString(USER_PAYMENT_GATEWAY, "paymentwall")
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

    fun plansActivity(): Class<*> {
        return PlansActivity_::class.java
    }

    fun welcomeActivity(): Class<*> {
        return WelcomeActivity_::class.java
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

    fun getDeviceExp(): Long {
        return prefs.getLong(DEVICE_CODE_EXP, 0)
    }

    fun getProDaysLeft(): Int {
        return prefs.getInt(PRO_DAYS_LEFT, 0)
    }

    private fun setExpiration(expiration: Long?) {
        if (expiration == null) {
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
        } else LocalDateTime(expiration * 1000)
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

    fun setProPlan(plan: ProPlan?) {
        selectedPlan = plan
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

    fun setStripeToken(token: String?) {
        prefs.edit().putString(STRIPE_TOKEN, token).apply()
    }

    fun stripeToken(): String? {
        return prefs.getString(STRIPE_TOKEN, "")
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

    fun storeUserData(user: ProUser?) {
        if (user!!.email != null && user.email != "") {
            setEmail(user.email)
        }

        if (!TextUtils.isEmpty(user.code)) {
            setCode(user.code)
        }

        if (user.isActive) {
            linkDevice()
        }

        setExpiration(user.expiration)
        setExpired(user.isExpired)
        setIsProUser(user.isProUser)
        setUserLevel(user.userLevel)
        val devices = Vpn.Devices.newBuilder().addAllDevices(user.devices.map { Vpn.Device.newBuilder().setId(it.id).setName(it.name).setCreated(it.created).build() }).build()
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

    // isPlayVersion checks whether or not the user installed Lantern via
    // the Google Play store
    override fun isPlayVersion(): Boolean {
        if (BuildConfig.PLAY_VERSION || prefs.getBoolean(PLAY_VERSION, false)) {
            return true
        }
        try {
            val validInstallers: List<String> = ArrayList(listOf("com.android.vending", "com.google.android.feedback"))
            val installer = context.packageManager
                .getInstallerPackageName(context.packageName)
            return installer != null && validInstallers.contains(installer)
        } catch (e: java.lang.Exception) {
            Logger.error(TAG, "Error fetching package information: " + e.message)
        }
        return false
    }

    fun setPlayVersion(playVersion: Boolean) {
        prefs.edit().putBoolean(PLAY_VERSION, playVersion).apply()
    }

    fun setRenewalText(renewalText: String) {
        db.mutate { tx ->
            tx.put(RENEWAL_TEXT, renewalText)
        }
    }

    fun getRenewalText() {
        db.mutate { tx -> tx.get(RENEWAL_TEXT) ?: "" }
    }

    companion object {
        private val TAG = LanternSessionManager::class.java.name

        // shared preferences
        private const val PRO_USER = "prouser"
        private const val USER_LEVEL = "userLevel"
        private const val USER_ID = "userId"
        private const val RENEWAL_TEXT = "renewalText"
        private const val PLANS = "plans"
        private const val DEVICES = "devices"
        private const val PRO_EXPIRED = "proexpired"
        private const val PRO_PLAN = "proplan"
        private const val SHOW_RENEWAL_PREF = "renewalpref"
        private const val EXPIRY_DATE = "expirydate"
        private const val PRO_MONTHS_LEFT = "promonthsleft"
        private const val PRO_DAYS_LEFT = "prodaysleft"
        private const val EXPIRY_DATE_STR = "expirydatestr"
        private const val STRIPE_TOKEN = "stripe_token"
        private const val STRIPE_API_KEY = "stripe_api_key"
        private const val DEFAULT_CURRENCY_CODE = "usd"
        private const val DEVICE_LINKED = "DeviceLinked"
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
