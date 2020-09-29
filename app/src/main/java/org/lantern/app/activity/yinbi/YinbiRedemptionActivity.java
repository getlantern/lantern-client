package org.lantern.app.activity.yinbi;

import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.ClipboardManager;
import android.content.ClipData;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.view.LayoutInflater;

import okhttp3.HttpUrl;

import org.lantern.app.activity.WebViewActivity_;
import org.lantern.app.fragment.ClickSpan;
import org.lantern.app.model.AccountInfo;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.LanternHttpClient;
import org.lantern.app.model.ProError;
import org.lantern.app.model.RedemptionCode;
import org.lantern.app.model.Reward;
import org.lantern.app.model.Utils;
import org.lantern.app.R;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import okhttp3.Response;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class YinbiRedemptionActivity extends YinbiActivity {
    private static final String TAG = YinbiRedemptionActivity.class.getName();

    // redemptionCodes is a map of previously seen redemption codes
    private final Map<String, RedemptionCode> redemptionCodes = new HashMap<String, RedemptionCode>();

    // check for new Yinbi codes every 10 seconds while this screen is open
    private int checkCodesInterval = 10000;

    protected CoordinatorLayout coordinatorLayout;

    private Button copyAllCodesBtn;

    private FrameLayout distributionSection;

    private LinearLayout redemptionSection;

    private TableLayout redemptionTable;

    private TextView okDistributionBtn;

    private Handler fetchCodesHandler;

    protected ProgressDialog dialog;

    private final ClickSpan.OnClickListener clickSpan =
        new ClickSpan.OnClickListener() {
            @Override
            public void onClick() {
                final Intent intent = new Intent(YinbiRedemptionActivity.this,
                        WebViewActivity_.class);
                if (redemptionCodes != null &&
                    redemptionCodes.size() > 0) {
                    intent.putExtra("url", YINBI_SIGNUP);
                } else {
                    intent.putExtra("url", YINBI_WEBSITE);
                }
                startActivity(intent);
            }
    };

     private final BroadcastReceiver screenStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action != null && fetchCodesHandler != null &&
                    action.equals(Intent.ACTION_SCREEN_OFF)) {
                // stop making requests for Yinbi account info if the screen
                // is turned off
                fetchCodesHandler.removeCallbacks(checkCodesRunner);
                fetchCodesHandler = null;
            }
        }
    };

    Runnable checkCodesRunner = new Runnable() {
        @Override
        public void run() {
            try {
                getUserAccountInfo();
            } finally {
                fetchCodesHandler.postDelayed(checkCodesRunner, checkCodesInterval);
            }
        }
    };

    private void closeDialog() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    /**
     * getUserAccountInfo fetches the Yinbi account info for a user via
     * the pro server
    */
    private void getUserAccountInfo() {
        final HttpUrl url = LanternHttpClient.createProUrl("/yinbi/user-account-info");
        lanternClient.get(url, new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Unable to fetch Yinbi account info", throwable);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onUserAccountError(error);
                    }
                });
            }

            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeDialog();
                        updateAccountInfo(result);
                    }
                });
            }
        });
    }

    private void onUserAccountError(final ProError error) {
        closeDialog();
        if (error != null && error.getMessage() != null) {
            Logger.error(TAG, "Pro error fetching Yinbi account info " +
                    error.getMessage());
        }
    }

    private class RewardCountDown extends CountDownTimer {
        private TextView tv;
        private Reward reward;
        public RewardCountDown(long countDownInterval, final Reward reward, final TextView tv) {
            super(reward.getTimeLeft(), countDownInterval);
            this.tv = tv;
            this.reward = reward;
        }

        @Override
        public void onTick(long millisUntilFinished) {
            tv.setText(Reward.getTimeLeftStatus(millisUntilFinished));
        }

        @Override
        public void onFinish() {
            removeRedemptionCode(reward.getCode());
        }
    }

    /**
     * Attaches an onClick listener to the array of views. When clicked
     * on, a popup appears that gives the user details about how Yinbi is
     * distributed
     */
    private void addDistributionPopupListeners(final View[] views) {
        for (View view : views) {
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    toggleDistributionPopup();
                }
            });
        }
    }

    // removeRedemptionCode removes the given code from the map
    // of existing codes. It also removes the corresponding TableRow
    // from the redemption table
    private void removeRedemptionCode(final String code) {
        final RedemptionCode rc = redemptionCodes.get(code);
        // remove the previous TableRow since the reward's
        // redeemed status has changed
        if (rc != null && rc.getRow() != null) {
            redemptionTable.removeView(rc.getRow());
        }
        redemptionCodes.remove(code);
    }

    /**
     * addRedemptionCodes iterates through the list of rewards and creates a
     * new redemption code table row for each
     */
    private void addRedemptionCodes(final List<Reward> rewards) {
        for (final Reward reward : rewards) {
            final String code = reward.getCode();
            final RedemptionCode previousCode = redemptionCodes.get(code);
            if (previousCode != null) {
                final Reward previousReward = previousCode.getReward();
                // row for this redemption code already exists
                if (reward.redeemed() == previousReward.redeemed()) {
                    // the reward's redeemed status hasn't changed. Skip adding
                    // it to the table
                    continue;
                }
                removeRedemptionCode(code);
            }
            Logger.debug(TAG, "Adding new reward " + reward);

            final boolean redeemed = reward.redeemed();
            final int layout = reward.getLayout();
            final TableRow row = (TableRow)LayoutInflater.from(this).inflate(layout,
                    null);
            final TextView date = (TextView)row.findViewById(R.id.date);
            final TextView codeView = (TextView)row.findViewById(R.id.code);
            final TextView status = (TextView)row.findViewById(R.id.status);
            final ImageView helpCircle;
            if (status == null && !redeemed) {
                continue;
            }

            if (!redeemed) {
                helpCircle = (ImageView)row.findViewById(R.id.helpCircle);
            } else {
                helpCircle = null;
            }

            final Double amount = reward.getAmount();
            if (!redeemed && (amount == null || amount == 0)) {
                // if the redemption code has no amount, the corresponding
                // auction is still pending
                status.setTextColor(getResources().getColor(R.color.pink));
                helpCircle.setVisibility(View.VISIBLE);

                addDistributionPopupListeners(new View[]{status, helpCircle, codeView});
                RewardCountDown countDown = new RewardCountDown(1000, reward, status);
                countDown.start();
            } else {
                status.setText(String.format("%d YNB", amount.intValue()));
            }

            date.setText(reward.getDate());
            if (amount != null && amount > 0) {
                codeView.setText(code);
            }
            if (redeemed) {
                // add strikethrough to redemption code that was already
                // redeemed
                codeView.setPaintFlags(codeView.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
            }
            row.setTag(reward.getCode());

            if (!redeemed) {
                redemptionTable.addView(row, 0);
            } else {
                // add redeemed codes to the end of the table
                redemptionTable.addView(row, redemptionTable.getChildCount());
            }

            final RedemptionCode rc = new RedemptionCode(reward, row);
            // add code to the map of existing redemption codes
            redemptionCodes.put(code, rc);
        }
    }

    /**
     * updateAccountInfo parses the JSON response from the pro server
     * and converts it to an AccountInfo. It then adds the given rewards to
     * the redemption code table
     */
    private void updateAccountInfo(final JsonObject result) {
        if (result == null) {
            return;
        }
        final Resources res = getResources();
        final AccountInfo accountInfo = new Gson().fromJson(result, AccountInfo.class);
        if (accountInfo == null) {
            return;
        }

        final List<String> codes = accountInfo.getCodes(true);
        if (codes == null || codes.size() == 0) {
            copyAllCodesBtn.setVisibility(View.GONE);
        }

        addRedemptionCodes(accountInfo.getRewards());
    }

    // getActiveCodes iterates through the map of redemption codes
    // and returns a string of codes that haven't been redeemed yet
    // seperated by newlines
    private String getActiveCodes() {
        final List<String> codes = new ArrayList<String>();
        for (final RedemptionCode rc : redemptionCodes.values()) {
            final Reward reward = rc.getReward();
            if (reward != null && !reward.redeemed()) {
                // add the code to the list if it hasn't been
                // redeemed yet
                codes.add(reward.getCode());
            }
        }
        return TextUtils.join("\n", codes);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(screenStateReceiver);
        if (fetchCodesHandler != null) {
            fetchCodesHandler.removeCallbacks(checkCodesRunner);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (fetchCodesHandler == null) {
            fetchCodesHandler = new Handler();
            checkCodesRunner.run();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        IntentFilter screenStateFilter = new IntentFilter();
        screenStateFilter.addAction(Intent.ACTION_SCREEN_ON);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_OFF);
        registerReceiver(screenStateReceiver, screenStateFilter);

        coordinatorLayout = (CoordinatorLayout)findViewById(R.id.coordinatorLayout);

        redemptionSection = (LinearLayout)findViewById(R.id.redemptionSection);
        distributionSection = (FrameLayout)findViewById(R.id.distributionSection);

        okDistributionBtn = (TextView)findViewById(R.id.okDistributionBtn);
        okDistributionBtn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                toggleDistributionPopup();
            }
        });

        copyAllCodesBtn = (Button)findViewById(R.id.copyAllCodes);
        copyAllCodesBtn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                copyAllCodes(v);
            }
        });

        redemptionTable = (TableLayout)findViewById(R.id.redemptionTable);

        dialog = ProgressDialog.show(this,
                getResources().getString(R.string.loading_yinbi),
                "",
                true, false);
        highlightWebsite(clickSpan, visitYinbi);
    }

    /**
     * When the help circle next to a pending redemption code is clicked on, a
     * popup appears with details about how Yinbi is distributed
     */
    private void toggleDistributionPopup() {
        if (redemptionSection.getVisibility() == View.VISIBLE) {
            redemptionSection.setVisibility(View.GONE);
            distributionSection.setVisibility(View.VISIBLE);
        } else {
            redemptionSection.setVisibility(View.VISIBLE);
            distributionSection.setVisibility(View.GONE);
        }
    }

    private void copyAllCodes(View view) {
        final String codes = getActiveCodes();
        if (codes != null && codes.equals("")) {
            Logger.debug(TAG, "No active redemption codes; skipping copying");
            Utils.showPlainSnackbar(coordinatorLayout,
                    getResources().getString(R.string.no_active_codes));
            return;
        }
        final ClipboardManager clipboard = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        final ClipData clip = ClipData.newPlainText("label", codes);
        clipboard.setPrimaryClip(clip);
        final String snackbarMsg = getResources().getString(R.string.successfully_copied_codes);
        Utils.showPlainSnackbar(coordinatorLayout, snackbarMsg);
    }

    @Override
    public int getLayoutId() {
        return R.layout.yinbi_redemption;
    }
}
