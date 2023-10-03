package org.getlantern.lantern.util

import android.app.Activity
import android.app.ProgressDialog
import androidx.annotation.NonNull
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.google.gson.JsonObject
import com.stripe.android.ApiResultCallback
import com.stripe.android.Stripe
import com.stripe.android.model.CardParams
import com.stripe.android.model.Token
import io.flutter.plugin.common.MethodChannel
import okhttp3.FormBody
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.datadog.Datadog
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternHttpClient.ProCallback
import org.getlantern.lantern.model.LanternSessionManager
import org.getlantern.lantern.model.PaymentProvider
import org.getlantern.lantern.model.ProError
import org.getlantern.mobilesdk.Logger

class PaymentsUtil(private val activity: Activity) {

    private val session: LanternSessionManager = LanternApp.getSession()

    @JvmField
    protected var dialog: ProgressDialog? = null

    public fun submitStripePayment(
        planID: String,
        email: String,
        cardNumber: String,
        expirationDate: String,
        cvc: String,
        methodCallResult: MethodChannel.Result,
    ) {
        try {
            Datadog.trackUserClick("submitStripePayment", mapOf(
                "email" to email,
                "planID" to planID,
            ))
            val date = expirationDate.split("/").toTypedArray()
            val card: CardParams = CardParams(
                cardNumber.replace("[\\s]", ""),
                date[0].toInt(), // expMonth
                date[1].toInt(), // expYear
                cvc,
            )
            val stripe: Stripe = Stripe(activity, session.stripePubKey()!!)
            dialog = createDialog(activity.resources.getString(R.string.processing_payment))
            stripe.createCardToken(
                card,
                callback = object : ApiResultCallback<Token> {
                    override fun onSuccess(@NonNull token: Token) {
                        sendPurchaseRequest(
                            planID,
                            email,
                            token.id,
                            PaymentProvider.Stripe,
                            methodCallResult,
                        )
                    }

                    override fun onError(@NonNull error: Exception) {
                        dialog?.dismiss()
                        Datadog.addError("Error submitting to Stripe: $error")
                        methodCallResult.error(
                            "errorSubmittingToStripe",
                            error.getLocalizedMessage(),
                            null,
                        )
                    }
                },
            )
        } catch (t: Throwable) {
            dialog?.dismiss()
            Datadog.addError("Error submitting to Stripe", t)
            methodCallResult.error(
                "errorSubmittingToStripe",
                activity.getString(R.string.error_making_purchase),
                null,
            )
        }
    }

    fun submitBitcoinPayment(
        planID: String,
        email: String,
        refCode: String,
        methodCallResult: MethodChannel.Result,
    ) {
        try {
            Datadog.trackUserClick("submitBitcoinPayment", mapOf(
                "email" to email,
                "planID" to planID,
            ))
            val provider = PaymentProvider.BTCPay.toString().lowercase()
            val params = mutableMapOf<String, String>(
                "email" to email,
                "plan" to planID,
                "provider" to provider,
                "deviceName" to session.deviceName(),
            )
            lanternClient.get(
                LanternHttpClient.createProUrl("/payment-redirect", params),
                object : ProCallback {
                    override fun onFailure(throwable: Throwable?, error: ProError?) {
                        Datadog.addError("BTCPay is unavailable", throwable)
                        methodCallResult.error(
                            "unknownError",
                            "BTCPay is unavailable", // This error message is localized Flutter-side
                            null,
                        )
                        return
                    }

                    override fun onSuccess(response: Response?, result: JsonObject?) {
                        Logger.debug(
                            TAG,
                            "Email successfully validated $email",
                        )
                        methodCallResult.success(result.toString())
                    }
                },
            )
        } catch (t: Throwable) {
            Datadog.addError("BTCPay is unavailable", t)
            methodCallResult.error(
                "unknownError",
                "BTCPay is unavailable", // This error message is localized Flutter-side
                null,
            )
        }
    }

    // Handles Google Play transactions
    fun submitGooglePlayPayment(planID: String, methodCallResult: MethodChannel.Result) {
        val inAppBilling = LanternApp.getInAppBilling()
        Datadog.trackUserClick("googlePlayPayment", mapOf(
            "planID" to planID,
        ))

        if (inAppBilling == null) {
            Logger.error(TAG, "Missing inAppBilling")
            methodCallResult.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
            return
        }
        inAppBilling.startPurchase(
            activity,
            planID,
            object : PurchasesUpdatedListener {
                override fun onPurchasesUpdated(
                    billingResult: BillingResult,
                    purchases: MutableList<Purchase>?,
                ) {
                    if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                        methodCallResult.error(
                            "unknownError",
                            activity.resources.getString(R.string.error_making_purchase),
                            null,
                        )
                        Datadog.addError("Google Play: error making purchase")
                        return
                    }

                    val tokens = mutableListOf<String>()
                    for (purchase in purchases!!) {
                        if (!purchase.isAcknowledged) tokens.add(purchase.purchaseToken)
                    }

                    if (tokens.size != 1) {
                        Logger.error(
                            TAG,
                            "Unexpected number of purchased products, not proceeding with purchase",
                        )
                        methodCallResult.error(
                            "unknownError",
                            activity.resources.getString(R.string.error_making_purchase),
                            null,
                        )
                        return
                    }

                    sendPurchaseRequest(
                        planID,
                        "",
                        tokens[0],
                        PaymentProvider.GooglePlay,
                        methodCallResult,
                    )
                }
            },
        )
    }

    // Applies referral code (before the user has initiated a transaction)
    fun applyRefCode(refCode: String, methodCallResult: MethodChannel.Result) {
        try {
            val formBody: FormBody = FormBody.Builder()
                .add("code", refCode).build()
            lanternClient.post(
                LanternHttpClient.createProUrl("/referral-attach"),
                formBody,
                object : ProCallback {
                    override fun onFailure(throwable: Throwable?, error: ProError?) {
                        Datadog.addError("Error retrieving referral code: $error", throwable)
                        if (error != null && error.message != null) {
                            methodCallResult.error(
                                "unknownError",
                                error.message,
                                null,
                            )
                            return
                        }
                    }

                    override fun onSuccess(response: Response, result: JsonObject) {
                        Logger.debug(
                            TAG,
                            "Successfully redeemed referral code: $refCode",
                        )
                        session.setReferral(refCode)
                        methodCallResult.success("applyCodeSuccessful")
                    }
                },
            )
        } catch (t: Throwable) {
            Datadog.addError("Unable to apply referral code", t)
            methodCallResult.error(
                "unknownError",
                "Something went wrong while applying your referral code",
                null,
            )
        }
    }

    fun redeemResellerCode(email: String, resellerCode: String, result: MethodChannel.Result) {
        try {
            session.setEmail(email)
            session.setResellerCode(resellerCode)
            sendPurchaseRequest("", email, "", PaymentProvider.ResellerCode, result)
        } catch (t: Throwable) {
            Logger.error(TAG, "Unable to redeem reseller code", t)
            result.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
        }
    }

    private fun createDialog(message: String): ProgressDialog {
        return ProgressDialog.show(
            activity,
            message,
            "",
            true,
            false,
        )
    }

    private fun sendPurchaseRequest(
        planID: String,
        email: String,
        token: String,
        provider: PaymentProvider,
        methodCallResult: MethodChannel.Result,
    ) {
        val currency = LanternApp.getSession().planByID(planID)?.let {
            it.currency
        } ?: "usd"
        Logger.d(TAG, "Sending purchase request: provider $provider; plan ID: $planID; currency: $currency")
        val session = session
        val json: JsonObject = JsonObject()
        json.addProperty("idempotencyKey", System.currentTimeMillis().toString())
        json.addProperty("provider", provider.toString().lowercase())
        json.addProperty("email", email)
        json.addProperty("plan", planID)
        json.addProperty("currency", currency.lowercase())
        json.addProperty("deviceName", session.deviceName())

        when (provider) {
            PaymentProvider.Stripe -> {
                val stripePublicKey = session.stripePubKey()
                stripePublicKey?.let { json.addProperty("stripePublicKey", stripePublicKey) }
                json.addProperty("stripeEmail", email)
                json.addProperty("stripeToken", token)
                json.addProperty("token", token)
            }

            PaymentProvider.GooglePlay -> {
                json.addProperty("token", token)
            }

            PaymentProvider.ResellerCode -> {
                Logger.d(TAG, "Received reseller code purchase request")
                val resellerCode = LanternApp.getSession().resellerCode()
                json.addProperty("provider", "reseller-code")
                json.addProperty("resellerCode", resellerCode!!)
            }

            else -> {}
        }

        lanternClient.post(
            LanternHttpClient.createProUrl("/purchase"),
            LanternHttpClient.createJsonBody(json),
            object : ProCallback {

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    dialog?.dismiss()
                    session.linkDevice()
                    session.setIsProUser(true)
                    Logger.e(TAG, "Purchase Completed: $response")
                    methodCallResult.success("purchaseSuccessful")
                    Logger.d(TAG, "Successful purchase response: $result")
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.e(TAG, "Error with purchase request: $error")
                    Datadog.addError("Error with purchase request: $error", t, mapOf(
                        "provider" to provider.toString().lowercase(),
                        "plan" to planID,
                        "deviceName" to session.deviceName(),
                    ))
                    dialog?.dismiss()
                    methodCallResult.error(
                        "errorMakingPurchase",
                        activity.getString(
                            R.string.error_making_purchase,
                        ),
                        null,
                    )
                }
            },
        )
    }

    companion object {
        private val TAG = PaymentsUtil::class.java.name
        private val lanternClient: LanternHttpClient = LanternApp.getLanternHttpClient()
    }
}
