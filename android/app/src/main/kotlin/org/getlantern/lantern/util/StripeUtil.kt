package org.getlantern.lantern.util

import android.app.Activity
import android.app.ProgressDialog
import android.content.Intent
import androidx.annotation.NonNull
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
import org.getlantern.lantern.activity.WelcomeActivity_
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternHttpClient.ProCallback
import org.getlantern.lantern.model.PaymentProvider
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger

class StripeUtil(private val activity: Activity) {

    @JvmField
    protected var dialog: ProgressDialog? = null

    public fun submitPayment(email: String, cardNumber: String, expirationDate: String, 
        cvc: String, methodCallResult: MethodChannel.Result) {
        try {
            val date = expirationDate.split("/").toTypedArray()
            val card: CardParams = CardParams(
                cardNumber.replace("[\\s]", ""),
                date[0].toInt(), // expMonth
                date[1].toInt(), // expYear
                cvc,
            )
            val stripe: Stripe = Stripe(activity, LanternApp.getSession().stripePubKey()!!)
            dialog = createDialog(activity.resources.getString(R.string.processing_payment))
            stripe.createCardToken(
                card,
                callback = object : ApiResultCallback<Token> {
                    override fun onSuccess(@NonNull token: Token) {
                        LanternApp.getSession().setStripeToken(token.id)
                        sendPurchaseRequest(email, methodCallResult)
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

    private fun createDialog(message: String): ProgressDialog {
        return ProgressDialog.show(
            activity,
            message,
            "",
            true,
            false,
        )
    }

    private fun sendPurchaseRequest(email: String, methodCallResult: MethodChannel.Result) {
        Logger.d(TAG, "Sending purchase request with provider $provider")
        val session = LanternApp.getSession()
        val stripePublicKey = session.stripePubKey()
        val stripeToken = session.stripeToken()
        val resellerCode = session.resellerCode()
        val formBody: FormBody.Builder = FormBody.Builder()
            .add("stripeEmail", email)
            .add("idempotencyKey", System.currentTimeMillis().toString())
            .add("provider", provider.toString())
            .add("email", email)
            .add("currency", session.currency().lowercase())
            .add("deviceName", session.deviceName())

        stripePublicKey?.let { formBody.add("stripePublicKey", stripePublicKey) }
        stripeToken?.let { 
            formBody.add("stripeToken", stripeToken)
            formBody.add("token", stripeToken)
        }
        resellerCode?.let { formBody.add("resellerCode", resellerCode) }

        lanternClient.post(
            LanternHttpClient.createProUrl("/purchase"),
            formBody.build(),
            object : ProCallback {

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    dialog?.dismiss()
                    LanternApp.getSession().linkDevice()
                    LanternApp.getSession().setIsProUser(true)                
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
        private val TAG = StripeUtil::class.java.name
        private val lanternClient: LanternHttpClient = LanternApp.getLanternHttpClient()
        private val provider: PaymentProvider = PaymentProvider.Stripe
    }
}
