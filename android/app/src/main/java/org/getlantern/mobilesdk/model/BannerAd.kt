package org.getlantern.mobilesdk.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class BannerAd {
    @Expose
    @SerializedName("enabled")
    var enabled = false

    @Expose
    @SerializedName("text")
    var text: String? = null

    @Expose
    @SerializedName("url")
    var url: String? = null
}