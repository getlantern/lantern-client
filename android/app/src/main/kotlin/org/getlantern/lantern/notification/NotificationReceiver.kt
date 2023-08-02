package org.getlantern.lantern.notification

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationManager
import io.lantern.model.VpnModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.model.VpnState
import org.getlantern.lantern.util.isServiceRunning
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.lantern.vpn.VpnServiceManager
import org.getlantern.mobilesdk.Logger
import org.greenrobot.eventbus.EventBus


class NotificationReceiver(private val serviceManager: VpnServiceManager) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Logger.debug(TAG, "Received disconnect broadcast")
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NotificationHelper.VPN_CONNECTED)
        if (Utils.isServiceRunning(context, LanternVpnService::class.java)
        ) {
            serviceManager.disconnect()
        }
    }

    companion object {
        private val TAG = NotificationReceiver::class.java.simpleName
    }
}