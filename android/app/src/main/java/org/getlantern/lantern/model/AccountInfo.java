package org.getlantern.lantern.model;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class AccountInfo {
    private static final String TAG = AccountInfo.class.getName();

    @SerializedName("rewards")
    private List<Reward> rewards;

    @SerializedName("balance")
    private Integer balance;

    public void setBalance(final Integer balance) {
        this.balance = balance;
    }

    public Integer getBalance() {
        return balance;
    }

    public void setRewards(final List<Reward> rewards) {
        this.rewards = rewards;
    }

    public List<Reward> getRewards() {
        return rewards;
    }

    public List<String> getCodes(final boolean activeOnly) {
        if (rewards == null) {
            return null;
        }
        final List<String> codes = new ArrayList<String>();
        for (final Reward reward : rewards) {
            final boolean validCode = reward != null && reward.getAmount() != null
                && reward.getAmount() > 0;
            if (!activeOnly || validCode) {
                codes.add(reward.getCode());
            }
        }
        return codes;
    }
}
