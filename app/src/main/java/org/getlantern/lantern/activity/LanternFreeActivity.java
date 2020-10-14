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
import org.getlantern.lantern.model.Stats;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class LanternFreeActivity extends BaseActivity {

    private static final String TAG = LanternFreeActivity.class.getName();

    private String snackbarMsg;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getIntent() != null) {
            snackbarMsg = getIntent().getStringExtra("snackbarMsg");
        }

        setHeaderLogo(LanternApp.getSession().useVpn());

        Utils.showPlainSnackbar(coordinatorLayout, snackbarMsg);
    }

    @Override
    public int getLayoutId() {
        return R.layout.activity_lantern_free_main;
    }

    private void setHeaderLogo(boolean useVpn) {
        if (useVpn) {
            headerLogo.setImageResource(R.drawable.lantern_logo_white);
        } else {
            headerLogo.setImageResource(R.drawable.lantern_logo);
        }
    }

    @Override
    public void updateTheme(boolean useVpn) {
        super.updateTheme(useVpn);
        setHeaderLogo(useVpn);
    }
}
