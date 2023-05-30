package org.getlantern.lantern.notification

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.lantern.model.VpnModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.model.VpnState
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.mobilesdk.Logger
import org.greenrobot.eventbus.EventBus


class NotificationReceiver() : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
    	if (Utils.isServiceRunning(
                context,
                LanternVpnService::class.java,
            )
        ) {
            Logger.debug(TAG, "Received disconnect broadcast")
            EventBus.getDefault().post(VpnState(false))
            context.startService(
	            Intent(
	                context,
	                LanternVpnService::class.java,
	            ).setAction(LanternVpnService.ACTION_DISCONNECT),
        	)
        }
    }

    companion object {
        private val TAG = NotificationReceiver::class.java.simpleName
    }
}