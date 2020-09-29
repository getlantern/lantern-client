package org.getlantern.lantern.activity;

import android.view.View;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.EActivity;

import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;

@EActivity(R.layout.privacy_disclosure)
public class PrivacyDisclosureActivity extends FragmentActivity {
    private static final String TAG = PrivacyDisclosureActivity.class.getName();

    public void acceptTerms(View view) {
        Logger.debug(TAG, "Accepted privacy disclosure");
        LanternApp.getSession().acceptTerms();
        finish();
    }
}
