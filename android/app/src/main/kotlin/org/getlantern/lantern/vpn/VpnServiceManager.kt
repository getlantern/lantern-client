package org.getlantern.lantern.vpn

import android.app.Service
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.lantern.model.VpnModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.Actions
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.lantern.service.BaseService
import org.getlantern.lantern.service.ConnectionState
import org.getlantern.lantern.service.LanternConnection
import org.getlantern.lantern.util.runOnMainDispatcher
import org.getlantern.mobilesdk.Logger

class VpnServiceManager(
    private val context: Context,
    private val vpnModel: VpnModel,
) : BaseService.Callback {
    private val notifications = NotificationHelper(context)
    private var state = ConnectionState.Disconnected
    private val vpnServiceConnection = LanternConnection(true)

    fun init() {
        vpnServiceConnection.connect(context)
    }

    fun connect() {
        updateVpnStatus(true)
        LanternApp.startService(vpnServiceConnection)
        notifications.vpnConnectedNotification()
    }

    private fun updateVpnStatus(useVpn: Boolean) {
        Logger.d(TAG, "Updating VPN status to %1\$s", useVpn)
        LanternApp.getSession().updateVpnPreference(useVpn)
        LanternApp.getSession().updateBootUpVpnPreference(useVpn)
        vpnModel.setVpnOn(useVpn)
    }

    override fun onStateChanged(state: ConnectionState) {
        this.state = state
    }

    fun onVpnPermissionResult(isGranted: Boolean) {
        if (isGranted) connect()
    }

    fun disconnect() {
        updateVpnStatus(false)
        LanternApp.stopService(vpnServiceConnection)
    }

    companion object {
        private val TAG = VpnServiceManager::class.java.simpleName
    }
}
