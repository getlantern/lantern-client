package org.lantern.app.activity;

import android.content.res.Resources;
import androidx.fragment.app.FragmentActivity;
import android.text.Html;
import android.widget.CompoundButton;
import android.widget.TextView;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

import com.kyleduo.switchbutton.SwitchButton;

import org.lantern.app.LanternApp;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.SessionManager;
import org.lantern.app.R;

@EActivity(R.layout.settings)
public class SettingsActivity extends FragmentActivity {
    private static final String TAG = SettingsActivity.class.getName();
    private static final String proxyAllDescFmt = "&#8226; %s<br />%s<br />&#8226; %s<br />%s";
    private static final SessionManager session = LanternApp.getSession();

    @ViewById
    TextView proxyAllDesc;

    @ViewById
    SwitchButton proxyAll;

    @AfterViews
    void afterViews() {
        if (session.proxyAll()) {
            proxyAll.setCheckedImmediatelyNoEvent(true);
            proxyAll.setBackColorRes(R.color.setting_on);
        }

        setDescText();

        proxyAll.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                proxyAll(isChecked);
            }
        });
    }

    private void setDescText() {
        final Resources res = getResources();
        proxyAllDesc.setText(Html.fromHtml(String.format(
            proxyAllDescFmt, res.getString(R.string.proxy_all_on_header),
            res.getString(R.string.proxy_all_on),
            res.getString(R.string.proxy_all_off_header),
            res.getString(R.string.proxy_all_off)
        )));
    }

    public void proxyAll(boolean on) {
        // store updated user preference
        session.setProxyAll(on);

        proxyAll.setBackColorRes(on ? R.color.setting_on : R.color.setting_off );

        Logger.debug(TAG, "Proxy all setting is " + on);
    }
}
