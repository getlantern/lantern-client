package org.getlantern.mobilesdk.util

import com.google.gson.JsonObject
import com.google.gson.JsonParser
import okhttp3.CacheControl
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Headers.Companion.toHeaders
import okhttp3.HttpUrl
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import okio.Buffer
import org.getlantern.mobilesdk.Logger
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Proxy
import java.util.concurrent.TimeUnit
import kotlin.Throws

interface HttpCallback {
    fun onFailure(throwable: Throwable?)
    fun onSuccess(response: Response?, result: JsonObject)
}

open class HttpClient(@JvmField val httpClient: OkHttpClient) {

    /**
     * Creates a new HTTP client
     *
     * @param proxyHost The host of the local proxy.
     * @param proxyPort The port of the local proxy.
     */
    constructor(proxyHost: String, proxyPort: Int) : this(
        OkHttpClient.Builder()
            .retryOnConnectionFailure(true)
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .proxy(Proxy(Proxy.Type.HTTP, InetSocketAddress(proxyHost, proxyPort)))
            .build()
    )

    fun request(method: String, url: HttpUrl, cb: HttpCallback) {
        request(method, url, null, null, cb)
    }

    fun request(
        method: String,
        url: HttpUrl,
        headers: Map<String, String>?,
        _body: RequestBody?,
        cb: HttpCallback
    ) {
        var body = _body
        var builder = Request.Builder()
            .cacheControl(CacheControl.FORCE_NETWORK)
        if (headers != null) {
            builder = builder.headers(headers.toHeaders())
        }
        builder = builder.url(url)
        if (method == "POST") {
            if (body == null) {
                body = RequestBody.create(null, ByteArray(0))
            }
            builder = builder.post(body)
        }
        val request = builder.build()
        if (headers != null) {
            Logger.debug(
                TAG,
                String.format(
                    "Sending a %s request to %s (Headers: %s)",
                    method, url, request.headers
                )
            )
        } else {
            Logger.debug(TAG, String.format("Sending a %s request to %s", method, url))
        }
        logRequest(request)

        httpClient.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                cb.onFailure(e)
            }

            @Throws(IOException::class)
            override fun onResponse(call: Call, response: Response) {
                val responseBody = response.body
                if (!response.isSuccessful) {
                    Logger.error(TAG, "Request to $url failed")
                    Logger.error(TAG, "Response: $response")
                    if (responseBody != null) {
                        Logger.error(TAG, "Body: " + responseBody.string())
                    }
                    cb.onFailure(null)
                    return
                }
                if (responseBody == null) {
                    Logger.error(TAG, String.format("Invalid response body for %s request", url))
                    return
                }
                val responseData = response.body!!.string()
                val result: JsonObject
                result = try {
                    JsonParser().parse(responseData).asJsonObject
                } catch (t: Throwable) {
                    Logger.error(TAG, "Not a JSON response", t)
                    cb.onFailure(t)
                    return
                }
                if (result["error"] != null) {
                    val error = result["error"].asString
                    Logger.error(TAG, "Error making request to $url:$result error:$error")
                    cb.onFailure(null)
                    return
                }
                cb.onSuccess(response, result)
            }
        })
    }

    companion object {
        var TAG = HttpClient::class.java.name
        private fun logRequest(request: Request) {
            try {
                val copy = request.newBuilder().build()
                val buffer = Buffer()
                copy.body!!.writeTo(buffer)
                Logger.debug(TAG, "New request: " + buffer.readUtf8())
            } catch (e: Exception) {
                Logger.error(TAG, "Unable to log request " + e.message)
            }
        }
    }
}
