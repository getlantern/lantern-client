package io.lantern.model

import internalsdk.VPNManager
import internalsdk.VPNModel
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.model.dbadapter.DBAdapter

class VpnModel(
    flutterEngine: FlutterEngine,
    private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null,
) : GoModel<VPNModel>(
    "vpn",
    flutterEngine,
    masterDB.withSchema("vpn"),
    VPNModel(DBAdapter(masterDB.db))
) {

    init {
        model.setManager(object : VPNManager {
            override fun startVPN() {
                switchLanternHandler?.invoke(true)
            }

            override fun stopVPN() {
                switchLanternHandler?.invoke(false)
            }
        })
    }

    fun isConnectedToVpn(): Boolean {
        val vpnStatus = model.vpnStatus
        return vpnStatus == "connected" || vpnStatus == "disconnecting"
    }

    fun setVpnOn(vpnOn: Boolean) {
        model.switchVPN(vpnOn)
    }

    fun updateStatus(vpnOn: Boolean) {
        model.saveVPNStatus(if (vpnOn) "connected" else "disconnected")
    }
}
