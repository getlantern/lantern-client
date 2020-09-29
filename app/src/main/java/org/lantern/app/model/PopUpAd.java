package org.lantern.app.model;

import com.google.gson.annotations.SerializedName;

public class PopUpAd {

    @SerializedName("enabled")
    private boolean enabled;

    @SerializedName("url")
    private String url;

    @SerializedName("display_frequency_seconds")
    private Integer displayFrequencySeconds;

    @SerializedName("content.mobile.header")
    private String contentHeader;

    @SerializedName("content.mobile.left.image.resource")
    private String leftImageResource;

    @SerializedName("content.mobile.right.image.resource")
    private String rightImageResource;

    @SerializedName("content.mobile.left.image.url")
    private String leftImageUrl;

    @SerializedName("content.mobile.right.image.url")
    private String rightImageUrl;

    @SerializedName("content.mobile.subheader")
    private String contentSubHeader;

    @SerializedName("content.mobile.button.free")
    private String contentButtonFree;

    @SerializedName("content.mobile.button.pro")
    private String contentButtonPro;

    @SerializedName("content.mobile.website")
    private String contentWebsite;

    @SerializedName("content.mobile.main_screen.pro")
    private String contentMainScreenPro;

    @SerializedName("content.mobile.main_screen.free")
    private String contentMainScreenFree;

    @SerializedName("content.mobile.main_screen.free.details")
    private String contentMainScreenFreeDetails;

    @SerializedName("content.mobile.main_screen.pro.details")
    private String contentMainScreenProDetails;

    @SerializedName("content.mobile.secondary_screen.free")
    private String contentSecondaryScreenFree;

    @SerializedName("content.mobile.secondary_screen.pro")
    private String contentSecondaryScreenPro;

    @SerializedName("content.mobile.renewal.button.url")
    private String renewalButtonUrl;

    @SerializedName("content.mobile.renew.button")
    private String renewalButtonText;

    @SerializedName("content.mobile.buy.lantern.pro.button")
    private String buyLanternProText;

    public Integer getDisplayFrequency() {
        return displayFrequencySeconds;
    }

    public String getContentHeader() {
        return contentHeader;
    }

    public String getContentSubHeader() {
        return contentSubHeader;
    }

    public String getContentWebsite() {
        return contentWebsite;
    }

    public String getLeftImageResource() {
        return leftImageResource;
    }

    public String getRightImageResource() {
        return rightImageResource;
    }

    public String getLeftImageUrl() {
        return leftImageUrl;
    }

    public String getRightImageUrl() {
        return rightImageUrl;
    }

    public String getRenewalButtonUrl() {
        return renewalButtonUrl;
    }

    public String getRenewalButtonText() {
        return renewalButtonText;
    }

    public String getContentButtonFree() {
        return contentButtonFree;
    }

    public String getContentButtonPro() {
        return contentButtonPro;
    }

    public String getContentMainScreenFree() {
        return contentMainScreenFree;
    }

    public String getContentMainScreenPro() {
        return contentMainScreenPro;
    }

    public String getContentMainScreenFreeDetails() {
        return contentMainScreenFreeDetails;
    }

    public String getContentMainScreenProDetails() {
        return contentMainScreenProDetails;
    }


    public String getContentSecondaryScreenFree() {
        return contentSecondaryScreenFree;
    }

    public String getContentSecondaryScreenPro() {
        return contentSecondaryScreenPro;
    }

    public String getBuyLanternProText() {
        return buyLanternProText;
    }

    public boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(final String url) {
        this.url = url;
    }
}
