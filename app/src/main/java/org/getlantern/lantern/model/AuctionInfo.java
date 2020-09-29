package org.getlantern.lantern.model;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;
import com.google.gson.annotations.SerializedName;

import org.getlantern.mobilesdk.Logger;

public class AuctionInfo {
    private static final String TAG = AuctionInfo.class.getName();

    @SerializedName("auctionDatetime")
    private String auctionDatetime;

    @SerializedName("tokensReleased")
    private Double tokensReleased;

    public String getAuctionDatetime() {
        return auctionDatetime;
    }

    public Integer getTokensReleased() {
        if (tokensReleased != null) {
            return tokensReleased.intValue();
        }
        return 0;
    }

    public Long getTimeLeft() {
        try {
            final TimeZone utc = TimeZone.getTimeZone("UTC");
            // 2019-01-08T17:00:00Z
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            simpleDateFormat.setTimeZone(utc);
            final Date endDate = simpleDateFormat.parse(getAuctionDatetime());
            final Calendar rightNow = Calendar.getInstance(utc);
            return Math.abs(endDate.getTime() - rightNow.getTimeInMillis());
        } catch (java.text.ParseException e) {
            Logger.error(TAG, "Unable to parse auction time", e);
        }
        return null;
    }
}
