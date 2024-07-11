package org.getlantern.mobilesdk.model

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.Response
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpCallback
import org.getlantern.mobilesdk.util.HttpClient

fun interface LoConfCallback {
    fun onSuccess(loconf: LoConf)
}

class LoConf {
    @Expose
    @SerializedName("surveys")
    var surveys: Map<String, Survey>? = null

    @Expose
    @SerializedName("defaultLocale")
    var defaultLocale: String? = null


    companion object {
        private val TAG = LoConf::class.java.name

        /**
         * Fetches the loconf config stored at
         * https://raw.githubusercontent.com/getlantern/loconf/master/messages.json
         *
         * @param cb the callback to execute after the config is fetched
         */
        fun fetch(cb: LoConfCallback) {
            Logger.debug(TAG, "Fetching loconf")
            fetch(BuildConfig.LOCONF_URL, cb)
        }

        fun fetch(loconfUrl: String, cb: LoConfCallback) {
//            fetch(LanternApp.getHttpClient(), loconfUrl, cb)
        }

        fun fetch(client: HttpClient, loconfUrl: String, cb: LoConfCallback) {
//            val builder = loconfUrl.toHttpUrlOrNull()!!.newBuilder()
//            client.request(
//                "GET", builder.build(),
//                object : HttpCallback {
//                    override fun onFailure(throwable: Throwable?) {
//                        Logger.error(TAG, "Unable to fetch surveys", throwable)
//                    }
//
//                    override fun onSuccess(response: Response?, result: JsonObject) {
//                        try {
//                            Logger.debug(TAG, "JSON response$result")
//                            val loconf = Gson().fromJson(result, LoConf::class.java)
//                            cb.onSuccess(loconf)
//                        } catch (e: Exception) {
//                            Logger.error(TAG, "Unable to parse surveys: " + e.message, e)
//                        }
//                    }
//                }
//            )
        }
    }
}
