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
        return getPrefs().isProUser
    }

    private fun isDeviceLinked(): Boolean {
        return getPrefs().isDeviceLinked
    }

    fun isExpired(): Boolean {
        return getPrefs().isProExpired
    }

    fun getCurrency(): Currency? {
        try {
            val lang = language
            val parts = lang!!.split("_".toRegex()).toTypedArray()
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
        updatePrefs { prefs -> prefs.remoteConfigPaymentProvider = provider }
    }

    fun getRemoteConfigPaymentProvider(): String? {
        return getPrefs().remoteConfigPaymentProvider ?: ""
    }

    fun setPaymentProvider(provider: String?) {
        updatePrefs { prefs -> prefs.userPaymentGateway = provider }
    }

    fun getPaymentProvider(): String? {
        return getPrefs().userPaymentGateway ?: "paymentwall"
    }

    fun setSignature(sig: String?) {
        updatePrefs { prefs -> prefs.pwSignature = sig }
    }

    fun getPwSignature(): String? {
        return getPrefs().pwSignature ?: ""
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
        updatePrefs { prefs -> prefs.stripeApiKey = key }
    }

    fun stripePubKey(): String? {
        return getPrefs().stripeApiKey ?: ""
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
        updatePrefs { prefs ->
            prefs.deviceCodeExpiration = expiration * 1000
            prefs.deviceLinkingCode = code
        }
    }

    fun deviceCode(): String? {
        return getPrefs().deviceLinkingCode
    }

    fun getDeviceExp(): Long? {
        return getPrefs().deviceCodeExpiration
    }

    fun yinbiEnabled(): Boolean {
        return BuildConfig.YINBI_ENABLED || getPrefs().yinbiEnabled
    }

    fun setYinbiEnabled(enabled: Boolean) {
        updatePrefs { prefs -> prefs.yinbiEnabled = enabled }
    }

    fun showYinbiThanksPurchase(): Boolean {
        return getPrefs().yinbiThanksPurchase
    }

    fun setThanksPurchase(v: Boolean) {
        updatePrefs { prefs -> prefs.yinbiThanksPurchase = v }
    }

    fun showYinbiRedemptionTable(): Boolean {
        return getPrefs().yinbiShowRedemption
    }

    fun setShowRedemptionTable(v: Boolean) {
        updatePrefs { prefs -> prefs.yinbiShowRedemption = v }
    }

    fun getProDaysLeft(): Int? {
        return getPrefs().proDaysLeft
    }

    private fun setExpiration(expiration: Long?) {
        if (expiration == null) {
            return
        }
        val expiry = Date(expiration * 1000)
        val dateFormat = SimpleDateFormat("MM/dd/yyyy")
        val dateToStr = dateFormat.format(expiry)
        Logger.debug(TAG, "Lantern pro expiration date: $dateToStr")
        updatePrefs { prefs ->
            prefs.expirationDate = expiration
            prefs.expirationString = dateToStr
        }
    }

    fun getExpiration(): LocalDateTime? {
        val expiration = getPrefs().expirationDate
        return if (expiration == 0L) {
            null
        } else LocalDateTime(expiration * 1000)
    }

    fun getExpirationStr(): String? {
        return getPrefs().expirationString
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
        return isRecentInstall && getPrefs().welcomeLastSeen == 0L
    }

    fun getProTimeLeft(): String? {
        val numMonths = numProMonths()
        if (numMonths < 1) {
            val numDays = getPrefs().proDaysLeft
            return if (numDays == 0) {
                ""
            } else String.format("%dD", numDays)
        }
        return String.format("%dMO",
                numMonths)
    }

    fun numProMonths(): Int {
        return getPrefs().proMonthsLeft
    }

    fun setWelcomeLastSeen() {
        val now = System.currentTimeMillis()
        updatePrefs { prefs ->
            if (isProUser) {
                prefs.renewalLastSeen = now
            } else {
                prefs.welcomeLastSeen = now
            }
        }
    }

    fun setRenewalPref(dontShow: Boolean) {
        updatePrefs { prefs -> prefs.showRenewal = !dontShow }
    }

    fun showRenewalPref(): Boolean {
        return getPrefs().showRenewal
    }

    fun proUserStatus(status: String) {
        if (status == "active") {
            updatePrefs { prefs -> prefs.isProUser = true }
        }
    }

    fun setProPlan(plan: ProPlan?) {
        selectedPlan = plan
    }

    fun setIsProUser(isProUser: Boolean) {
        updatePrefs { prefs -> prefs.isProUser = isProUser }
    }

    fun setExpired(expired: Boolean) {
        updatePrefs { prefs -> prefs.isProExpired = expired }
    }

    fun setResellerCode(code: String?) {
        updatePrefs { prefs -> prefs.resellerCode = code }
    }

    fun setProvider(provider: String?) {
        updatePrefs { prefs -> prefs.provider = provider }
    }

    fun setAccountId(accountId: String?) {
        updatePrefs { prefs -> prefs.accountId = accountId }
    }

    fun accountId(): String? {
        return getPrefs().accountId
    }

    override fun code(): String? {
        return getPrefs().referralCode ?: ""
    }

    override fun setCode(referral: String?) {
        updatePrefs { prefs -> prefs.referralCode = referral }
    }

    fun setStripeToken(token: String?) {
        updatePrefs { prefs -> prefs.stripeToken = token }
    }

    fun stripeToken(): String? {
        return getPrefs().stripeToken ?: ""
    }

    fun resellerCode(): String? {
        return getPrefs().resellerCode ?: ""
    }

    override fun provider(): String? {
        return getPrefs().provider ?: ""
    }

    fun setReferral(referralCode: String?) {
        referral = referralCode
    }

    fun referral(): String? {
        return referral
    }

    fun unlinkDevice() {
        devices.clear()
        updatePrefs { prefs ->
            prefs.isProUser = false
            prefs.isDeviceLinked = false
            prefs.proToken = null
            prefs.emailAddress = null
            prefs.userId = 0
            prefs.deviceCodeExpiration = 0
            prefs.deviceLinkingCode = null
        }
    }

    fun linkDevice() {
        updatePrefs { prefs -> prefs.isDeviceLinked = true }
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
            updatePrefs { prefs ->
                prefs.proMonthsLeft = user.monthsLeft()
                prefs.proDaysLeft = user.daysLeft()
            }
        }
    }

    companion object {
        // shared preferences
        private const val DEFAULT_CURRENCY_CODE = "usd"

        // other constants
        private const val DEFAULT_ONE_YEAR_COST: Long = 3200
    }
}