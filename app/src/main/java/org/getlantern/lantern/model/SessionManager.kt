package org.getlantern.lantern.model

import android.content.Context
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

class SessionManager(context: Context) : SessionManager(context) {
    private var selectedPlan: ProPlan? = null

    // the devices associated with a user's Pro account
    private var devices: java.util.HashMap<String?, Device?> = HashMap()

    private var referral: String? = null
    private var verifyCode: String? = null

    override fun isProUser(): Boolean {
        return prefs.getBoolean(PRO_USER, false)
    }

    private fun isDeviceLinked(): Boolean {
        return prefs.getBoolean(DEVICE_LINKED, false)
    }

    fun isExpired(): Boolean {
        return prefs.getBoolean(PRO_EXPIRED, false)
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
        editor.putString(REMOTE_CONFIG_PAYMENT_PROVIDER, provider).commit()
    }

    fun getRemoteConfigPaymentProvider(): String? {
        return prefs.getString(REMOTE_CONFIG_PAYMENT_PROVIDER, "")
    }

    fun setPaymentProvider(provider: String?) {
        editor.putString(USER_PAYMENT_GATEWAY, provider).commit()
    }

    fun getPaymentProvider(): String? {
        return prefs.getString(USER_PAYMENT_GATEWAY, "paymentwall")
    }

    fun setSignature(sig: String?) {
        editor.putString(PW_SIGNATURE, sig).commit()
    }

    fun getPwSignature(): String? {
        return prefs.getString(PW_SIGNATURE, "")
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
        editor.putString(STRIPE_API_KEY, key).commit()
    }

    fun stripePubKey(): String? {
        return prefs.getString(STRIPE_API_KEY, "")
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
        editor.putLong(DEVICE_CODE_EXP, expiration * 1000).commit()
        editor.putString(DEVICE_LINKING_CODE, code).commit()
    }

    fun deviceCode(): String? {
        return prefs.getString(DEVICE_LINKING_CODE, "")
    }

    fun getDeviceExp(): Long? {
        return prefs.getLong(DEVICE_CODE_EXP, 0)
    }

    fun yinbiEnabled(): Boolean {
        return BuildConfig.YINBI_ENABLED || prefs.getBoolean(YINBI_ENABLED, false)
    }

    fun setYinbiEnabled(enabled: Boolean) {
        editor.putBoolean(YINBI_ENABLED, enabled).commit()
    }

    fun showYinbiThanksPurchase(): Boolean {
        return prefs.getBoolean(YINBI_THANKS_PURCHASE, false)
    }

    fun setThanksPurchase(v: Boolean) {
        editor.putBoolean(YINBI_THANKS_PURCHASE, v).commit()
    }

    fun showYinbiRedemptionTable(): Boolean {
        return prefs.getBoolean(SHOW_YINBI_REDEMPTION, false)
    }

    fun setShowRedemptionTable(v: Boolean) {
        editor.putBoolean(SHOW_YINBI_REDEMPTION, v).commit()
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
        editor.putLong(EXPIRY_DATE, expiration)
        editor.putString(EXPIRY_DATE_STR, dateToStr).commit()
    }

    fun getExpiration(): LocalDateTime? {
        val expiration = prefs.getLong(EXPIRY_DATE, 0L)
        return if (expiration == 0L) {
            null
        } else LocalDateTime(expiration * 1000)
    }

    fun getExpirationStr(): String? {
        return prefs.getString(EXPIRY_DATE_STR, "")
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
        editor.putLong(name, currentMilliseconds + numSeconds * 1000).commit()
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
        return isRecentInstall && prefs.getLong(WELCOME_LAST_SEEN, 0) == 0L
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
        editor.putLong(name, System.currentTimeMillis()).commit()
    }

    fun setRenewalPref(dontShow: Boolean) {
        editor.putBoolean(SHOW_RENEWAL_PREF, dontShow).commit()
    }

    fun showRenewalPref(): Boolean {
        return prefs.getBoolean(SHOW_RENEWAL_PREF, true)
    }

    fun proUserStatus(status: String) {
        if (status == "active") {
            editor.putBoolean(PRO_USER, true).commit()
        }
    }

    fun setProPlan(plan: ProPlan?) {
        selectedPlan = plan
    }

    fun setIsProUser(isProUser: Boolean) {
        editor.putBoolean(PRO_USER, isProUser).commit()
    }

    fun setExpired(expired: Boolean) {
        editor.putBoolean(PRO_EXPIRED, expired).commit()
    }

    fun setEmail(email: String?) {
        editor.putString(EMAIL_ADDRESS, email).commit()
    }

    fun setResellerCode(code: String?) {
        editor.putString(RESELLER_CODE, code).commit()
    }

    fun setProvider(provider: String?) {
        editor.putString(PROVIDER, provider).commit()
    }

    fun setAccountId(accountId: String?) {
        editor.putString(ACCOUNT_ID, accountId).commit()
    }

    fun accountId(): String? {
        return prefs.getString(ACCOUNT_ID, "")
    }

    override fun code(): String? {
        return prefs.getString(REFERRAL_CODE, "")
    }

    override fun setCode(referral: String?) {
        editor.putString(REFERRAL_CODE, referral).commit()
    }

    fun setStripeToken(token: String?) {
        editor.putString(STRIPE_TOKEN, token).commit()
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

    fun unlinkDevice(newUser: Boolean) {
        devices.clear()
        setIsProUser(false)
        editor.putBoolean(PRO_USER, false)
        editor.putBoolean(DEVICE_LINKED, false)
        editor.remove(TOKEN)
        editor.remove(EMAIL_ADDRESS)
        editor.remove(USER_ID)
        editor.remove(DEVICE_CODE_EXP)
        editor.remove(DEVICE_LINKING_CODE)
        editor.remove(PRO_PLAN)
        editor.commit()
    }

    fun linkDevice() {
        editor.putBoolean(DEVICE_LINKED, true)
        editor.commit()
    }

    override fun storeUserData(user: ProUser?) {
        super.storeUserData(user)

        if (user!!.email != null && user!!.email != "") {
            setEmail(user!!.email)
        }

        setYinbiEnabled(user!!.yinbiEnabled)

        if (!TextUtils.isEmpty(user!!.code)) {
            setCode(user!!.code)
        }

        if (user!!.isActive) {
            linkDevice()
            setShowRedemptionTable(true)
        } else if (isProUser) {
            setShowRedemptionTable(true)
        }

        setExpiration(user!!.expiration)
        setExpired(user!!.isExpired)
        setIsProUser(user!!.isProUser)

        if (user!!.isProUser) {
            EventBus.getDefault().post(UserStatus(user!!.isActive, user!!.monthsLeft().toLong()))
            editor.putInt(PRO_MONTHS_LEFT, user!!.monthsLeft()).commit()
            editor.putInt(PRO_DAYS_LEFT, user!!.daysLeft()).commit()
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
        private const val YINBI_USER_ID = "yinbiuserid"
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