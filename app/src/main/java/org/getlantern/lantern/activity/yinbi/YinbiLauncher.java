package org.getlantern.lantern.activity.yinbi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import org.getlantern.lantern.LanternApp;
import org.getlantern.mobilesdk.model.SessionManager;

public class YinbiLauncher extends Activity {

    private static final SessionManager session = LanternApp.getSession();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Intent intent;
        final Class<? extends YinbiActivity> activityClass;
        if (session.showYinbiRedemptionTable()) {
            activityClass = YinbiRedemptionActivity.class;
        } else {
            activityClass = YinbiScreenActivity.class;
        }
        startActivity(new Intent(this, activityClass));
        finish();
    }
}
