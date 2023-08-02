package org.getlantern.lantern.vpn

import android.content.Context
import io.lantern.model.VpnModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.lantern.service.BaseService
import org.getlantern.lantern.service.ConnectionState
import org.getlantern.lantern.service.LanternConnection
import org.getlantern.mobilesdk.Logger

class VpnServiceManager(
    private val context: Context,
    private val vpnModel: VpnModel,
) : BaseService.Callback {
    private var state = ConnectionState.Disconnected
    private val vpnServiceConnection = LanternConnection(true)

    fun init() {
        vpnServiceConnection.connect(context)
    }

    fun connect() {
        updateVpnStatus(true)
        LanternApp.startService(vpnServiceConnection)
        LanternApp.notifications.vpnConnectedNotification()
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
