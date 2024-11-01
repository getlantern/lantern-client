package org.getlantern.lantern.plausible

import android.net.Uri
import androidx.annotation.VisibleForTesting
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import okhttp3.Call
import okhttp3.Callback
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.URI
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

internal interface PlausibleClient {
    // See [Plausible.event] for details on parameters.
    // @return true if the event was successfully processed and false if not
    fun event(
        domain: String,
        name: String,
        url: String,
        referrer: String,
        screenWidth: Int,
        props: Map<String, Any?>? = null,
    ) {
        var correctedUrl = Uri.parse(url)
        if (correctedUrl.scheme.isNullOrBlank()) {
            correctedUrl = correctedUrl.buildUpon().scheme("app").build()
        }
        if (correctedUrl.authority.isNullOrBlank()) {
            correctedUrl = correctedUrl.buildUpon().authority("localhost").build()
        }
        return event(
            Event(
                domain,
                name,
                correctedUrl.toString(),
                referrer,
                screenWidth,
                props?.mapValues { (_, v) -> v.toString() },
            ),
        )
    }

    fun event(event: Event)
}

// The primary client for sending events to Plausible. It will attempt to send events immediately,
// caching them to disk to send later upon failure.
internal class NetworkFirstPlausibleClient(
    private val config: PlausibleConfig,
    coroutineContext: CoroutineContext = Dispatchers.IO,
) : PlausibleClient {
    private val coroutineScope = CoroutineScope(coroutineContext)

    init {
        coroutineScope.launch {
            config.eventDir.mkdirs()
            config.eventDir.listFiles()?.forEach {
                if (!it.exists()) return@forEach
                try {
                    val event = Event.fromJson(it.readText())
                    if (event == null) {
                        Logger.e(TAG, "Failed to decode event JSON, discarding")
                        it.delete()
                        return@forEach
                    }
                    postEvent(event)
                } catch (e: FileNotFoundException) {
                    Logger.e(TAG, "Could not open event file", e)
                    return@forEach
                } catch (e: IOException) {
                    return@forEach
                }
                it.delete()
            }
        }
    }

    override fun event(event: Event) {
        coroutineScope.launch {
            suspendEvent(event)
        }
    }

    @VisibleForTesting
    internal suspend fun suspendEvent(event: Event) {
        try {
            postEvent(event)
        } catch (e: IOException) {
            if (!config.retryOnFailure) return
            val file = File(config.eventDir, "event_${System.currentTimeMillis()}.json")
            file.writeText(event.toJson())
            var retryAttempts = 0
            var retryDelay = 1000L
            while (retryAttempts < 5) {
                delay(retryDelay)
                retryDelay =
                    when (retryDelay) {
                        1000L -> 60_000L
                        60_000L -> 360_000L
                        360_000L -> 600_000L
                        else -> break
                    }
                try {
                    postEvent(event)
                    file.delete()
                    break
                } catch (e: IOException) {
                    retryAttempts++
                }
            }
        }
    }

    // postEvent sends an event directly to the Plausible API. The X-Forwarded-For header is used to explicitly set the
    // IP address of the client. Since we are sending events from our proxies, we have to make sure to override this header
    // with the correct IP address of the client. Plausible does not store the raw value of the IP address: it is only used
    // to calculate a unique user_id and to fill in the Location report with the country, region and city data of the visitor.
    private suspend fun postEvent(event: Event) {
        if (!config.enable) {
            Logger.e("Plausible", "Plausible disabled, not sending event: $event")
            return
        }
        val session = LanternApp.session
        Logger.d(TAG, "Sending event ${event.toJson()}")
        val body = event.toJson().toRequestBody("application/json".toMediaType())
        val url =
            config.host
                .toHttpUrl()
                .newBuilder()
                .addPathSegments("api/event")
                .build()

        val request =
            Request.Builder()
                .url(url)
                .addHeader("User-Agent", config.userAgent)
                .addHeader("X-Forwarded-For", session.ipAddress ?: "127.0.0.1")
                .addHeader("Content-Type", "application/json")
                .post(body)
                .build()
        suspendCancellableCoroutine { continuation ->
            val call = okHttpClient.newCall(request)
            continuation.invokeOnCancellation {
                call.cancel()
            }

            call.enqueue(
                object : Callback {
                    override fun onFailure(
                        call: Call,
                        e: IOException,
                    ) {
                        Logger.e(TAG, "Failed to send event to backend $e")
                        continuation.resumeWithException(e)
                    }

                    override fun onResponse(
                        call: Call,
                        response: Response,
                    ) {
                        response.use { res ->
                            if (res.isSuccessful) {
                                continuation.resume(Unit)
                            } else {
                                val e =
                                    IOException(
                                        "Received unexpected response: ${res.code} ${res.body?.string()}",
                                    )
                                onFailure(call, e)
                            }
                        }
                    }
                },
            )
        }
    }

    val okHttpClient: OkHttpClient by lazy {
        val session = LanternApp.session
        val hTTPAddr = session.hTTPAddr
        if (hTTPAddr.isEmpty()) {
            OkHttpClient()
        } else {
            val uri = URI("http://" + hTTPAddr)
            Logger.d(TAG, "Setting http proxy address to $uri")
            val proxy =
                Proxy(
                    Proxy.Type.HTTP,
                    InetSocketAddress(
                        "127.0.0.1",
                        uri.port,
                    ),
                )
            OkHttpClient.Builder().proxy(proxy).build()
        }

    }

    companion object {
        private val TAG = NetworkFirstPlausibleClient::class.java.simpleName
    }
}
