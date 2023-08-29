package org.getlantern.lantern.model

import androidx.annotation.NonNull
import androidx.annotation.Nullable

import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken

import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.util.Json
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpClient

import okhttp3.CacheControl
import okhttp3.Call
import okhttp3.Callback
import okhttp3.FormBody
import okhttp3.Headers
import okhttp3.Headers.Companion.toHeaders
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.MediaType
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import okhttp3.ResponseBody
import okio.Buffer

open class LanternHttpClient : HttpClient() {
    companion object {
        private const val DEVICE_ID_HEADER = "X-Lantern-Device-Id"
        private const val USER_ID_HEADER = "X-Lantern-User-Id"
        private const val PRO_TOKEN_HEADER = "X-Lantern-Pro-Token"
        private const val APP_VERSION_HEADER = "X-Lantern-Version"
        private const val PLATFORM_HEADER = "X-Lantern-Platform"

        private var JSON: MediaType? = "application/json; charset=utf-8".toMediaTypeOrNull()

        fun createProUrl(uri: String, params: Map<String, String?> = mutableMapOf()): HttpUrl {
            val url = "http://localhost/pro${uri}"
            var builder = url.toHttpUrl().newBuilder()
            for ((key, value) in params) {
                builder.addQueryParameter(key, value)
            }
            return builder.build()
        }

        fun createJsonBody(json: JsonObject): RequestBody {
            return RequestBody.create(JSON, json.toString())
        }
    }

    private fun userHeaders(): MutableMap<String, String> {
        val headers = mutableMapOf<String, String>()
        headers.put(DEVICE_ID_HEADER, LanternApp.getSession().deviceID)
        headers.put(PRO_TOKEN_HEADER, LanternApp.getSession().token)
        headers.put(USER_ID_HEADER, LanternApp.getSession().userID.toString())
        headers.put(PLATFORM_HEADER, "android")
        headers.put(APP_VERSION_HEADER, Utils.appVersion(LanternApp.getAppContext()))
        headers.putAll(LanternApp.getSession().getInternalHeaders())
        return headers
    }

    fun get(url: HttpUrl, cb: ProCallback) {
        proRequest("GET", url, userHeaders(), null, cb)
    }

    fun post(url: HttpUrl, body: RequestBody, cb: ProCallback) {
        proRequest("POST", url, userHeaders(), body, cb)
    }

    fun userData(cb: ProUserCallback) {
        val params = mapOf<String, String>("locale" to LanternApp.getSession().language)
        val url = createProUrl("/user-data", params)
        get(url, object : ProCallback {
            override fun onFailure(throwable: Throwable?, error: ProError?) {

            }

            override fun onSuccess(response: Response?, result: JsonObject?) {

            }
        })
    }

    fun sendLinkRequest(cb: ProCallback?) {
        val url = createProUrl("/user-link-request")
        val formBody = FormBody.Builder()
            .add("email", LanternApp.getSession().email())
            .add("deviceName", LanternApp.getSession().deviceName())
            .build()
        post(url, formBody, object : ProCallback {
            override fun onFailure(throwable: Throwable?, error: ProError?) {
                if (cb != null) cb.onFailure(throwable, error)
            }

            override fun onSuccess(response: Response?, result: JsonObject?) {

            }
        })
    }

    fun plans(cb: PlansCallback, inAppBilling: InAppBilling?) {
        val params = mapOf("locale" to LanternApp.getSession().language, 
            "countrycode" to LanternApp.getSession().getCountryCode())
        val url = createProUrl("/plans", params)
        val plans = mapOf<String, ProPlan>()
        get(url, object : ProCallback {
            override fun onFailure(throwable: Throwable?, error: ProError?) {
                if (cb != null) cb.onFailure(throwable, error)
            }

            override fun onSuccess(response: Response?, result: JsonObject?) {

            }

        })
    }

    fun plansV3(cb: PlansV3Callback, inAppBilling: InAppBilling?) {

    }

    private fun proRequest(method: String, url: HttpUrl, headers: Map<String, String>,
        body: RequestBody?, cb: ProCallback) {
        var builder = Request.Builder().cacheControl(CacheControl.FORCE_NETWORK)
        if (headers != null) {
            builder = builder.headers(headers.toHeaders())
        }
    }

    interface ProCallback {
        fun onFailure(throwable: Throwable?, error: ProError?)
        abstract fun onSuccess(response: Response?, result: JsonObject?)
    }

    interface ProUserCallback {
        fun onFailure(throwable: Throwable?, error: ProError?)
        fun onSuccess(response: Response, userData: ProUser)
    }

    interface PlansCallback {
        fun onFailure(throwable: Throwable?, error: ProError?)
        fun onSuccess(plans: Map<String, ProPlan>)        
    }

    interface PlansV3Callback {
        fun onFailure(throwable: Throwable?, error: ProError?)
        fun onSuccess(plans: Map<String, ProPlan>, methods: List<PaymentMethods>)              
    }
}
