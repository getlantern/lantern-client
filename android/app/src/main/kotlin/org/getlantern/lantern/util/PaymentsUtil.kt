package org.getlantern.lantern.util

import android.app.Activity
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
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.model.toPaymentProvider
import org.getlantern.mobilesdk.Logger

class PaymentsUtil(private val activity: Activity) {
    private val session: LanternSessionManager = LanternApp.getSession()


    fun submitStripePayment(
        planID: String,
        email: String,
        cardNumber: String,
        expirationDate: String,
        cvc: String,
        methodCallResult: MethodChannel.Result,
    ) {
        try {
            val date = expirationDate.split("/").toTypedArray()
            val card: CardParams =
                CardParams(
                    cardNumber.replace("[\\s]", ""),
                    date[0].toInt(), // expMonth
                    date[1].toInt(), // expYear
                    cvc,
                )

            val stripeKey = session.stripePubKey()
            //Make sure if key null throw error
            if (stripeKey.isNullOrEmpty()) {
                Logger.error(TAG, "Stripe public key is not set")
                methodCallResult.error(
                    "errorSubmittingToStripe",
                    activity.getString(R.string.error_making_purchase),
                    null,
                )
                return
            }
            val stripe = Stripe(activity, session.stripePubKey()!!)
            stripe.createCardToken(
                card,
                callback =
                object : ApiResultCallback<Token> {
                    override fun onSuccess(
                        result: Token,
                    ) {
                        Logger.debug(TAG, "Stripe Card Token Success: $result")

                        sendPurchaseRequest(
                            planID,
                            email,
                            result.id,
                            PaymentProvider.Stripe,
                            methodCallResult,
                        )
                    }

                    override fun onError(
                        e: Exception,
                    ) {
                        Logger.error(TAG, "Error submitting to Stripe: $e")
                        methodCallResult.error(
                            "errorSubmittingToStripe",
                            e.localizedMessage,
                            null,
                        )
                    }
                },
            )
        } catch (t: Throwable) {
            Logger.error(TAG, "Error submitting to Stripe", t)
            methodCallResult.error(
                "errorSubmittingToStripe",
                activity.getString(R.string.error_making_purchase),
                null,
            )
        }
    }


    fun generatePaymentRedirectUrl(
        planID: String,
        email: String,
        provider: String,
        methodCallResult: MethodChannel.Result,
    ) {
        try {
            val provider = provider.toPaymentProvider().toString().lowercase()
            if (provider == null) {
                methodCallResult.error(
                    "unknownError",
                    "$provider is unavailable", // This error message is localized Flutter-side
                    null,
                )
                return
            }
            val params =
                mutableMapOf(
                    "email" to email,
                    "plan" to planID,
                    "provider" to provider,
                    "deviceName" to session.deviceName(),
                )

            sendPaymentRedirectRequest(params, object : ProCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    Logger.error(TAG, "$provider is unavailable ", throwable)
                    methodCallResult.error(
                        "unknownError",
                        "$provider is unavailable", // This error message is localized Flutter-side
                        null,
                    )
                    return
                }

                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    val providerUrl = result!!.get("redirect").asString
                    Logger.debug(
                        TAG,
                        "$provider url is  $providerUrl",
                    )

                    methodCallResult.success(providerUrl)
                }
            })
        } catch (t: Throwable) {
            methodCallResult.error(
                "unknownError",
                "$provider is unavailable", // This error message is localized Flutter-side
                null,
            )
        }
    }

    private fun sendPaymentRedirectRequest(params: Map<String, String>, proCallback: ProCallback) {
        lanternClient.get(
            LanternHttpClient.createProUrl("/payment-redirect", params),
            object : ProCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    proCallback.onFailure(throwable, error)
                    return
                }

                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    proCallback.onSuccess(response, result)

                }
            },
        )
    }

    // getPlanYear splits the given plan ID by hyphen and returns the year the given startas with
    private fun getPlanYear(planID: String): String {
        var plan = planID
        val parts = planID.split("-").toTypedArray()
        if (parts.isNotEmpty()) {
            plan = parts[0]
            Logger.debug(TAG, "Updated plan to have ID $plan")
        }
        return plan
    }

    // Handles Google Play transactions
    fun submitGooglePlayPayment(
        email: String,
        planID: String,
        methodCallResult: MethodChannel.Result,
    ) {

        val inAppBilling = LanternApp.getInAppBilling()
        val currency =
            LanternApp.getSession().planByID(planID)?.let {
                it.currency
            } ?: "usd"
        val plan = getPlanYear(planID)
        Logger.debug(TAG, "Starting in-app purchase for plan with ID $plan")
        inAppBilling.startPurchase(
            activity,
            plan,
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
                        "$plan-$currency",
                        email,
                        tokens[0],
                        PaymentProvider.GooglePlay,
                        methodCallResult,
                    )
                }
            },
        )
    }

    // Applies referral code (before the user has initiated a transaction)
    fun applyRefCode(
        refCode: String,
        methodCallResult: MethodChannel.Result,
    ) {
        try {
            val formBody: FormBody =
                FormBody.Builder()
                    .add("code", refCode).build()
            lanternClient.post(
                LanternHttpClient.createProUrl("/referral-attach"),
                formBody,
                object : ProCallback {
                    override fun onFailure(
                        throwable: Throwable?,
                        error: ProError?,
                    ) {
                        if (error != null && error.message != null) {
                            methodCallResult.error(
                                "unknownError",
                                error.message,
                                null,
                            )
                            return
                        }
                    }

                    override fun onSuccess(
                        response: Response?,
                        result: JsonObject?,
                    ) {
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
            methodCallResult.error(
                "unknownError",
                "Something went wrong while applying your referral code",
                null,
            )
        }
    }

    fun redeemResellerCode(
        email: String,
        resellerCode: String,
        result: MethodChannel.Result,
    ) {
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

    private fun sendPurchaseRequest(
        planID: String,
        email: String,
        token: String,
        provider: PaymentProvider,
        methodCallResult: MethodChannel.Result,
    ) {
        val currency =
            LanternApp.getSession().planByID(planID)?.let {
                it.currency
            } ?: "usd"
        Logger.d(
            TAG,
            "Sending purchase request: provider $provider; plan ID: $planID; currency: $currency"
        )
        val session = session
        val json = JsonObject()
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
                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    Logger.e(TAG, "Purchase Completed: $response")
                    session.linkDevice()
                    lanternClient.userData(object : LanternHttpClient.ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.e(TAG, "User detail : $userData")
                            session.setIsProUser(true)
                            activity.runOnUiThread {

                                methodCallResult.success("purchaseSuccessful")
                            }

                        }

                        override fun onFailure(throwable: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $throwable.message")
                            activity.runOnUiThread {

                                methodCallResult.success("purchaseSuccessful")
                            }

                        }
                    })

                    Logger.d(TAG, "Successful purchase response: $result")
                }

                override fun onFailure(
                    t: Throwable?,
                    error: ProError?,
                ) {

                    Logger.e(TAG, "Error with purchase request: $error")
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
