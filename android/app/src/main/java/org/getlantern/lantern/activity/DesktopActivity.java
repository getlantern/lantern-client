package org.getlantern.lantern.activity;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.getlantern.lantern.R;
import org.getlantern.lantern.util.IntentUtil;

@EActivity(R.layout.desktop_option)
public class DesktopActivity extends BaseFragmentActivity {
    @Click
    void btnShare() {
        IntentUtil.INSTANCE.sharePlainText(
            this,
            getString(R.string.lantern_desktop_link),
            getString(R.string.lantern_desktop_link_share_title)
        );
    }
}
