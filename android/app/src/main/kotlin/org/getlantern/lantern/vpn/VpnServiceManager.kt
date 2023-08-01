package org.getlantern.lantern.vpn

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.lantern.model.VpnModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.mobilesdk.Logger

class VpnServiceManager(
    private val context: Context,
    private val vpnModel: VpnModel,
) {
    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (context == null || intent == null) return
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.cancel(NotificationHelper.VPN_CONNECTED)
            updateVpnStatus(false)
            context.startService(
                Intent(context, LanternVpnService::class.java).apply {
                    action = LanternVpnService.ACTION_DISCONNECT
                },
            )
        }
    }
    private val notifications = NotificationHelper(context, broadcastReceiver)
    private var lanternVpnService: LanternVpnService? = null

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder) {
            lanternVpnService = (binder as LanternVpnService.LocalBinder).service
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            lanternVpnService = null
        }
    }

    fun init() {
        val packageName = context.packageName
        LocalBroadcastManager.getInstance(context)
            .registerReceiver(broadcastReceiver, IntentFilter("$packageName.intent.VPN_DISCONNECTED"))
    }

    fun connect() {
        updateVpnStatus(true)
        val intent = Intent(context, LanternVpnService::class.java).apply {
            action = LanternVpnService.ACTION_CONNECT
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
        notifications.vpnConnectedNotification()
    }

    private fun updateVpnStatus(useVpn: Boolean) {
        Logger.d(TAG, "Updating VPN status to %1\$s", useVpn)
        LanternApp.getSession().updateVpnPreference(useVpn)
        LanternApp.getSession().updateBootUpVpnPreference(useVpn)
        vpnModel.setVpnOn(useVpn)
    }

    fun onVpnPermissionResult(isGranted: Boolean) {
        if (isGranted) connect()
    }

    fun disconnect() {
        LocalBroadcastManager.getInstance(context).sendBroadcast(notifications.disconnectIntent())
    }

    fun bind() {
        synchronized(this) {
            if (lanternVpnService == null) {
                val intent = Intent(context, LanternVpnService::class.java)
                context.bindService(intent, serviceConnection, 0)
            }
        }
    }

    fun unbind() {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(broadcastReceiver)
        synchronized(this) {
            if (lanternVpnService == null) return
            try {
                context.unbindService(serviceConnection)
            } catch (_: Exception) {}
        }
    }

    companion object {
        private val TAG = VpnServiceManager::class.java.simpleName
    }
}
