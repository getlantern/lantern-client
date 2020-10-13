package org.getlantern.lantern.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.model.SessionManager;

public class Launcher extends Activity {

    private static final SessionManager session = LanternApp.getSession();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Intent intent;
        if (session.isProUser()) {
            intent = new Intent(this, LanternProActivity.class);
        } else {
            intent = new Intent(this, LanternFreeActivity.class);
        }
        startActivity(intent);
        finish();
    }
}
