package org.getlantern.lantern.receiver;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;

import org.getlantern.lantern.activity.BeamFreeActivity;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.service.LanternService_;

public class LanternBootReceiver extends BroadcastReceiver{

    private static final String TAG = "LanternBootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED)){
            Logger.debug(TAG, "RECEIVED BOOT COMPLETED");

            Intent i = new Intent(context, BeamFreeActivity.class);
            Bundle b = new Bundle();
            b.putInt("isBootUp", 1);
            i.putExtras(b);
            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(i);
        }
    }
}
