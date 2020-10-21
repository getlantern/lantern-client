package org.getlantern.lantern.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import org.getlantern.lantern.LanternApp;

public class Launcher extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Intent intent;
        intent = new Intent(this, BeamFreeActivity.class);
        startActivity(intent);
        finish();
    }
}
