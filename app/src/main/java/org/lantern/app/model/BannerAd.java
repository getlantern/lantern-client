package org.lantern.app.model;

import com.google.gson.annotations.SerializedName;

public class BannerAd {
    @SerializedName("enabled")
    private boolean enabled;

    @SerializedName("text")
    private String text;

    @SerializedName("url")
    private String url;

    public boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getText() {
        return text;
    }

    public void setText(final String text) {
        this.text = text;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(final String url) {
        this.url = url;
    }
}

