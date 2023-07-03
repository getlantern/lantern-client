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
                        methodCallResult.error(
                            "errorSubmittingToStripe",
                            error.getLocalizedMessage(),
                            null,
                        )
                    }
                },
            )
        } catch (t: Throwable) {
            Logger.error(TAG, "Error submitting to Stripe", t)
            dialog?.dismiss()
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
            Logger.error(TAG, "BTCPay is unavailable", t)
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
                        Logger.error(
                            TAG,
                            "Error retrieving referral code: $error",
                        )
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
            Logger.error(TAG, "Unable to apply referral code", t)
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
        Logger.d(TAG, "Sending purchase request with provider $provider")
        val session = session
        val formBody: FormBody.Builder = FormBody.Builder()
            .add("idempotencyKey", System.currentTimeMillis().toString())
            .add("provider", provider.toString().lowercase())
            .add("email", email)
            .add("plan", planID)
            .add("currency", currency.lowercase())
            .add("deviceName", session.deviceName())
        Logger.d(TAG, "Currency is $currency")
        when (provider) {
            PaymentProvider.Stripe -> {
                val stripePublicKey = session.stripePubKey()
                stripePublicKey?.let { formBody.add("stripePublicKey", stripePublicKey) }
                formBody.add("stripeEmail", email)
                formBody.add("stripeToken", token)
                formBody.add("token", token)
            }

            PaymentProvider.GooglePlay -> {
                formBody.add("token", token)
            }

            PaymentProvider.ResellerCode -> {
                val resellerCode = LanternApp.getSession().resellerCode()
                resellerCode?.let {
                    formBody.add("provider", "reseller-code")
                    formBody.add("resellerCode", resellerCode)
                }
            }

            else -> {}
        }

        lanternClient.post(
            LanternHttpClient.createProUrl("/purchase"),
            formBody.build(),
            object : ProCallback {

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    dialog?.dismiss()
                    session.linkDevice()
                    session.setIsProUser(true)
                    Logger.e(TAG, "Purchase Completed: $response")
                    methodCallResult.success("purchaseSuccessful")
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.e(TAG, "Error with purchase request: $error .. currency is $currency")
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
