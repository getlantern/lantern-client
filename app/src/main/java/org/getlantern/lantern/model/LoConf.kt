package org.getlantern.lantern.model

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import okhttp3.HttpUrl
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpCallback

interface LoConfCallback {
    fun onSuccess(loconf: LoConf)
}

class LoConf {
    @Expose
    @SerializedName("surveys")
    var surveys: Map<String, Survey>? = null

    @Expose
    @SerializedName("defaultLocale")
    var defaultLocale: String? = null

    @Expose
    @SerializedName("ads")
    var ads: Map<String, BannerAd>? = null

    @Expose
    @SerializedName("popUpAds")
    var popUpAds: Map<String, PopUpAd>? = null

    companion object {
        private val TAG = LoConf.javaClass.name;
        private const val LOCONF_URL = "https://raw.githubusercontent.com/getlantern/loconf/master/messages.json"
        private const val LOCONF_STAGING_URL = "https://raw.githubusercontent.com/getlantern/loconf/master/test-messages.json"

        /**
         * Fetches the loconf config stored at
         * https://raw.githubusercontent.com/getlantern/loconf/master/messages.json
         *
         * @param cb the callback to execute after the config is fetched
         */
        fun fetch(cb: LoConfCallback) {
            Logger.debug(TAG, "Fetching loconf")
            val loconfUrl: String = if (LanternApp.getSession().useStaging()) {
                LOCONF_STAGING_URL
            } else {
                LOCONF_URL
            }
            fetch(cb, loconfUrl)
        }

        private fun fetch(cb: LoConfCallback, loconfUrl: String?) {
            val builder = HttpUrl.parse(loconfUrl)!!.newBuilder()
            LanternApp.getHttpClient().request("GET", builder.build(), object : HttpCallback {
                override fun onFailure(throwable: Throwable?) {
                    Logger.error(TAG, "Unable to fetch surveys", throwable)
                }

                override fun onSuccess(response: Response?, result: JsonObject) {
                    try {
                        Logger.debug(TAG, "JSON response$result")
                        val loconf = Gson().fromJson(result, LoConf::class.java)
                        cb.onSuccess(loconf)
                    } catch (e: Exception) {
                        Logger.error(TAG, "Unable to parse surveys: " + e.message, e)
                    }
                }
            })
        }
    }
}