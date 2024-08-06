package org.getlantern.mobilesdk.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class Survey {
    @Expose
    @SerializedName("probability")
    var probability = 0.0

    @Expose
    @SerializedName("enabled")
    var enabled = false

    @Expose
    @SerializedName("userType")
    var userType: String? = null

    @Expose
    @SerializedName("showPlansScreen")
    var showPlansScreen = false

    @Expose
    @SerializedName("campaign")
    var campaign: String? = null

    @Expose
    @SerializedName("url")
    var url: String = ""

    @Expose
    @SerializedName("message")
    var message: String = ""

    @Expose
    @SerializedName("thanks")
    var thanks: String = ""

    @Expose
    @SerializedName("button")
    var button: String = ""
    override fun toString(): String {
        return String.format(
            "URL: %s userType: %s Thanks:%s  Message:%s",
            url, userType, thanks, message
        )
    }
}
