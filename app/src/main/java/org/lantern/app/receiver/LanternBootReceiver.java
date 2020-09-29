package org.lantern.app.receiver;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.Context;
import android.net.VpnService;
import android.os.Bundle;

import org.lantern.app.activity.LanternFreeActivity;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.vpn.LanternVpnService;
import org.lantern.app.service.LanternService_;

public class LanternBootReceiver extends BroadcastReceiver{

    private static final String TAG = "LanternBootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED)){
            Logger.debug(TAG, "RECEIVED BOOT COMPLETED");

            Intent i = new Intent(context, LanternFreeActivity.class);
            Bundle b = new Bundle();
            b.putInt("isBootUp", 1);
            i.putExtras(b);
            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(i);
        }
    }
}
