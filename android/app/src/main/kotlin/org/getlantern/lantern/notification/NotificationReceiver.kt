package org.getlantern.lantern.notification

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.model.VpnState
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.mobilesdk.Logger
import org.greenrobot.eventbus.EventBus


class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Logger.debug(TAG, "Received disconnect broadcast")
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NotificationHelper.VPN_CONNECTED)
        if (Utils.isServiceRunning(
                context,
                LanternVpnService::class.java,
            )
        ) {
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