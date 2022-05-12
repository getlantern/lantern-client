package io.lantern.android.model

import android.app.Activity
import android.text.TextUtils
import androidx.core.content.ContextCompat
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.google.gson.JsonObject
import com.stripe.android.ApiResultCallback
import com.stripe.android.Stripe
import com.stripe.android.model.Card
import com.stripe.android.model.Token
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import okhttp3.FormBody
import okhttp3.RequestBody
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.*
import org.getlantern.lantern.model.LanternHttpClient.*
import org.getlantern.lantern.openHome
import org.getlantern.lantern.restartApp
import org.getlantern.lantern.util.Analytics
import org.getlantern.lantern.util.DateUtil.isBefore
import org.getlantern.lantern.util.DateUtil.isToday
import org.getlantern.lantern.util.Json
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger
import java.util.concurrent.*

/**
 * This is a model that uses the same db schema as the preferences in SessionManager so that those
 * settings can be observed.
 */
open class SessionModel(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null,
) : BaseModel("session", flutterEngine, LanternApp.getSession().db) {
    private val lanternClient = LanternApp.getLanternHttpClient()
    private var plans: ConcurrentHashMap<String, ProPlan> = ConcurrentHashMap<String, ProPlan>()

    companion object {
        private const val TAG = "SessionModel"
        private const val STRIPE_TAG = "$TAG.stripe"

        const val PATH_PRO_USER = "prouser" // TODO: redundant
        const val PATH_PROXY_ALL = "proxyAll"
        const val PATH_PLANS = "plans"
        const val PATH_USER_LEVEL = "userLevel"
    }

    init {
        db.mutate { tx ->
            // initialize data for fresh install // TODO remove the need to do this for each data path
            // TODO: PATH_PRO_USER is now redundant since we can derive from userLevel
            tx.put(
                PATH_PRO_USER,
                castToBoolean(tx.get(PATH_PRO_USER), false)
            )
            tx.put(
                PATH_PROXY_ALL,
                castToBoolean(tx.get(PATH_PROXY_ALL), false)
            )
            // TODO: do we need this?
            tx.put(
                PATH_PLANS, tx.get(PATH_PLANS) ?: ""
            )
            // TODO: do we need this?
            tx.put(
                PATH_USER_LEVEL, tx.get(PATH_USER_LEVEL) ?: ""
            )
        }
    }

    /**
     * Sometimes, preferences values from old clients that are supposed to be booleans will actually
     * be stored as numeric values or as strings. This normalizes them all to Booleans.
     */
    private fun castToBoolean(value: Any?, defaultValue: Boolean): Boolean {
        return when (value) {
            is Boolean -> value
            is Number -> value.toInt() == 1
            is String -> value.toBoolean()
            else -> defaultValue
        }
    }

    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "authorizeViaEmail" -> authorizeViaEmail(call.argument("emailAddress")!!, result)
            "resendRecoveryCode" -> sendRecoveryCode(result)
            "validateRecoveryCode" -> validateRecoveryCode(call.argument("code")!!, result)
            "approveDevice" -> approveDevice(call.argument("code")!!, result)
            "removeDevice" -> removeDevice(call.argument("deviceId")!!, result)
            "updateAndCachePlans" -> updateAndCachePlans(result)
            "updateAndCacheUserLevel" -> updateAndCacheUserLevel(result)
            "submitStripe" -> submitStripe(call.argument("email")!!, call.argument("cardNumber")!!, call.argument("expDate")!!, call.argument("cvc")!!, result)
            "submitGooglePlay" -> submitGooglePlay(call.argument("planID")!!, result)
            "applyRefCode" -> applyRefCode(call.argument("email")!!, call.argument("refCode")!!, result)
            "submitBitcoin" -> submitBitcoin(call.argument("planID")!!, call.argument("email")!!, result)
            "redeemResellerCode" -> redeemResellerCode(call.argument("email")!!, call.argument("resellerCode")!!, result)
            else -> super.doOnMethodCall(call, result)
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "setProxyAll" -> {
                val on = call.argument("on") ?: false
                saveProxyAll(on)
            }
            "setLanguage" -> {
                LanternApp.getSession().setLanguage(call.argument("lang"))
            }
            "setPaymentTestMode" -> {
                LanternApp.getSession().setPaymentTestMode(call.argument("on") ?: false)
                activity.restartApp()
            }
            "setPlayVersion" -> {
                LanternApp.getSession().isPlayVersion = call.argument("on") ?: false
                activity.restartApp()
            }
            "getPlayVersion" -> LanternApp.getSession().isPlayVersion
            "setForceCountry" -> {
                LanternApp.getSession().setForceCountry(call.argument("countryCode") ?: "")
                activity.restartApp()
            }
            "setSelectedTab" -> {
                db.mutate { tx ->
                    tx.put("/selectedTab", call.argument<String>("tab")!!)
                }
            }
            "trackScreenView" -> Analytics.screen(activity, call.arguments as String)
            "setForceUserLevel" -> {
                LanternApp.getSession().setUserLevel(call.argument("newLevel") ?: "")
            }
            "resetCachedPlans" -> {
                LanternApp.getSession().setUserPlans("")
            }
            else -> super.doMethodCall(call, notImplemented)
        }
    }

    private fun saveProxyAll(on: Boolean) {
        db.mutate { tx ->
            tx.put(PATH_PROXY_ALL, on)
        }
    }

    private fun authorizeViaEmail(emailAddress: String, methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Start Account recovery with email $emailAddress")

        LanternApp.getSession().setEmail(emailAddress)
        val formBody = FormBody.Builder()
            .add("email", emailAddress)
            .build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/user-recover"), formBody,
            object : ProCallback {
                override fun onSuccess(response: Response?, result: JsonObject?) {
                    Logger.debug(TAG, "Account recovery response: $result")
                    if (result!!["token"] != null && result["userID"] != null) {
                        Logger.debug(TAG, "Successfully recovered account")
                        // update token and user ID with those returned by the pro server
                        LanternApp.getSession().setUserIdAndToken(result["userID"].asLong, result["token"].asString)
                        LanternApp.getSession().linkDevice()
                        LanternApp.getSession().setIsProUser(true)
                        activity.showAlertDialog(
                            activity.getString(R.string.device_added), activity.getString(R.string.device_authorized_pro), ContextCompat.getDrawable(activity, R.drawable.ic_filled_check),
                            {
                                activity.openHome()
                            }
                        )
                    } else {
                        Logger.error(TAG, "Got empty recovery result, can't continue")
                        activity.runOnUiThread {
                            methodCallResult.error("unknownError", null, null)
                        }
                        return
                    }
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error == null) {
                        Logger.error(TAG, "Unable to recover account and no error to show")
                        activity.runOnUiThread {
                            methodCallResult.error("unknownError", t?.message, null)
                        }
                        return
                    }

                    val errorId = error.id
                    if (errorId == "wrong-device") {
                        sendRecoveryCode(methodCallResult)
                    } else if (errorId == "wrong-email" || errorId == "cannot-recover-user") {
                        activity.runOnUiThread {
                            methodCallResult.error("unableToRecover", errorId, null)
                        }
                        activity.showErrorDialog(activity.resources.getString(R.string.cannot_find_email))
                    } else {
                        Logger.error(TAG, "Unknown error recovering account:$error")
                    }
                }
            }
        )
    }

    private fun sendRecoveryCode(methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Sending link request...")
        lanternClient.sendLinkRequest(object : ProCallback {
            override fun onSuccess(response: Response?, result: JsonObject?) {
                activity.runOnUiThread {
                    methodCallResult.success("needPin")
                }
            }

            override fun onFailure(t: Throwable?, error: ProError?) {
                activity.runOnUiThread {
                    methodCallResult.error("unableToRequestRecoveryCode", t?.message, null)
                }
                activity.showErrorDialog(activity.resources.getString(R.string.unknown_error))
            }
        })
    }

    private fun validateRecoveryCode(code: String, methodCallResult: MethodChannel.Result) {
        val formBody: RequestBody = FormBody.Builder()
            .add("code", code)
            .build()
        Logger.debug(TAG, "Validating link request; code:$code")
        lanternClient.post(
            LanternHttpClient.createProUrl("/user-link-validate"), formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Unable to validate link code", t)
                    activity.runOnUiThread {
                        methodCallResult.error("unableToVerifyRecoveryCode", t?.message, error?.message)
                    }
                    if (error == null) {
                        Logger.error(TAG, "Unable to validate recovery code and no error to show")
                        return
                    }
                    val errorId = error.id
                    if (errorId == "too-many-devices") {
                        activity.showErrorDialog(activity.resources.getString(R.string.too_many_devices))
                    } else if (error.message != null) {
                        activity.showErrorDialog(error.message)
                    }
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    Logger.debug(TAG, "Response: $result")
                    if (result["token"] != null && result["userID"] != null) {
                        Logger.debug(TAG, "Successfully validated recovery code")
                        // update token and user ID with those returned by the pro server
                        // update token and user ID with those returned by the pro server
                        LanternApp.getSession().setUserIdAndToken(result["userID"].asLong, result["token"].asString)
                        LanternApp.getSession().linkDevice()
                        LanternApp.getSession().setIsProUser(true)
                        activity.showAlertDialog(activity.getString(R.string.device_added), activity.getString(R.string.device_authorized_pro), ContextCompat.getDrawable(activity, R.drawable.ic_filled_check), { activity.openHome() })
                    }
                }
            }
        )
    }

    private fun approveDevice(code: String, methodCallResult: MethodChannel.Result) {
        val formBody: RequestBody = FormBody.Builder()
            .add("code", code)
            .build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/link-code-approve"), formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Error approving device link code: $error")
                    activity.runOnUiThread {
                        methodCallResult.error("errorApprovingDevice", t?.message, error?.message)
                    }
                    activity.showErrorDialog(activity.resources.getString(R.string.invalid_verification_code))
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    lanternClient.userData(object : ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.debug(TAG, "Successfully updated userData")
                            activity.runOnUiThread {
                                methodCallResult.success("approvedDevice")
                            }
                            activity.showAlertDialog(activity.resources.getString(R.string.device_added), activity.resources.getString(R.string.device_authorized_pro), ContextCompat.getDrawable(activity, R.drawable.ic_filled_check))
                        }

                        override fun onFailure(t: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $t.message")
                            methodCallResult.error("errorUpdatingUserData", t?.message, error?.message)
                        }
                    })
                }
            }
        )
    }

    private fun removeDevice(deviceId: String, methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Removing device $deviceId")
        val formBody: RequestBody = FormBody.Builder()
            .add("deviceID", deviceId)
            .build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/user-link-remove"), formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error != null) {
                        Logger.error(TAG, "Error removing device: $error")
                    }
                    activity.runOnUiThread {
                        methodCallResult.error("errorApprovingDevice", t?.message, error?.message)
                    }
                    // encountered some issue removing the device; display an error
                    activity.showErrorDialog(activity.resources.getString(R.string.unable_remove_device))
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    Logger.debug(TAG, "Successfully removed device")

                    val isLogout = deviceId == LanternApp.getSession().deviceID
                    if (isLogout) {
                        // if one of the devices we removed is the current device
                        // make sure to logout
                        Logger.debug(TAG, "Logging out")
                        LanternApp.getSession().logout()
                        activity.restartApp()
                        return
                    }

                    lanternClient.userData(object : ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.debug(TAG, "Successfully updated userData")
                            activity.runOnUiThread {
                                methodCallResult.success("removedDevice")
                            }
                        }

                        override fun onFailure(t: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $t.message")
                            methodCallResult.error("errorUpdatingUserData", t?.message, error?.message)
                        }
                    })
                }
            }
        )
    }

    // Hits the /user-data endpoint and saves { userLevel: null | "pro" | "platinum" } to PATH_USER_LEVEL
    private fun updateAndCacheUserLevel(result: MethodChannel.Result) {
        try {
            lanternClient.userData(object : ProUserCallback {
                override fun onSuccess(response: Response, userData: ProUser) {
                    Logger.debug(TAG, "Successfully updated userData")
                    result.success("cachingUserDataSuccess")
                    LanternApp.getSession().setUserLevel(userData.userLevel)
                }
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Unable to fetch user data: $t.message")
                    result.error("cachingUserDataError", "Unable to cache user status", error?.message) // This will be localized Flutter-side
                    return
                }
            })
        } catch (t: Throwable) {
            Logger.error(TAG, "Error caching user status", t)
            result.error("unknownError", "Unable to cache user status", null) // This will be localized Flutter-side
        }
    }

    // Hits the /plans endpoint and saves plans to PATH_PLANS
    private fun updateAndCachePlans(result: MethodChannel.Result) {
        try {
            LanternApp.getPlans(object : PlansCallback {
                override fun onSuccess(proPlans: Map<String, ProPlan>) {
                    plans.clear()
                    plans.putAll(proPlans)
                    Logger.info(TAG, "Successfully cached plans: $plans")
                    result.success("cachingPlansSuccess")
                    for (planId in proPlans.keys) {
                        proPlans[planId]?.let { updatePrice(it) }
                    }
                    LanternApp.getSession().setUserPlans(Json.gson.toJson(plans))
                }
                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error?.message != null) {
                        Logger.error(TAG, "Failure caching plans: $t.message")
                        result.error(
                            "unknownError",
                            "Unable to cache plans",
                            null,
                        )
                        return
                    }
                }
            })
        } catch (t: Throwable) {
            Logger.error(TAG, "Error caching plans", t)
            result.error(
                "unknownError",
                "Unable to cache plans", // This will be localized Flutter-side
                null,
            )
        }
    }

    protected fun updatePrice(plan: ProPlan) {
        val formattedBonus = formatRenewalBonusExpected(plan.renewalBonusExpected)
        val totalCost = plan.costWithoutTaxStr
        var totalCostBilledOneTime = activity.resources.getString(R.string.total_cost, totalCost)
        var formattedDiscount = ""
        if (plan.discount > 0) {
            formattedDiscount =
                activity.resources.getString(R.string.discount, Math.round(plan.discount * 100).toString())
        }
        val oneMonthCost = plan.formattedPriceOneMonth
        var renewalText = ""
        if (LanternApp.getSession().getUserLevel() == "pro" || LanternApp.getSession().getUserLevel() == "platinum" ) {
            val localDateTime = LanternApp.getSession().getExpiration()
            renewalText = when {
                localDateTime.isToday() -> {
                    activity.resources.getString(R.string.membership_ends_today, formattedBonus)
                }
                localDateTime.isBefore() -> {
                    activity.resources.getString(R.string.membership_has_expired, formattedBonus)
                }
                else -> {
                    activity.resources.getString(R.string.membership_end_soon, formattedBonus)
                }
            }
        }
        plan.setRenewalText(renewalText)
        plan.setTotalCostBilledOneTime(totalCostBilledOneTime)
        plan.setOneMonthCost(oneMonthCost)
        plan.setFormattedBonus(formattedBonus)
        plan.setFormattedDiscount(formattedDiscount)
        plan.setTotalCost(totalCost)
    }

    private fun formatRenewalBonusExpected(planBonus: MutableMap<String, Int>): String? {
        val bonusMonths: Int? = planBonus["months"]
        val bonusDays: Int? = planBonus["days"]
        val bonusParts: MutableList<String?> = java.util.ArrayList()
        if (bonusMonths != null && bonusMonths > 0) {
            bonusParts.add(
                activity.resources.getQuantityString(
                    R.plurals.month,
                    bonusMonths.toInt(),
                    bonusMonths
                )
            )
        }
        if (bonusDays != null && bonusDays > 0) {
            bonusParts.add(activity.resources.getQuantityString(R.plurals.day, bonusDays.toInt(), bonusDays))
        }
        return TextUtils.join(" ", bonusParts)
    }

    // TODO: WIP
    // Transmits the email and credit card info to Stripe checkout flow
    private fun submitStripe(
        email: String,
        cardNumber: String,
        expDate: String,
        cvc: String,
        result: MethodChannel.Result
    ) {
        try {
            LanternApp.getSession().setEmail(email)
            val dateComponents = expDate.split(expDate.trim(), "/")
            val month = dateComponents[0].toInt()
            val year = dateComponents[1].toInt()
            val card: Card = Card.create(
                cardNumber.trim(),
                month,
                year,
                cvc.trim { it <= ' ' }
            )
            Logger.debug(
                STRIPE_TAG,
                "Stripe publishable key is '%s'",
                LanternApp.getSession().stripePubKey()
            )
            val stripe = Stripe(
                activity,
                LanternApp.getSession().stripePubKey()!!
            )
            stripe.createCardToken(
                card,
                callback = object : ApiResultCallback<Token> {
                    override fun onSuccess(token: Token) {
                        LanternApp.getSession().setStripeToken(token.id)
                        result.success("stripeSuccess")
                        val paymentHandler = PaymentHandler(activity, "stripe")
                        paymentHandler.sendPurchaseRequest()
                    }

                    override fun onError(error: Exception) {
                        result.error("unknownError", error.localizedMessage, null)
                        return
                    }
                }
            )
        } catch (t: Throwable) {
            Logger.error(STRIPE_TAG, "Error submitting payment to stripe", t)
            result.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
        }
    }

    // TODO: WIP
    // Handles Google Play transaction
    private fun submitGooglePlay(planID: String, result: MethodChannel.Result) {
        if (LanternApp.getInAppBilling() == null) {
            Logger.error(TAG, "getInAppBilling is null")
            result.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
            return
        }
        if (LanternApp.getInAppBilling() != null && !LanternApp.getInAppBilling().startPurchase(
                activity,
                planID,
                object : PurchasesUpdatedListener {
                    override fun onPurchasesUpdated(
                        billingResult: BillingResult,
                        purchases: MutableList<Purchase>?
                    ) {
                        if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                            result.error(
                                    "unknownError",
                                    activity.resources.getString(R.string.error_making_purchase),
                                    null,
                                )
                            return
                        }

                        val tokens: MutableList<String> = ArrayList()
                        for (purchase in purchases!!) {
                            if (!purchase.isAcknowledged) {
                                Logger.debug(
                                        TAG,
                                        "Order Token: " + purchase.purchaseToken
                                    )
                                tokens.add(purchase.purchaseToken)
                            }
                        }

                        if (tokens.size != 1) {
                            Logger.error(
                                    TAG,
                                    "Unexpected number of purchased products, not proceeding with purchase: " + tokens.size
                                )
                            result.error(
                                    "unknownError",
                                    activity.resources.getString(R.string.error_making_purchase),
                                    null,
                                )
                            return
                        }

                        result.success(null)
                        val paymentHandler =
                            PaymentHandler(activity, "googleplay", tokens[0])
                        paymentHandler.sendPurchaseRequest()
                    }
                }
            )
        ) {
            result.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
        }
    }

    // TODO: WIP
    // Applies referral code (before the user has initiated a transaction)
    private fun applyRefCode(email: String, refCode: String, result: MethodChannel.Result) {
        try {
            // TODO: Migrate handleReferral() from CheckoutActivity
            // TODO: handle error
        } catch (t: Throwable) {
            Logger.error(TAG, "Unable to apply referral code", t)
            result.error(
                "unknownError",
                "Something went wrong while applying your referral code", // This error message is localized Flutter-side
                null,
            )
        }
    }

    // TODO: WIP
    // Fetches the BTCPay endpoint info which is needed to trigger the Webview
    private fun submitBitcoin(planID: String, email: String, result: MethodChannel.Result) {
        try {
            // TODO: hit /purchase-redirect endpoint
        } catch (t: Throwable) {
            Logger.error(TAG, "BTCPay is unavailable", t)
            result.error(
                "unknownError",
                "BTCPay is unavailable", // This error message is localized Flutter-side
                null,
            )
        }
    }

    // TODO: WIP
    private fun redeemResellerCode(email: String, resellerCode: String, result: MethodChannel.Result) {
        try {
            LanternApp.getSession().setEmail(email)
            LanternApp.getSession().setResellerCode(resellerCode)
            val paymentHandler =
                PaymentHandler(activity, "reseller-code")
            paymentHandler.sendPurchaseRequest()
            result.success("redeemResellerSuccess")
        } catch (t: Throwable) {
            Logger.error(TAG, "Unable to redeem reseller code", t)
            result.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
        }
    }
}
