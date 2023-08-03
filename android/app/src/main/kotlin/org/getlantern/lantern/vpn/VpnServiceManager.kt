package org.getlantern.lantern.vpn

import android.content.Context
import android.content.IntentFilter
import io.lantern.model.VpnModel
import kotlinx.coroutines.*
import org.getlantern.lantern.Actions
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.service.LanternConnection
import org.getlantern.lantern.util.broadcastReceiver
import org.getlantern.mobilesdk.Logger

class VpnServiceManager(
    private val context: Context,
    private val vpnModel: VpnModel,
) {
    private val vpnServiceConnection = LanternConnection(true)
    private val receiver = broadcastReceiver { _, _ ->
        Logger.d(TAG, "Received disconnect broadcast")
        val manager = LanternApp.notificationManager
        manager.cancel(1)
        disconnect()
    }

    init {
        vpnServiceConnection.connect(context)
        context.registerReceiver(
            receiver,
            IntentFilter().apply {
                addAction(Actions.DISCONNECT_VPN)
            },
        )
    }

    fun connect() {
        updateVpnStatus(true)
        LanternApp.startService(vpnServiceConnection)
    }

    private fun updateVpnStatus(useVpn: Boolean) {
        Logger.d(TAG, "Updating VPN status to $useVpn")
        LanternApp.getSession().updateVpnPreference(useVpn)
        LanternApp.getSession().updateBootUpVpnPreference(useVpn)
        vpnModel.setVpnOn(useVpn)
    }

    fun onVpnPermissionResult(isGranted: Boolean) {
        if (isGranted) connect()
    }

    fun destroy() {
        context.unregisterReceiver(receiver)
        vpnServiceConnection.disconnect(context)
    }

    fun disconnect() {
        updateVpnStatus(false)
        LanternApp.stopService(vpnServiceConnection)
    }

    companion object {
        private val TAG = VpnServiceManager::class.java.simpleName
    }
}
