package org.lantern.app.activity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.lantern.app.activity.yinbi.YinbiRenewActivity;
import org.lantern.app.model.Constants;
import org.lantern.app.model.ProUser;
import org.lantern.app.model.Stats;
import org.lantern.app.model.UserStatus;
import org.lantern.app.R;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class LanternProActivity extends BaseActivity {

    private static final String TAG = LanternProActivity.class.getName();

    private LinearLayout renewProSection;

    private Button renewBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        renewProSection = (LinearLayout)findViewById(R.id.renewProSection);

        renewBtn = (Button)findViewById(R.id.renewBtn);
        renewBtn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                final Class activity = session.plansActivity();
                startActivity(new Intent(LanternProActivity.this, activity));
            }
        });

        setHeaderLogo(session.useVpn());
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (session.yinbiEnabled()) {
            renewProSection.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void onUserDataUpdate(final ProUser user) {
        final View tab = (View)viewPagerTab.getTabAt(Constants.PRO_USER_TAB);
        if (tab != null) {
            final TextView title = (TextView)tab.findViewById(R.id.tabText);
            title.setText(session.getProTimeLeft());
        }
    }

    @Override
    public int getLayoutId() {
        return R.layout.activity_lantern_pro_main;
    }

    private void updateTabText(final int pos, final String newText) {
        final View tab = (View)viewPagerTab.getTabAt(pos);
        if (tab == null) {
            return;
        }
        final TextView title = (TextView)tab.findViewById(R.id.tabText);
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
    public void onEventMainThread(UserStatus status) {
        updateTabText(Constants.PRO_USER_TAB,
                status.monthsLeft());
    }

    public void close(View view) {
        viewPager.setCurrentItem(0);
    }

    private void setHeaderLogo(boolean useVpn) {
        if (useVpn) {
            headerLogo.setImageResource(R.drawable.lantern_pro_logo_white);
        } else {
            headerLogo.setImageResource(R.drawable.lantern_pro_logo);
        }

    }

    @Override
    public void updateTheme(boolean useVpn) {
        super.updateTheme(useVpn);
        setHeaderLogo(useVpn);
        updateTabIcon(Constants.PRO_USER_TAB,
                R.drawable.time_small_icon);
    }
}
