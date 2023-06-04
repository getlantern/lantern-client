package org.getlantern.lantern.util

import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import okhttp3.CacheControl
import okhttp3.Call
import okhttp3.Callback
import okhttp3.FormBody
import okhttp3.Headers
import okhttp3.HttpUrl
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import okhttp3.ResponseBody
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.model.ProUser
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpClient
import java.io.IOException
import java.util.List
import java.util.Map

/**
 * An OkHttp-based HTTP client.
 */
public class LanternHttpClient(httpClient: OkHttpClient?) : HttpClient() {

    /**
     * The HTTP headers expected with Pro requests for a user
     */
    private fun userHeaders(): MutableMap<String, String> {
        val headers = mutableMapOf<String, String>()
        headers.put(DEVICE_ID_HEADER, LanternApp.getSession().getDeviceID())
        headers.put(PRO_TOKEN_HEADER, LanternApp.getSession().getToken())
        headers.put(USER_ID_HEADER, String.valueOf(LanternApp.getSession().getUserID()))
        headers.put(PLATFORM_HEADER, "android")
        headers.put(APP_VERSION_HEADER, Utils.appVersion(LanternApp.getAppContext()))
        headers.putAll(LanternApp.getSession().getInternalHeaders())
        return headers
    }

    fun request(
        @NonNull method: String,
        @NonNull url: HttpUrl,
        cb: HttpCallback,
    ) {
        request(method, url, null, null, cb)
    }

    fun request(
        @NonNull method: String,
        @NonNull url: HttpUrl,
        cb: ProCallback,
    ) {
        proRequest(method, url, null, null, cb)
    }

    fun request(
        @NonNull method: String,
        @NonNull url: HttpUrl,
        addProHeaders: Boolean,
        body: RequestBody,
        cb: HttpCallback,
    ) {
        if (addProHeaders) {
            request(method, url, userHeaders(), body, cb)
        } else {
            request(method, url, null, body, cb)
        }
    }

    fun request(
        @NonNull method: String,
        @NonNull url: HttpUrl,
        body: RequestBody,
        cb: ProCallback,
    ) {
        proRequest(method, url, userHeaders(), body, cb)
    }

    /**
     * GET request.
     *
     * @param url request URL
     * @param cb  for notifying the caller of an HTTP response or failure
     */
    fun get(@NonNull url: HttpUrl, cb: ProCallback) {
        proRequest("GET", url, userHeaders(), null, cb)
    }

    /**
     * POST request.
     *
     * @param url  request URL
     * @param body the data enclosed with the HTTP message
     * @param cb   the callback responded with an HTTP response or failure
     */
    fun post(
        @NonNull url: HttpUrl,
        body: RequestBody,
        @NonNull cb: ProCallback,
    ) {
        proRequest("POST", url, userHeaders(), body, cb)
    }

    private fun processPlans(result: JsonObject, cb: PlansCallback, inAppBilling: InAppBilling) {
        val plans = mutableMapOf<String, ProPlan>()
        val stripePubKey = result.get("providers").getAsJsonObject().get("stripe").getAsJsonObject().get("pubKey").getAsString()
        LanternApp.getSession().setStripePubKey(stripePubKey)
        val listType = TypeToken<List<ProPlan>>() {}.getType()
        Logger.debug(TAG, "Plans: " + result.get("plans"))
        val fetched = Json.gson.fromJson(result.get("plans"), listType)
        Logger.debug(TAG, "Pro plans: " + fetched)
        for (plan in fetched) {
            if (plan != null) {
                plan.formatCost()
                Logger.debug(TAG, "New plan is " + plan)
                plans.put(plan.getId(), plan)
            }
        }
        if (inAppBilling != null) {
            // this means we're in the play store, use the configured plans from there but with the
            // renewal bonus from the server side plans
            val regularPlans = mutableMapOf<String, ProPlan>()
            for (entry in plans.entrySet()) {
                // Plans from the pro server have a version suffix, like '1y-usd-9' but plans from
                // the Play Store don't, like '1y-usd'. So we normalize by dropping the version
                // suffix.
                regularPlans.put(entry.getKey().substring(0, entry.getKey().lastIndexOf("-")), entry.getValue())
            }
            plans = inAppBilling.getPlans()
            for (entry in plans.entrySet()) {
                val regularPlan = regularPlans.get(entry.getKey())
                if (regularPlan != null) {
                    entry.getValue().updateRenewalBonusExpected(regularPlan.getRenewalBonusExpected())
                }
            }
        }
        cb.onSuccess(plans)
    }

    fun getPlans(cb: PlansCallback, inAppBilling: InAppBilling) {
        val params = mutableMapOf<String, String>()
        params.put("locale", LanternApp.getSession().getLanguage())
        params.put("countrycode", LanternApp.getSession().getCountryCode())
        val url = createProUrl("/plans", params)
        val plans = mutableMapOf<String, ProPlan>()
        get(
            url,
            object : ProCallback() {
                override fun onFailure(throwable: Throwable, error: ProError) {
                    Logger.error(TAG, "Unable to fetch plans", throwable)
                    cb.onFailure(throwable, error)
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    try {
                        Logger.d(TAG, "JSON response for " + url + ":" + result.toString())
                        processPlans(result, cb, inAppBilling)
                    } catch (e: Exception) {
                        Logger.error(TAG, "Unable to fetch plans: " + e.getMessage(), e)
                    }
                }
            },
        )
    }

    fun prepareYuansfer(vendor: String, cb: YuansferCallback) {
        val url: HttpUrl = createProUrl("/yuansfer-prepay")
        val formBody: RequestBody = FormBody.Builder()
            .add("plan", LanternApp.getSession().getSelectedPlan().getId())
            .add("email", LanternApp.getSession().email())
            .add("deviceName", LanternApp.getSession().deviceName())
            .add("paymentVendor", vendor)
            .build()

        post(
            url,
            formBody,
            object : LanternHttpClient.ProCallback() {
                override fun onFailure(throwable: Throwable, error: ProError) {
                    if (cb != null) {
                        cb.onFailure(throwable, error)
                    }
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    if (result.get("error") != null) {
                        onFailure(null, new ProError(result))
                    } else if (cb != null) {
                        cb.onSuccess((result.get("alipay") as JsonObject).get("payInfo").getAsString())
                    }
                }
            },
        )
    }

    fun sendLinkRequest(cb: ProCallback?) {
        final HttpUrl url = createProUrl("/user-link-request")
        final RequestBody formBody = FormBody.Builder()
            .add("email", LanternApp.getSession().email())
            .add("deviceName", LanternApp.getSession().deviceName())
            .build()

        post(
            url,
            formBody,
            object : LanternHttpClient.ProCallback() {
                override fun onFailure(throwable: Throwable, error: ProError) {
                    if (cb != null) {
                        cb.onFailure(throwable, error)
                    }
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    if (result.get("error") != null) {
                        onFailure(null, new ProError(result))
                    } else if (cb != null) {
                        cb.onSuccess(response, result)
                    }
                }
            },
        )
    }

    /**
     * Returns all user data, including payments, referrals, and all available
     * fields.
     *
     * @param cb for notifying the caller of an HTTP response or failure
     */
    fun userData(cb: ProUserCallback) {
        val params = mutableMapOf<String, String>()
        params.put("locale", LanternApp.getSession().getLanguage())
        val url: HttpUrl = createProUrl("/user-data", params)
        get(
            url,
            object : ProCallback() {
                override fun onFailure(throwable: Throwable, error: ProError) {
                    Logger.error(TAG, "Unable to fetch user data", throwable)
                    if (cb != null) {
                        cb.onFailure(throwable, error)
                    }
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    try {
                        Logger.d(TAG, "JSON response" + result.toString())
                        val user: ProUser? = Json.gson.fromJson(result, ProUser::class.java)
                        if (user != null) {
                            Logger.d(TAG, "User ID is " + user.getUserId())
                            LanternApp.getSession().storeUserData(user)
                        }
                        if (cb != null) {
                            cb.onSuccess(response, user)
                        }
                    } catch (e: Exception) {
                        Logger.error(TAG, "Unable to fetch user data: " + e.getMessage(), e)
                    }
                }
            },
        )
    }

    fun request(
        @NonNull method: String,
        @NonNull url: HttpUrl,
        headers: Map<String, String>,
        body: RequestBody,
        cb: HttpCallback?,
    ) {
        var builder = Request.Builder()
            .cacheControl(CacheControl.FORCE_NETWORK)
        if (headers != null) {
            builder = builder.headers(Headers.of(headers))
        }
        builder = builder.url(url)

        if (method != null && method.equals("POST")) {
            if (body == null) {
                body = RequestBody.create(null, byte[0])
            }
            builder = builder.post(body)
        }
        val request = builder.build()
        httpClient.newCall(request).enqueue(object : Callback() {
            override fun onFailure(call: Call, e: IOException) {
                if (cb != null) {
                    cb.onFailure(e)
                }
            }

            @Throws(IOException::class.java)
            override fun onResponse(call: Call, response: Response) {
                if (!response.isSuccessful()) {
                    Logger.error(TAG, "Request to $url failed")
                    Logger.error(TAG, "Response: $response")
                    val body: ResponseBody = response.body()
                    if (body != null) {
                        Logger.error(TAG, "Body: ${body.string()}")
                    }
                    cb.onFailure(null)
                    return
                }
                cb.onSuccess(response)
            }
        })
    }

    /**
     * Creates a new HTTP request to be enqueued for later execution
     *
     * @param method  the HTTP method
     * @param url     the URL target of this request
     * @param headers the HTTP header fields to add to the request
     * @param body    the body of a POST request
     * @param cb      to notify the caller of an HTTP response or failure
     */
    private fun proRequest(
        @NonNull method: String?,
        @NonNull url: HttpUrl,
        headers: Map<String, String>,
        body: RequestBody?,
        cb: ProCallback,
    ) {
        var builder = Request.Builder()
            .cacheControl(CacheControl.FORCE_NETWORK)
        if (headers != null) {
            builder = builder.headers(Headers.of(headers))
        }
        builder = builder.url(url)

        if (method != null && method.equals("POST")) {
            if (body == null) {
                body = RequestBody.create(null, byte[0])
            }
            builder = builder.post(body)
        }
        val request: Request = builder.build()
        httpClient.newCall(request).enqueue(object : Callback() {
            override fun onFailure(call: Call, e: IOException) {
                if (e != null) {
                    val error = ProError("", e.getMessage())
                    cb.onFailure(e, error)
                }
            }

            @Throws(IOException::class.java)
            override fun onResponse(call: Call, response: Response) {
                if (!response.isSuccessful()) {
                    Logger.error(TAG, "Request to " + url + " failed")
                    Logger.error(TAG, "Response: " + response)
                    val body = response.body()
                    if (body != null) {
                        Logger.error(TAG, "Body: " + body.string())
                    }
                    val error: ProError = ProError("", "Unexpected response code from server")
                    cb.onFailure(null, error)
                    return
                }
                val responseData = response.body().string()
                var result: JsonObject?
                if (responseData == null) {
                    Logger.error(TAG, String.format("Invalid response body for %s request", url))
                    return
                }
                try {
                    result = (JsonParser()).parse(responseData).getAsJsonObject()
                } catch (t: Throwable) {
                    Logger.debug(TAG, "Not a JSON response")
                    final ResponseBody body = ResponseBody.create(null, responseData)
                    cb.onSuccess(response.newBuilder().body(body).build(), null)
                    return
                }
                if (result.get("error") != null) {
                    val error = result.get("error").getAsString()
                    Logger.error(TAG, "Error making request to " + url + ":" + result + " error:" + error)
                    cb.onFailure(null, ProError(result))
                } else if (cb != null) {
                    cb.onSuccess(response, result)
                }
            }
        })
    }

    companion object {
        val TAG = LanternHttpClient::class.java.simpleName

        // the standard user headers sent with most Pro requests
        private const val DEVICE_ID_HEADER = "X-Lantern-Device-Id"
        private const val USER_ID_HEADER = "X-Lantern-User-Id"
        private const val PRO_TOKEN_HEADER = "X-Lantern-Pro-Token"
        private const val APP_VERSION_HEADER = "X-Lantern-Version"
        private const val PLATFORM_HEADER = "X-Lantern-Platform"
        private val JSON = MediaType.parse("application/json; charset=utf-8")

        public fun createProUrl(uri: String, params: Map<String, String>?): HttpUrl {
            val url = String.format("http://localhost/pro%s", uri)
            val builder = HttpUrl.parse(url).newBuilder()
            if (params != null) {
                for (param in params.entrySet()) {
                    builder.addQueryParameter(param.getKey(), param.getValue())
                }
            }
            return builder.build()
        }

        public fun createJsonBody(json: JsonObject): RequestBody {
            return RequestBody.create(JSON, json.toString())
        }
    }

    public interface ProCallback {
        fun onFailure(@Nullable throwable: Throwable, @Nullable error: ProError)
        fun onSuccess(response: Response, result: JsonObject)
    }

    public interface ProUserCallback {
        fun onFailure(@Nullable throwable: Throwable, @Nullable error: ProError)
        fun onSuccess(response: Response, userData: ProUser)
    }

    public interface HttpCallback {
        fun onFailure(@Nullable throwable: Throwable)
        fun onSuccess(response: Response)
    }

    public interface PlansCallback {
        fun onFailure(@Nullable throwable: Throwable, @Nullable error: ProError)
        fun onSuccess(plans: Map<String, ProPlan>)
    }

    public interface YuansferCallback {
        fun onFailure(@Nullable throwable: Throwable, @Nullable error: ProError)
        fun onSuccess(paymentInfo: String)
    }
}
