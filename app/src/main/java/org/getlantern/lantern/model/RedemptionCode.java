package org.getlantern.lantern.model;

import androidx.annotation.NonNull;
import android.widget.TableRow;

public class RedemptionCode {

    private static final String TAG = RedemptionCode.class.getName();
    private Reward reward;
    private TableRow row;

    public RedemptionCode(@NonNull final Reward reward, @NonNull final TableRow row) {
        this.reward = reward;
        this.row = row;
    }

    public TableRow getRow() {
        return row;
    }

    public Reward getReward() {
        return reward;
    }
}

