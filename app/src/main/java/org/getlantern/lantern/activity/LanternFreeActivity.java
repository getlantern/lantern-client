package org.getlantern.lantern.activity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.Bandwidth;
import org.getlantern.lantern.model.Constants;
import org.getlantern.lantern.model.ProUser;
import org.getlantern.lantern.model.Stats;
import org.getlantern.lantern.model.UserStatus;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class LanternFreeActivity extends BaseActivity {

    private static final String TAG = LanternFreeActivity.class.getName();

    private TextView dataRemaining, upgradeToPro;

    private Button upgradeBtn;

    private ProgressBar dataProgressBar;

    private View dataUsageContainer;

    private String snackbarMsg;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        dataRemaining = (TextView) findViewById(R.id.dataRemaining);
        dataProgressBar = (ProgressBar) findViewById(R.id.dataProgressBar);
        upgradeBtn = (Button) findViewById(R.id.upgradeBtn);
        upgradeToPro = (TextView) findViewById(R.id.upgradeToPro);
        dataUsageContainer = findViewById(R.id.dataUsageContainer);
        addUpgradeToProClickListener(new View[]{upgradeBtn, upgradeToPro});

        if (getIntent() != null) {
            snackbarMsg = getIntent().getStringExtra("snackbarMsg");
        }

        setHeaderLogo(LanternApp.getSession().useVpn());

        Utils.showPlainSnackbar(coordinatorLayout, snackbarMsg);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (LanternApp.getSession().yinbiEnabled()) {
            upgradeToPro.setText(getResources().getString(R.string.upgrade_to_pro_yinbi));
        }
    }

    private void addUpgradeToProClickListener(final View[] views) {
        for (final View view : views) {
            view.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    startActivity(new Intent(LanternFreeActivity.this,
                            LanternApp.getSession().plansActivity()));
                }
            });
        }
    }

    @Override
    public int getLayoutId() {
        return R.layout.activity_lantern_free_main;
    }

    @Override
    protected void onUserDataUpdate(final ProUser user) {
        if (user.isProUser()) {
            startActivity(new Intent(LanternFreeActivity.this, LanternProActivity.class));
            finish();
        }
    }

    private void updateTabText(final int pos, final String newText) {
        final View tab = viewPagerTab.getTabAt(pos);
        if (tab == null) {
            return;
        }
        final TextView title = tab.findViewById(R.id.tabText);
        if (title != null) {
            title.setText(newText);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEventMainThread(final Stats st) {
        if (st != null) {
            updateTabText(Constants.LOCATION_TAB,
                    st.getCountryCode());
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEventMainThread(Bandwidth update) {
        if (update == null) {
            return;
        }

        Logger.debug(TAG, "Received bandwidth data update");

        if (update.getAllowed() <= 0) {
            Logger.debug(TAG, "No data cap for this region.");
            return;
        }
        String amount = String.format("%s%%", update.getPercent());
        updateTabText(Constants.DATA_USAGE_TAB, amount);

        final String text = getString(R.string.data_used,
                String.valueOf(update.getRemaining()),
                org.getlantern.mobilesdk.model.Utils.convertTTSToDateTimeString(update.getTtlSeconds()));

        dataUsageContainer.setVisibility(View.VISIBLE);
        dataProgressBar.setVisibility(View.VISIBLE);
        dataRemaining.setVisibility(View.VISIBLE);
        dataRemaining.setText(text);
        dataProgressBar.setProgress((int) update.getPercent());
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEventMainThread(UserStatus status) {
        updateTabText(Constants.DATA_USAGE_TAB,
                status.monthsLeft());
    }

    public void close(View view) {
        viewPager.setCurrentItem(0);
    }

    private void setHeaderLogo(boolean useVpn) {
        if (useVpn) {
            headerLogo.setImageResource(R.drawable.logo_white);
        } else {
            headerLogo.setImageResource(R.drawable.logo);
        }
    }

    @Override
    public void updateTheme(boolean useVpn) {
        super.updateTheme(useVpn);
        setHeaderLogo(useVpn);
        updateTabIcon(Constants.DATA_USAGE_TAB,
                R.drawable.data_usage_off_icon);
    }
}
