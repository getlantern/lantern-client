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
import okhttp3.RequestBody
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
                            email,
                            token.id,
                            PaymentProvider.Stripe,
                            methodCallResult,
                        )
                    }

                    override fun onError(@NonNull error: Exception) {
                        dialog?.dismiss()
                        methodCallResult.error("errorSubmittingToStripe", error.getLocalizedMessage(), null)
                    }
                },
            )
        } catch (t: Throwable) {
            Logger.error(TAG, "Error submitting to Stripe", t)
            dialog?.dismiss()
            methodCallResult.error("errorSubmittingToStripe", activity.getString(R.string.error_making_purchase), null)
        }
    }

    fun submitBitcoinPayment(planID: String, email: String, refCode: String, methodCallResult: MethodChannel.Result) {
        try {
            val params = mutableMapOf<String, String>("email" to email, "planID" to planID)
            val formBody: RequestBody = FormBody.Builder().add("email", email).add("planID", planID).build()
            lanternClient.post(
                LanternHttpClient.createProUrl("/payment-redirect", params),
                formBody,
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
        val successfulPurchase = !inAppBilling.startPurchase(
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
                            "Unexpected number of purchased products, not proceeding with purchase: " + tokens.size,
                        )
                        methodCallResult.error(
                            "unknownError",
                            activity.resources.getString(R.string.error_making_purchase),
                            null,
                        )
                        return
                    }

                    methodCallResult.success(null)
                    sendPurchaseRequest(
                        "",
                        tokens[0],
                        PaymentProvider.GooglePlay,
                        methodCallResult,
                    )
                }
            },
        )

        if (!successfulPurchase) {
            methodCallResult.error(
                "unknownError",
                activity.resources.getString(R.string.error_making_purchase),
                null,
            )
        }
    }

    // Applies referral code (before the user has initiated a transaction)
    fun applyRefCode(refCode: String, result: MethodChannel.Result) {
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
                            result.error(
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
                            "Successfully redeemed referral code$refCode",
                        )
                        session.setReferral(refCode)
                    }
                },
            )
        } catch (t: Throwable) {
            Logger.error(TAG, "Unable to apply referral code", t)
            result.error(
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
            sendPurchaseRequest(email, "", PaymentProvider.ResellerCode, result)
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

    private fun createDialog(message: String): ProgressDialog {
        return ProgressDialog.show(
            activity,
            message,
            "",
            true,
            false,
        )
    }

    private fun sendPurchaseRequest(email: String, token: String, provider: PaymentProvider, methodCallResult: MethodChannel.Result) {
        Logger.d(TAG, "Sending purchase request with provider $provider")
        val session = session
        val resellerCode = session.resellerCode()
        val formBody: FormBody.Builder = FormBody.Builder()
            .add("idempotencyKey", System.currentTimeMillis().toString())
            .add("provider", provider.toString())
            .add("email", email)
            .add("currency", session.currency().lowercase())
            .add("deviceName", session.deviceName())

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
            else -> {}
        }
        resellerCode?.let { formBody.add("resellerCode", resellerCode) }

        lanternClient.post(
            LanternHttpClient.createProUrl("/purchase"),
            formBody.build(),
            object : ProCallback {

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    dialog?.dismiss()
                    session.linkDevice()
                    session.setIsProUser(true)
                    methodCallResult.success("purchaseSuccessful")
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    val errorMakingPurchase = activity.getString(
                        R.string.error_making_purchase,
                    )
                    Logger.e(TAG, "Error with purchase request: $error")
                    dialog?.dismiss()
                    activity.showErrorDialog(errorMakingPurchase)
                }
            },
        )
    }

    companion object {
        private val TAG = PaymentsUtil::class.java.name
        private val lanternClient: LanternHttpClient = LanternApp.getLanternHttpClient()
    }
}
