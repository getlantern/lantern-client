package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.lantern.db.DB
import org.getlantern.lantern.LanternApp
import java.io.File

/**
 * Created by DoNguyen on 10/3/21.
 */
class VpnModel(
        flutterEngine: FlutterEngine? = null,
        private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null,
) : BaseModel("vpn", flutterEngine, db) {

    companion object {
        const val PATH_VPN_STATUS = "/vpn_status"
        const val PATH_SERVER_INFO = "/server_info"
        const val PATH_BANDWIDTH = "/bandwidth"

        val db = DB.createOrOpen(
                ctx = LanternApp.getAppContext(),
                filePath = File(
                        File(LanternApp.getAppContext().filesDir, ".lantern"),
                        "vpn_db"
                ).absolutePath,
                password = "password" // TODO: make the password random and save it as an encrypted preference
        )

        init {
            db.registerType(20, Vpn.ServerInfo::class.java)
            db.registerType(21, Vpn.Bandwidth::class.java)
            db.mutate { tx ->
                // initialize vpn status for fresh install
                tx.put(PATH_VPN_STATUS, tx.get<String>(PATH_VPN_STATUS) ?: "disconnected")
            }
        }
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
        db.mutate { tx ->
            tx.put(PATH_BANDWIDTH, bandwidth)
        }
    }
}