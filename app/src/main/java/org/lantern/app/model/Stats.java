package org.lantern.app.model;

public class Stats {
    private String city, country, countryCode;
    private long httpsUpgrades;
    private long adsBlocked;

    public Stats(String city, String country, String countryCode, long httpsUpgrades, long adsBlocked) {

        this.city = city;
        this.country = country;
        this.countryCode = countryCode;
        this.httpsUpgrades = httpsUpgrades;
        this.adsBlocked = adsBlocked;
    }

    public String getCountry() {
        return country;
    }

    public String getCity() {
        return city;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public String getHTTPSUpgrades() {
        return String.valueOf(httpsUpgrades);
    }

    public String getAdsBlocked() {
        return String.valueOf(adsBlocked);
    }
}
