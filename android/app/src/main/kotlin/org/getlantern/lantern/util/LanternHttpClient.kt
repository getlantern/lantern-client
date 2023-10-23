package org.getlantern.lantern.model

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import okhttp3.CacheControl
import okhttp3.Call
import okhttp3.Callback
import okhttp3.FormBody
import okhttp3.Headers.Companion.toHeaders
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.MediaType
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpClient
import java.io.IOException

// An OkHttp-Based HTTP client for communicating with the Pro server
open class LanternHttpClient : HttpClient() {
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

    fun get(
        url: HttpUrl,
        cb: ProCallback,
    ) {
        proRequest("GET", url, userHeaders(), null, cb)
    }

    fun post(
        url: HttpUrl,
        body: RequestBody,
        cb: ProCallback,
    ) {
        proRequest("POST", url, userHeaders(), body, cb)
    }

    inline fun <reified T> parseData(row: String): T {
        return Gson().fromJson(row, object : TypeToken<T>() {}.type)
    }

    fun userData(cb: ProUserCallback) {
        val params = mapOf<String, String>("locale" to LanternApp.getSession().language)
        val url = createProUrl("/user-data", params)
        get(
            url,
            object : ProCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    cb.onFailure(throwable, error)
                }

                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    Logger.debug(TAG, "JSON response" + result.toString())
                    result?.let {
                        val user = parseData<ProUser>(result.toString())
                        Logger.debug(TAG, "User ID is ${user.userId}")
                        LanternApp.getSession().storeUserData(user)
                    }
                }
            },
        )
    }

    fun sendLinkRequest(cb: ProCallback?) {
        val url = createProUrl("/user-link-request")
        val formBody =
            FormBody.Builder()
                .add("email", LanternApp.getSession().email())
                .add("deviceName", LanternApp.getSession().deviceName())
                .build()
        post(
            url,
            formBody,
            object : ProCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    if (cb != null) cb.onFailure(throwable, error)
                }

                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    result?.get("error")?.let {
                        onFailure(null, ProError(result))
                    }
                }
            },
        )
    }

    private fun plansMap(fetched: List<ProPlan>): Map<String, ProPlan> {
        val plans = mutableMapOf<String, ProPlan>()
        for (plan in fetched) {
            plan.formatCost()
            plans.put(plan.id, plan)
        }
        return plans
    }

    fun plans(
        cb: PlansCallback,
        inAppBilling: InAppBilling?,
    ) {
        val params =
            mapOf(
                "locale" to LanternApp.getSession().language,
                "countrycode" to LanternApp.getSession().getCountryCode(),
            )
        val url = createProUrl("/plans", params)
        get(
            url,
            object : ProCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    cb.onFailure(throwable, error)
                }

                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    // val mapType = TypeToken<Map<String, List<PaymentMethods>>() {}.type
                    val stripePubKey =
                        result?.get("providers")?.asJsonObject
                            ?.get("stripe")?.asJsonObject?.get("pubKey")?.asString
                    LanternApp.getSession().setStripePubKey(stripePubKey)
                    val fetched = parseData<List<ProPlan>>(result?.get("plans").toString())
                    Logger.debug(TAG, "Pro plans: $fetched")
                    var plans = plansMap(fetched)
                    if (inAppBilling != null) {
                        // this means we're in the play store, use the configured plans from there but
                        // with the renewal bonus from the server side plans
                        val regularPlans = mutableMapOf<String, ProPlan>()
                        plans.forEach { (key, value) ->
                            regularPlans.put(key.substring(0, key.lastIndexOf("-")), value)
                        }
                        plans = inAppBilling.plans
                        plans.forEach { (key, value) ->
                            val regularPlan = regularPlans.get(key)
                            if (regularPlan != null) {
                                value.updateRenewalBonusExpected(regularPlan.renewalBonusExpected)
                            }
                        }
                    }
                    cb.onSuccess(plans)
                }
            },
        )
    }

    fun plansV3(
        cb: PlansV3Callback,
        inAppBilling: InAppBilling?,
    ) {
        val params =
            mapOf(
                "locale" to LanternApp.getSession().language,
                "countrycode" to LanternApp.getSession().getCountryCode(),
            )
        get(
            createProUrl("/plans-v3", params),
            object : ProCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    Logger.error(TAG, "Unable to fetch plans", throwable)
                    cb.onFailure(throwable, error)
                }

                override fun onSuccess(
                    response: Response?,
                    result: JsonObject?,
                ) {
                    val methods =
                        parseData<Map<String, List<PaymentMethods>>>(
                            result?.get("providers").toString(),
                        )
                    val providers = methods.get("android")
                    val fetched = parseData<List<ProPlan>>(result?.get("plans").toString())
                    val plans = plansMap(fetched)
                    if (providers != null) cb.onSuccess(plans, providers)
                }
            },
        )
    }

    private fun proRequest(
        method: String,
        url: HttpUrl,
        headers: Map<String, String>,
        body: RequestBody?,
        cb: ProCallback,
    ) {
        var builder =
            Request.Builder().cacheControl(CacheControl.FORCE_NETWORK)
                .headers(headers.toHeaders())
                .url(url)
        if (method == "POST") {
            var requestBody = if (body != null) body else RequestBody.create(null, ByteArray(0))
            builder = builder.post(requestBody)
        }

        val request = builder.build()
        httpClient.newCall(request).enqueue(
            object : Callback {
                override fun onFailure(
                    call: Call,
                    e: IOException,
                ) {
                    cb.onFailure(e, ProError("", e.message ?: ""))
                }

                override fun onResponse(
                    call: Call,
                    response: Response,
                ) {
                    response.use {
                        if (!response.isSuccessful) {
                            val error = ProError("", "Unexpected response code from server $response")
                            cb.onFailure(null, error)
                            return
                        }
                        val responseData = response.body!!.string()
                        Logger.d(TAG, "Response body " + responseData)
                        val result = JsonParser().parse(responseData).asJsonObject
                        if (result == null) {
                            return
                        } else if (result.get("error") != null) {
                            var error = result.get("error").asString
                            error = "Error making request to $url: $result error: $error"
                            Logger.error(TAG, error)
                            cb.onFailure(null, ProError("", error))
                            return
                        }
                        cb.onSuccess(response, result)
                    }
                }
            },
        )
    }

    interface ProCallback {
        fun onFailure(
            throwable: Throwable?,
            error: ProError?,
        )

        abstract fun onSuccess(
            response: Response?,
            result: JsonObject?,
        )
    }

    interface ProUserCallback {
        fun onFailure(
            throwable: Throwable?,
            error: ProError?,
        )

        fun onSuccess(
            response: Response,
            userData: ProUser,
        )
    }

    interface PlansCallback {
        fun onFailure(
            throwable: Throwable?,
            error: ProError?,
        )

        fun onSuccess(plans: Map<String, ProPlan>)
    }

    interface PlansV3Callback {
        fun onFailure(
            throwable: Throwable?,
            error: ProError?,
        )

        fun onSuccess(
            plans: Map<String, ProPlan>,
            methods: List<PaymentMethods>,
        )
    }

    companion object {
        private const val DEVICE_ID_HEADER = "X-Lantern-Device-Id"
        private const val USER_ID_HEADER = "X-Lantern-User-Id"
        private const val PRO_TOKEN_HEADER = "X-Lantern-Pro-Token"
        private const val APP_VERSION_HEADER = "X-Lantern-Version"
        private const val PLATFORM_HEADER = "X-Lantern-Platform"
        private val TAG = LanternHttpClient::class.java.name

        private var JSON: MediaType? = "application/json; charset=utf-8".toMediaTypeOrNull()

        fun createProUrl(
            uri: String,
            params: Map<String, String?> = mutableMapOf(),
        ): HttpUrl {
            val url = "http://localhost/pro$uri"
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
}
