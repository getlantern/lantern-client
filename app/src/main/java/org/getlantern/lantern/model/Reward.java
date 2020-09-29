package org.getlantern.lantern.model;

import com.google.gson.annotations.SerializedName;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;
import org.getlantern.lantern.R;

import java.lang.Math;

import org.getlantern.mobilesdk.Logger;

public class Reward {

    private static final String TAG = Reward.class.getName();

    @SerializedName("date")
    private String date;

    @SerializedName("code")
    private String code;

    @SerializedName("amount")
    private Double amount;

    @SerializedName("status")
    private String status;

    @SerializedName("redeemed_at")
    private String redeemedAt;

    @SerializedName("auction_time")
    private String auctionTime;

    public String toString() {
        return String.format("Reward{date: %s, code: %s, status: %s}", date, code, status);
    }

    public void setDate(final String date) {
        this.date  = date;
    }

    public String getDate() {
        return date;
    }

    public String getRedeemedAt() {
        return redeemedAt;
    }

    public void setStatus(final String status) {
        this.status = status;
    }

    // returns whether or not this code
    // has been redeemed
    public boolean redeemed() {
        return redeemedAt != null &&
            !redeemedAt.equals("");
    }

    public int getLayout() {
        return redeemed() ? R.layout.redeemed_row :
            R.layout.redemption_row;
    }

    public String getStatus() {
        return status;
    }

    public String getAuctionTime() {
        final String formattedTime = String.format("%s %s", date, auctionTime);
        Logger.debug(TAG, "Auction time is " + formattedTime);
        return formattedTime;
    }

    public void setCode(final String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public void setAmount(final Double amount) {
        this.amount = amount;
    }

    // getTimeLeft calculates the time remaining until the next auction
    // for the given reward
    public Long getTimeLeft() {
        try {
            final TimeZone utc = TimeZone.getTimeZone("UTC");
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM-dd-yyyy h:mm a");
            simpleDateFormat.setTimeZone(utc);
            final Date endDate = simpleDateFormat.parse(getAuctionTime());
            final Calendar rightNow = Calendar.getInstance(utc);
            return Math.abs(endDate.getTime() - rightNow.getTimeInMillis());
        } catch (java.text.ParseException e) {
            Logger.error(TAG, "Unable to parse auction time", e);
        }
        Calendar c = Calendar.getInstance();
        c.add(Calendar.DAY_OF_MONTH, 1);
        c.set(Calendar.HOUR_OF_DAY, 0);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        c.set(Calendar.MILLISECOND, 0);
        return c.getTimeInMillis()-System.currentTimeMillis();
    }

    public static String getTimeLeftStatus(long millisUntilFinished) {
        Date date = new Date(millisUntilFinished);
        DateFormat formatter = new SimpleDateFormat("HH:mm:ss");
        formatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        return formatter.format(date);
    }

    public Double getAmount() {
        return amount;
    }
}
