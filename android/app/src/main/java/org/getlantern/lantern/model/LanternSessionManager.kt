package org.getlantern.lantern.model

import android.app.Application
import android.content.res.Resources
import android.text.TextUtils
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.AddDeviceActivity
import org.getlantern.lantern.activity.LanternPlansActivity
import org.getlantern.lantern.activity.WelcomeActivity_
import org.getlantern.lantern.activity.yinbi.YinbiPlansActivity
import org.getlantern.lantern.activity.yinbi.YinbiRenewActivity
import org.getlantern.lantern.activity.yinbi.YinbiWelcomeActivity_
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.SessionManager
import org.greenrobot.eventbus.EventBus
import org.joda.time.LocalDateTime
import java.text.SimpleDateFormat
import java.util.*

class LanternSessionManager(application: Application) : SessionManager(application) {
    private var selectedPlan: ProPlan? = null

    // the devices associated with a user's Pro account
    private var devices: java.util.HashMap<String?, Device?> = HashMap()

    private var referral: String? = null
    private var verifyCode: String? = null

    override fun isProUser(): Boolean {
        return prefs.get<Boolean>(PRO_USER) ?: false
    }

    private fun isDeviceLinked(): Boolean {
        return prefs.get<Boolean>(DEVICE_LINKED) ?: false
    }

    fun isExpired(): Boolean {
        return prefs.get<Boolean>(PRO_EXPIRED) ?: false
    }

    fun getCurrency(): Currency? {
        try {
            val lang = language
            val parts = lang.split("_".toRegex()).toTypedArray()
            return if (parts.size > 0) {
                Currency.getInstance(Locale(parts[0], parts[1]))
            } else Currency.getInstance(Locale.getDefault())
        } catch (e: Exception) {
            Logger.error(TAG, e.message)
        }
        return Currency.getInstance("USD")
    }

    /**
     * When Stripe Checkout is used, this determines whether or not Bitcoin
     * should be enabled. Currently only enabled for Iranian users.
     */
    fun useBitcoin(): Boolean {
        return isIranianUser
    }

    /**
     * When Stripe Checkout is used, this determines whether or not Alipay
     * should be enabled. Currently only enabled for Chinese users.
     */
    fun useAlipay(): Boolean {
        return isChineseUser
    }

    override fun currency(): String? {
        val plan = selectedPlan
        return if (plan != null) {
            plan.currency
        } else DEFAULT_CURRENCY_CODE
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

    fun getReferralArray(res: Resources): Array<String?>? {
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
        prefs.mutate { tx ->
            tx.put(REMOTE_CONFIG_PAYMENT_PROVIDER, provider)
        }
    }

    fun getRemoteConfigPaymentProvider(): String? {
        return prefs.get<String>(REMOTE_CONFIG_PAYMENT_PROVIDER) ?: ""
    }

    fun setPaymentProvider(provider: String?) {
        prefs.mutate { tx ->
            tx.put(USER_PAYMENT_GATEWAY, provider)
        }
    }

    fun getPaymentProvider(): String? {
        return prefs.get<String>(USER_PAYMENT_GATEWAY) ?: "paymentwall"
    }

    fun setSignature(sig: String?) {
        prefs.mutate { tx ->
            tx.put(PW_SIGNATURE, sig)
        }
    }

    fun getPwSignature(): String? {
        return prefs.get<String>(PW_SIGNATURE) ?: ""
    }

    fun addDevice(device: Device) {
        devices.put(device.id, device)
    }

    fun removeDevice(id: String?) {
        devices.remove(id)
    }

    fun getDevices(): Map<String?, Device?>? {
        return devices
    }

    fun setStripePubKey(key: String?) {
        prefs.mutate { tx ->
            tx.put(STRIPE_API_KEY, key)
        }
    }

    fun stripePubKey(): String? {
        return prefs.get<String>(STRIPE_API_KEY) ?: ""
    }

    fun plansActivity(): Class<*>? {
        return if (!isPlayVersion && yinbiEnabled()) {
            if (isProUser) {
                YinbiRenewActivity::class.java
            } else {
                YinbiPlansActivity::class.java
            }
        } else {
            LanternPlansActivity::class.java
        }
    }

    fun welcomeActivity(): Class<*>? {
        return if (yinbiEnabled()) {
            YinbiWelcomeActivity_::class.java
        } else {
            WelcomeActivity_::class.java
        }
    }

    fun deviceLinked(): Boolean {
        if (!isDeviceLinked()) {
            launchActivity(AddDeviceActivity::class.java, false)
            return false
        }
        return true
    }

    fun setVerifyCode(code: String) {
        Logger.debug(TAG, "Verify code set to $code")
        verifyCode = code
    }

    fun verifyCode(): String? {
        return verifyCode
    }

    fun setDeviceCode(code: String?, expiration: Long) {
        prefs.mutate { tx ->
            tx.put(DEVICE_CODE_EXP, expiration * 1000)
            tx.put(DEVICE_LINKING_CODE, code)
        }
    }

    fun deviceCode(): String? {
        return prefs.get<String>(DEVICE_LINKING_CODE) ?: ""
    }

    fun getDeviceExp(): Long? {
        return prefs.get<Long>(DEVICE_CODE_EXP) ?: 0
    }

    fun yinbiEnabled(): Boolean {
        return BuildConfig.YINBI_ENABLED || prefs.get<Boolean>(YINBI_ENABLED) ?: false
    }

    fun setYinbiEnabled(enabled: Boolean) {
        prefs.mutate { tx ->
            tx.put(YINBI_ENABLED, enabled)
        }
    }

    fun showYinbiThanksPurchase(): Boolean {
        return prefs.get<Boolean>(YINBI_THANKS_PURCHASE) ?: false
    }

    fun setThanksPurchase(v: Boolean) {
        prefs.mutate { tx ->
            tx.put(YINBI_THANKS_PURCHASE, v)
        }
    }

    fun showYinbiRedemptionTable(): Boolean {
        return prefs.get<Boolean>(SHOW_YINBI_REDEMPTION) ?: false
    }

    fun setShowRedemptionTable(v: Boolean) {
        prefs.mutate { tx ->
            tx.put(SHOW_YINBI_REDEMPTION, v)
        }
    }

    fun getProDaysLeft(): Int? {
        return getInt(PRO_DAYS_LEFT, 0)
    }

    private fun setExpiration(expiration: Long?) {
        if (expiration == null) {
            return
        }
        val expiry = Date(expiration * 1000)
        val dateFormat = SimpleDateFormat("MM/dd/yyyy")
        val dateToStr = dateFormat.format(expiry)
        Logger.debug(TAG, "Lantern pro expiration date: $dateToStr")
        prefs.mutate { tx ->
            tx.put(EXPIRY_DATE, expiration)
            tx.put(EXPIRY_DATE_STR, dateToStr)
        }
    }

    fun getExpiration(): LocalDateTime? {
        val expiration = prefs.get<Long>(EXPIRY_DATE) ?: 0L
        return if (expiration == 0L) {
            null
        } else LocalDateTime(expiration * 1000)
    }

    fun getExpirationStr(): String? {
        return prefs.get<String>(EXPIRY_DATE_STR) ?: ""
    }

    fun showWelcomeScreen(): Boolean {
        if (isExpired()) {
            return showRenewalPref()
        }
        if (isProUser) {
            val daysLeft = getProDaysLeft() ?: return false
            return daysLeft < 45 && showRenewalPref()
        }

        // Show only once to free users. (If set, don't show)
        // Also, if the install isn't new-ish, we won't start showing them a welcome.
        return isRecentInstall && prefs.get<Long>(WELCOME_LAST_SEEN) ?: 0 == 0L
    }

    fun getProTimeLeft(): String? {
        val numMonths = numProMonths()
        if (numMonths < 1) {
            val numDays = getInt(PRO_DAYS_LEFT, 0)
            return if (numDays == 0) {
                ""
            } else String.format("%dD", numDays)
        }
        return String.format("%dMO",
                numMonths)
    }

    fun numProMonths(): Int {
        return getInt(PRO_MONTHS_LEFT, 0)
    }

    fun setWelcomeLastSeen() {
        val name = if (isProUser) RENEWAL_LAST_SEEN else WELCOME_LAST_SEEN
        prefs.mutate { tx ->
            tx.put(name, System.currentTimeMillis())
        }
    }

    fun setRenewalPref(dontShow: Boolean) {
        prefs.mutate { tx ->
            tx.put(SHOW_RENEWAL_PREF, dontShow)
        }
    }

    fun showRenewalPref(): Boolean {
        return prefs.get<Boolean>(SHOW_RENEWAL_PREF) ?: true
    }

    fun proUserStatus(status: String) {
        if (status == "active") {
            prefs.mutate { tx ->
                tx.put(PRO_USER, true)
            }
        }
    }

    fun setProPlan(plan: ProPlan?) {
        selectedPlan = plan
    }

    fun setIsProUser(isProUser: Boolean) {
        prefs.mutate { tx ->
            tx.put(PRO_USER, isProUser)
        }
    }

    fun setExpired(expired: Boolean) {
        prefs.mutate { tx ->
            tx.put(PRO_EXPIRED, expired)
        }
    }

    fun setResellerCode(code: String?) {
        prefs.mutate { tx ->
            tx.put(RESELLER_CODE, code)
        }
    }

    fun setProvider(provider: String?) {
        prefs.mutate { tx ->
            tx.put(PROVIDER, provider)
        }
    }

    fun setAccountId(accountId: String?) {
        prefs.mutate { tx ->
            tx.put(ACCOUNT_ID, accountId)
        }
    }

    fun accountId(): String? {
        return prefs.get<String>(ACCOUNT_ID) ?: ""
    }

    override fun code(): String? {
        return prefs.get<String>(REFERRAL_CODE) ?: ""
    }

    override fun setCode(referral: String?) {
        prefs.mutate { tx ->
            tx.put(REFERRAL_CODE, referral)
        }
    }

    fun setStripeToken(token: String?) {
        prefs.mutate { tx ->
            tx.put(STRIPE_TOKEN, token)
        }
    }

    fun stripeToken(): String? {
        return prefs.get<String>(STRIPE_TOKEN) ?: ""
    }

    fun resellerCode(): String? {
        return prefs.get<String>(RESELLER_CODE) ?: ""
    }

    override fun provider(): String? {
        return prefs.get<String>(PROVIDER) ?: ""
    }

    fun setReferral(referralCode: String?) {
        referral = referralCode
    }

    fun referral(): String? {
        return referral
    }

    fun unlinkDevice() {
        devices.clear()
        setIsProUser(false)
        prefs.mutate { tx ->
            tx.put(PRO_USER, false)
            tx.put(DEVICE_LINKED, false)
            tx.delete(TOKEN)
            tx.delete(EMAIL_ADDRESS)
            tx.delete(USER_ID)
            tx.delete(DEVICE_CODE_EXP)
            tx.delete(DEVICE_LINKING_CODE)
            tx.delete(PRO_PLAN)
        }
    }

    fun linkDevice() {
        prefs.mutate { tx ->
            tx.put(DEVICE_LINKED, true)
        }
    }

    fun storeUserData(user: ProUser?) {
        if (user!!.email != null && user.email != "") {
            setEmail(user.email)
        }

        setYinbiEnabled(user.yinbiEnabled)

        if (!TextUtils.isEmpty(user.code)) {
            setCode(user.code)
        }

        if (user.isActive) {
            linkDevice()
            setShowRedemptionTable(true)
        } else if (isProUser) {
            setShowRedemptionTable(true)
        }

        setExpiration(user.expiration)
        setExpired(user.isExpired)
        setIsProUser(user.isProUser)

        if (user.isProUser) {
            EventBus.getDefault().post(UserStatus(user.isActive, user.monthsLeft().toLong()))
            prefs.mutate { tx ->
                tx.put(PRO_MONTHS_LEFT, user.monthsLeft())
                tx.put(PRO_DAYS_LEFT, user.daysLeft())
            }
        }
    }

    companion object {
        // shared preferences
        private const val PRO_USER = "prouser"
        private const val PRO_EXPIRED = "proexpired"
        private const val PRO_PLAN = "proplan"
        private const val SHOW_RENEWAL_PREF = "renewalpref"
        private const val ACCOUNT_ID = "accountid"
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
        private const val YINBI_ENABLED = "yinbienabled"
        private const val YINBI_THANKS_PURCHASE = "showyinbithankspurchase"
        private const val SHOW_YINBI_REDEMPTION = "showyinbiredemption"
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