package org.getlantern.mobilesdk.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class PopUpAd {
    @Expose
    @SerializedName("enabled")
    var enabled = false

    @Expose
    @SerializedName("url")
    var url: String? = null

    @Expose
    @SerializedName("display_frequency_seconds")
    val displayFrequency: Int? = null

    @Expose
    @SerializedName("content.mobile.header")
    val contentHeader: String? = null

    @Expose
    @SerializedName("content.mobile.left.image.resource")
    val leftImageResource: String? = null

    @Expose
    @SerializedName("content.mobile.right.image.resource")
    val rightImageResource: String? = null

    @Expose
    @SerializedName("content.mobile.left.image.url")
    val leftImageUrl: String? = null

    @Expose
    @SerializedName("content.mobile.right.image.url")
    val rightImageUrl: String? = null

    @Expose
    @SerializedName("content.mobile.subheader")
    val contentSubHeader: String? = null

    @Expose
    @SerializedName("content.mobile.button.free")
    val contentButtonFree: String? = null

    @Expose
    @SerializedName("content.mobile.button.pro")
    val contentButtonPro: String? = null

    @Expose
    @SerializedName("content.mobile.website")
    val contentWebsite: String? = null

    @Expose
    @SerializedName("content.mobile.main_screen.pro")
    val contentMainScreenPro: String? = null

    @Expose
    @SerializedName("content.mobile.main_screen.free")
    val contentMainScreenFree: String? = null

    @Expose
    @SerializedName("content.mobile.main_screen.free.details")
    val contentMainScreenFreeDetails: String? = null

    @Expose
    @SerializedName("content.mobile.main_screen.pro.details")
    val contentMainScreenProDetails: String? = null

    @Expose
    @SerializedName("content.mobile.secondary_screen.free")
    val contentSecondaryScreenFree: String? = null

    @Expose
    @SerializedName("content.mobile.secondary_screen.pro")
    val contentSecondaryScreenPro: String? = null

    @Expose
    @SerializedName("content.mobile.renewal.button.url")
    val renewalButtonUrl: String? = null

    @Expose
    @SerializedName("content.mobile.renew.button")
    val renewalButtonText: String? = null

    @Expose
    @SerializedName("content.mobile.buy.lantern.pro.button")
    val buyLanternProText: String? = null
}
