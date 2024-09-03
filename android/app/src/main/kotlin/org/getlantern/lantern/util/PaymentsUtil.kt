package org.getlantern.lantern.util

import android.app.Activity
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.stripe.android.ApiResultCallback
import com.stripe.android.Stripe
import com.stripe.android.model.CardParams
import com.stripe.android.model.Token
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.mobilesdk.Logger

class PaymentsUtil(private val activity: Activity) {

    val session = LanternApp.getSession()

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
            if (stripeKey.isEmpty()) {
                Logger.error(TAG, "Stripe public key is not set")
                methodCallResult.error(
                    "errorSubmittingToStripe",
                    activity.getString(R.string.error_making_purchase),
                    null,
                )
                return
            }
            val stripe = Stripe(activity, stripeKey)
            stripe.createCardToken(
                card,
                callback =
                object : ApiResultCallback<Token> {
                    override fun onSuccess(
                        result: Token,
                    ) {
                        Logger.debug(TAG, "Stripe Card Token Success: $result")

                        try {
                            session.submitStripePlayPayment(email, planID, result.id)
                            methodCallResult.success("purchaseSuccessful")
                        } catch (e: Exception) {
                            Logger.error(TAG, "Error submitting to Stripe: $e")
                            methodCallResult.error(
                                "unknownError",
                                activity.resources.getString(R.string.error_making_purchase),
                                null,
                            )
                        }
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

    //     Handles Google Play transactions
    fun submitGooglePlayPayment(
        email: String,
        planID: String,
        methodCallResult: MethodChannel.Result,
    ) {
        assert(email.isNotEmpty(), { "Email cannot be empty" })
        assert(planID.isNotEmpty(), { "PlanId cannot be empty" })
        val inAppBilling = LanternApp.getInAppBilling()
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

                    if (purchases[0].purchaseState != Purchase.PurchaseState.PURCHASED) {
                        /*
                        * if the purchase state is not purchased then do not call api
                        * make user pro temporary next user open app it will check the purchase state and call api accordingly
                        * */
                        LanternApp.getSession().setUserPro(true)
                        return
                    }

                    /*
                    * Important: Google Play payment ignores the app-selected locale and currency
                    * It always uses the device's locale so
                    * We need to pass device local it does not mismatch to server while acknolgment*/
                    try {
                        session.submitGooglePlayPayment(email, planID, tokens.first())
                        methodCallResult.success("purchaseSuccessful")
                    } catch (e: Exception) {
                        methodCallResult.error(
                            "errorMakingPurchase",
                            activity.getString(
                                R.string.error_making_purchase,
                            ),
                            null,
                        )
                    }
                }
            },
        )
    }


    fun restorePurchase(result: MethodChannel.Result) {
        val inAppBilling = LanternApp.getInAppBilling()
        inAppBilling.restorePurchase { purchase ->
            if (purchase == null) {
                result.error("purchase_not_found", "No previous purchase found", null)
            }
            result.success("Purchase restored")

        }
    }

    companion object {
        private val TAG = PaymentsUtil::class.java.name
    }
}
