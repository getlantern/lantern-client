package org.lantern.app.model;

import java.util.Map;

import com.google.gson.annotations.SerializedName;

public class LoConf {
    @SerializedName("surveys")
    private Map<String, Survey> surveys;

    @SerializedName("defaultLocale")
    private String defaultLocale;

    @SerializedName("ads")
    private Map<String, BannerAd> ads;

    @SerializedName("popUpAds")
    private Map<String, PopUpAd> popUpAds;

    public void setAds(final Map<String, BannerAd> ads) {
        this.ads = ads;
    }

    public Map<String, BannerAd> getAds() {
        return ads;
    }

    public void setPopUpAds(final Map<String, PopUpAd> popUpAds) {
        this.popUpAds = popUpAds;
    }

    public Map<String, PopUpAd> getPopUpAds() {
        return popUpAds;
    }

    public void setSurveys(final Map<String, Survey> surveys) {
        this.surveys = surveys;
    }

    public Map<String, Survey> getSurveys() {
        return surveys;
    }

    public void setDefaultLocale(final String defaultLocale) {
        this.defaultLocale = defaultLocale;
    }

    public String getDefaultLocale() {
        return defaultLocale;
    }
}
