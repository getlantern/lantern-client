package org.getlantern.lantern.activity.yinbi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import org.getlantern.lantern.LanternApp;

public class YinbiLauncher extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Intent intent;
        final Class<? extends YinbiActivity> activityClass;
        if (LanternApp.getSession().showYinbiRedemptionTable()) {
            activityClass = YinbiRedemptionActivity.class;
        } else {
            activityClass = YinbiScreenActivity.class;
        }
        startActivity(new Intent(this, activityClass));
        finish();

        LanternApp.getSession().setShouldShowYinbiBadge(false);
    }
}
