package org.getlantern.lantern.model;

import android.os.CountDownTimer;
import android.widget.TextView;

public class AuctionCountDown extends CountDownTimer {

    private static final int AUCTION_COUNTDOWN_INTERVAL = 1000;

    private boolean isRunning;
    private TextView tv;

    public AuctionCountDown(final AuctionInfo auctionInfo, final TextView tv) {
        super(auctionInfo.getTimeLeft(), AUCTION_COUNTDOWN_INTERVAL);
        this.tv = tv;
        this.isRunning = true;
    }

    @Override
    public void onTick(long millisUntilFinished) {
        tv.setText(Reward.getTimeLeftStatus(millisUntilFinished));
    }

    public boolean isRunning() {
        return isRunning;
    }

    @Override
    public void onFinish() {
        this.isRunning = false;
    }
}
