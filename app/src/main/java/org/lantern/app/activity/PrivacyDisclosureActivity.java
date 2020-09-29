package org.lantern.app.activity;

import android.view.View;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.EActivity;

import org.lantern.mobilesdk.Logger;
import org.lantern.app.LanternApp;
import org.lantern.app.R;

@EActivity(R.layout.privacy_disclosure)
public class PrivacyDisclosureActivity extends FragmentActivity {
    private static final String TAG = PrivacyDisclosureActivity.class.getName();

    public void acceptTerms(View view) {
        Logger.debug(TAG, "Accepted privacy disclosure");
        LanternApp.getSession().acceptTerms();
        finish();
    }
}
