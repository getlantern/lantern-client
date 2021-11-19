package org.getlantern.lantern.service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import org.getlantern.mobilesdk.Logger;

public class Restarter extends BroadcastReceiver {
    private static final String TAG = Restarter.class.getName();

    @Override
    public void onReceive(Context context, Intent intent) {
        Logger.debug(TAG, "LanternService tried to stop, restarting");

        Intent serviceIntent = new Intent(context, LanternService_.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent);
        } else {
            context.startService(serviceIntent);
        }
    }
}