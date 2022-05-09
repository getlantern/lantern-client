package org.getlantern.lantern.model;

import com.google.gson.annotations.SerializedName;

import org.joda.time.Days;
import org.joda.time.Months;
import org.joda.time.LocalDateTime;

import java.util.List;

import org.getlantern.mobilesdk.Logger;

public class ProUser {

    private static final String TAG = ProUser.class.getName();

    public ProUser() {

    }

    @SerializedName("userId")
    private Long userId;

    @SerializedName("token")
    private String token;

    @SerializedName("referral")
    private String referral;

    @SerializedName("email")
    private String email;

    @SerializedName("userStatus")
    private String userStatus;

    @SerializedName("code")
    private String code;

    @SerializedName("subscription")
    private String subscription;

    @SerializedName("expiration")
    private Long expiration;

    @SerializedName("devices")
    private List<Device> devices;

    @SerializedName("currentUserLevel")
    private String currentUserLevel;

    public void setUserId(final Long userId) {
        this.userId = userId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setToken(final String token) {
        this.token = token;
    }

    public String getToken() {
        return token;
    }

    public void setReferral(final String referral) {
        this.referral = referral;
    }

    public String getReferral() {
        return referral;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public String getEmail() {
        return email;
    }

    public void setUserStatus(final String userStatus) {
        this.userStatus = userStatus;
    }

    public String getUserStatus() {
        return userStatus;
    }

    public boolean isProUser() {
        return userStatus != null && userStatus.equals("active");
    }

    public void setCode(final String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public void setExpiration(final Long expiration) {
        this.expiration = expiration;
    }

    public Long getExpiration() {
        return expiration;
    }

    public LocalDateTime getExpirationDate() {
        final Long expiration = getExpiration();
        if (expiration == null) {
            return null;
        }
        return new LocalDateTime(expiration * 1000);
    }

    public Integer monthsLeft() {
        final LocalDateTime expDate = getExpirationDate();
        if (expDate != null) {
            final int months = Months.monthsBetween(LocalDateTime.now(), expDate).getMonths();
            return months;
        }
        return null;
    }

    public Integer daysLeft() {
        final LocalDateTime expDate = getExpirationDate();
        if (expiration != null) {
            final int days = Days.daysBetween(LocalDateTime.now(), expDate).getDays();
            Logger.debug(TAG, "Number of days until Pro account expires " + days);
            return days;
        }
        return null;
    }

    public boolean isActive() {
        return userStatus != null && userStatus.equals("active");
    }

    public boolean isExpired() {
        return userStatus != null && userStatus.equals("expired");
    }

    public List<Device> getDevices() {
        return devices;
    }

    public String toString() {
        return String.format("User ID %d status %s expiration %d Pro user %b", userId, userStatus, expiration, isProUser());
    }

    public String newUserDetails() {
        return String.format("User ID %d referral", userId, referral);
    }
}
