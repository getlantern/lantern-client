package org.getlantern.lantern.model;

import com.google.gson.annotations.SerializedName;

public class Survey {

    @SerializedName("probability")
    private double probability;

    @SerializedName("enabled")
    private boolean enabled;

    @SerializedName("userType")
    private String userType;

    @SerializedName("showPlansScreen")
    private boolean showPlansScreen;

    @SerializedName("campaign")
    private String campaign;

    @SerializedName("url")
    private String url;

    @SerializedName("message")
    private String message;

    @SerializedName("thanks")
    private String thanks;

    @SerializedName("button")
    private String button;

    public double getProbability() {
        return probability;
    }

    public void setProbability(double probability) {
        this.probability = probability;
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

    public void setUrl(String url) {
        this.url = url;
    }
    
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
     
    public String getButton() {
        return button;
    }

    public void setButton(String button) {
        this.button = button;
    }

    public String getThanks() {
        return thanks;
    }

    public void setThanks(String thanks) {
        this.thanks = thanks;
    }

    public String getCampaign() {
        return campaign;
    }

    public void setCampaign(String campaign) {
        this.campaign = campaign;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public boolean getShowPlansScreen() {
        return showPlansScreen;
    }

    public void setShowPlansScreen(boolean showPlansScreen) {
        this.showPlansScreen = showPlansScreen;
    }

    public String toString() {
        return String.format("URL: %s userType: %s Thanks:%s  Message:%s",
                url, userType, thanks, message);
    }
}
