package org.getlantern.lantern.service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import org.getlantern.mobilesdk.Logger;

public class AutoStarter extends BroadcastReceiver {
    private static final String TAG = AutoStarter.class.getName();

    @Override
    public void onReceive(Context context, Intent intent) {
        Logger.debug(TAG, "Automatically starting Lantern Service on: " + intent.getAction());

        Intent serviceIntent = new Intent(context, LanternService_.class);
        serviceIntent.putExtra(
                LanternService.AUTO_BOOTED,
                intent.getAction() == Intent.ACTION_BOOT_COMPLETED
        );

        context.startService(serviceIntent);
    }
}