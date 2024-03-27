package org.getlantern.lantern.model;

public class Stats {
    private final String city;
    private final String country;
    private final String countryCode;
    private final long httpsUpgrades;
    private final long adsBlocked;
    private final boolean hasSucceedingProxy;

    public Stats(
            String city,
            String country,
            String countryCode,
            long httpsUpgrades,
            long adsBlocked,
            boolean hasSucceedingProxy) {
        this.city = city;
        this.country = country;
        this.countryCode = countryCode;
        this.httpsUpgrades = httpsUpgrades;
        this.adsBlocked = adsBlocked;
        this.hasSucceedingProxy = hasSucceedingProxy;
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

    public boolean isHasSucceedingProxy() {
        return hasSucceedingProxy;
    }
}
