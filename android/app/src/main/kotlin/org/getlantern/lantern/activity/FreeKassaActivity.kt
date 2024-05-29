package org.getlantern.lantern.activity

import android.annotation.SuppressLint
import android.content.Intent
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.ImageView
import android.widget.ProgressBar
import com.google.gson.JsonObject
import okhttp3.FormBody
import okhttp3.Response
import org.androidannotations.annotations.AfterViews
import org.androidannotations.annotations.EActivity
import org.androidannotations.annotations.Extra
import org.androidannotations.annotations.ViewById
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.util.FreeKassa
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger
import org.json.JSONException


// See here for an overview of how Freekassa purchase flow works in Lantern:
// https://github.com/getlantern/pro-server-neu/blob/5b845fb5f7c13144b1fabe64cc42aea485abc2a6/README.md?plain=1#L152
@EActivity(R.layout.freekassa_layout)
open class FreeKassaActivity : BaseFragmentActivity() {
    companion object {
        private val TAG = FreeKassaActivity::class.java.name
        private const val secretWordOne = "={WBvUg}wci5qx("
        private const val merchantId = 25970
        private val lanternHTTPClient: LanternHttpClient = LanternApp.getLanternHttpClient()
    }

    // @JvmField is necessary when working with Kotlin and the
    // AndroidAnnotations library:
    // https://github.com/androidannotations/androidannotations/wiki/Kotlin-support.
    // Also, no need to assert whether the @ViewById fields are null or not
    // during code execution: AndroidAnnotations library runs compile-time
    // checks for that and will fail a build if they're faulty
    @ViewById
    @JvmField
    protected var webView: WebView? = null

    @ViewById
    @JvmField
    protected var closeButton: ImageView? = null


    @ViewById
    @JvmField
    protected var progressBar: ProgressBar? = null

    @Extra
    @JvmField
    protected var userEmail: String? = null

    @Extra
    @JvmField
    protected var planID: String? = null

    @Extra
    @JvmField
    protected var currencyPrice: String? = null

    @AfterViews
    fun afterViews() {
        assertIntentExtras()
        closeButton?.setOnClickListener(View.OnClickListener {
            finish()
        })
        makeRequestToPrepayHandler(
            { transactionID: String -> displayWebView(transactionID) },
            { error: String -> showErrorDialog(error) }
        )
    }

    private fun assertIntentExtras() {
        if (userEmail == null) {
            throw RuntimeException("User email is null. This should never happen")
        }
    }

    private fun makeRequestToPrepayHandler(onSuccess: (String) -> Unit, onError: (String) -> Unit) {
        val params = hashMapOf(
            "locale" to LanternApp.getSession().language,
        )
        val url = LanternHttpClient.createProUrl("/freekassa-prepay", params)
        val requestBodyParams = FormBody.Builder()
            .add("deviceName", LanternApp.getSession().deviceName())
            .add("plan", planID!!)
            .add("email", userEmail!!)
            .build()

        Logger.d(TAG, "Sending request to Freekassa prepay handler")

        lanternHTTPClient.post(
            url,
            requestBodyParams,
            object : LanternHttpClient.ProCallback {
                override fun onFailure(throwable: Throwable?, error: ProError?) {
                    Logger.error(TAG, error.toString())
                    onError(error.toString())
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    Logger.debug(TAG, "Prepay handler response: $response")
                    if (response == null) {
                        val error = "Unable to prepare FreeKassa: Response is null"
                        Logger.error(TAG, error)
                        onError(error)
                        return
                    }
                    if (!response.isSuccessful) {
                        val error = "Unable to prepare FreeKassa: Response is not successful"
                        Logger.error(TAG, error)
                        onError(error)
                        return
                    }
                    if (result == null) {
                        val error = "Unable to prepare FreeKassa: Result is null"
                        Logger.error(TAG, error)
                        onError(error)
                        return
                    }

                    try {
                        if (result.has("error")) {
                            val error = result.get("error").asString
                            Logger.error(TAG, error)
                            onError(error)
                            return
                        }
                        if (!result.has("transactionId")) {
                            val error = "Unable to prepare FreeKassa: Transaction ID is null"
                            Logger.error(TAG, error)
                            onError(error)
                            return
                        }
                        val transactionID: String = result.get("transactionId").asString
                        displayWebView(transactionID)
                    } catch (e: JSONException) {
                        val error = "Unable to parse FreeKassa prepay response: $response"
                        Logger.error(TAG, error)
                        onError(error)
                    }
                }
            }
        )
    }

    // convertToPro assumes we've done a successful purchase since
    // "freekassa-success" callback was intercepted. There is a chance the
    // purchase fails (for whatever reason). In this case, the user will STILL
    // be shown a "Welcome to Pro" screen, but they'll never be pro and the UI
    // won't change when they're back to the main screen.
    //
    // You can simulate this by generating a fake credit card number (e.g.,
    // with this
    // https://ccardgenerator.com/generate-mastercard-card-numbers.php) and
    // using it to make a purchase. The purchase state will be "pending" in the
    // backend, but it'll eventually fail.
    private fun convertToPro() {
        val intent = Intent(this, MainActivity::class.java)
        LanternApp.getSession().linkDevice()
        LanternApp.getSession().setIsProUser(true)
        intent.putExtra("provider", "freekassa")
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        this.startActivity(intent)
        this.finish()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun displayWebView(transactionID: String) {
        // plan.currencyPrice is for example 4800 usd for a 1 year plan
        // (supposed to be 48.00 usd)
        val price = currencyPrice?.let {
            it.toLong() / 100
        }
        webView!!.post {
            webView!!.settings.javaScriptEnabled = true
            webView!!.settings.domStorageEnabled = true
            webView!!.webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView, url: String) {
                    Logger.d(TAG, "Finished loading url: $url")
                    progressBar!!.visibility = View.GONE
                    if (url.contains("freekassa-success")) {
                        Logger.d(
                            TAG,
                            "FreeKassa purchase worked just fine. Catching the redirect and exiting"
                        )
                        view.clearHistory()
                        // This opens a new activity, so we need to finish this one
                        // so that the user can't go back to it
                        convertToPro()
                    } else if (url.contains("freekassa-error")) {
                        view.clearHistory()
                        Logger.e(TAG, "FreeKassa purchase failed")
                        showErrorDialog("FreeKassa purchase failed")
                        finish()
                    }
                }
            }

            val plan = LanternApp.getSession().planByID(planID!!)!!
            val currency = plan.currency
            val u = FreeKassa.getPayURI(
                merchantId,
                price!!,
                currency,
                planID!!,
                secretWordOne,
                LanternApp.getSession().language,
                userEmail!!,
                mapOf(
                    "transactionid" to transactionID,
                    "paymentcurrency" to currency
                )
            )
            Logger.d(TAG, "freeKassa Payment URI: $u")
            webView!!.loadUrl(u.toString())
        }
    }
}
