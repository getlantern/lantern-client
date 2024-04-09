package io.lantern.model

import internalsdk.VPNManager
import internalsdk.VPNModel
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.model.dbadapter.DBAdapter
import org.getlantern.lantern.model.Bandwidth
import org.getlantern.mobilesdk.Logger

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

    fun updateBandwidth(bandwidth: Bandwidth) {
        try {
            model.updateBandwidth(
                bandwidth.percent,
                bandwidth.remaining,
                bandwidth.allowed,
                bandwidth.ttlSeconds,
            )
        } catch (t: Throwable) {
            Logger.error("VPNModel", "Error updating bandwidth", t)
        }
    }
}
