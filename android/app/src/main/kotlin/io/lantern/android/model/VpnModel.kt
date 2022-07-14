package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import org.getlantern.mobilesdk.Logger

class VpnModel(
    flutterEngine: FlutterEngine,
    private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null,
) : BaseModel("vpn", flutterEngine, masterDB.withSchema(VPN_SCHEMA)) {

    companion object {
        private const val TAG = "VpnModel"
        const val VPN_SCHEMA = "vpn"

        const val PATH_VPN_STATUS = "/vpn_status"
        const val PATH_SERVER_INFO = "/server_info"
        const val PATH_BANDWIDTH = "/bandwidth"
    }

    init {
        val start = System.currentTimeMillis()
        db.registerType(1000, Vpn.ServerInfo::class.java)
        db.registerType(1001, Vpn.Bandwidth::class.java)
        Logger.debug(TAG, "register types finished at ${System.currentTimeMillis() - start}")
        db.mutate { tx ->
            // initialize vpn status for fresh install
            tx.put(PATH_VPN_STATUS, tx.get<String>(PATH_VPN_STATUS) ?: "disconnected")
        }
        Logger.debug(TAG, "db.mutate finished at ${System.currentTimeMillis() - start}")
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "switchVPN" -> {
                val on = call.argument<Boolean>("on") ?: false
                saveVpnStatus(if (on) "connecting" else "disconnecting")
                switchLantern(on)
            }
            else -> super.doMethodCall(call, notImplemented)
        }
    }

    fun isConnectedToVpn(): Boolean {
        val vpnStatus = vpnStatus()
        return vpnStatus == "connected" || vpnStatus == "disconnecting"
    }

    private fun vpnStatus(): String {
        return db.get(PATH_VPN_STATUS) ?: ""
    }

    private fun switchLantern(value: Boolean) {
        switchLanternHandler?.invoke(value)
    }

    fun setVpnOn(vpnOn: Boolean) {
        val vpnStatus = if (vpnOn) "connected" else "disconnected"
        saveVpnStatus(vpnStatus)
    }

    fun saveVpnStatus(vpnStatus: String) {
        db.mutate { tx ->
            tx.put(PATH_VPN_STATUS, vpnStatus)
        }
    }

    fun saveServerInfo(serverInfo: Vpn.ServerInfo) {
        db.mutate { tx ->
            tx.put(PATH_SERVER_INFO, serverInfo)
        }
    }

    fun saveBandwidth(bandwidth: Vpn.Bandwidth) {
        Logger.d(TAG, "Bandwidth updated to " + bandwidth.remaining + " remaining out of " + bandwidth.allowed + " allowed")
        db.mutate { tx ->
            tx.put(PATH_BANDWIDTH, bandwidth)
        }
    }
}
