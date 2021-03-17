package io.lantern.isimud.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.observablemodel.ObservableModel
import org.getlantern.lantern.LanternApp
import java.io.File

/**
 * Created by DoNguyen on 10/3/21.
 */
class VpnModel(
        flutterEngine: FlutterEngine,
        private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null,
) : Model("vpn", flutterEngine, vpnObservableModel) {

    companion object {
        const val PATH_VPN_STATUS = "/vpn_status"
        const val PATH_SERVER_INFO = "/server_info"
        const val PATH_BANDWIDTH = "/bandwidth"

        val vpnObservableModel = ObservableModel.build(
                ctx = LanternApp.getAppContext(),
                filePath = File(
                        File(LanternApp.getAppContext().filesDir, ".lantern"),
                        "vpn_db"
                ).absolutePath,
                password = "password" // TODO: make the password random and save it as an encrypted preference
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "switchVPN" -> {
                switchLantern(call.argument<Boolean>("on") ?: false)
            }
            else -> super.onMethodCall(call, result)
        }
    }

    private fun switchLantern(value: Boolean) {
        switchLanternHandler?.invoke(value)
    }

    fun setVpnOn(vpnOn: Boolean) {
        val vpnStatus = if (vpnOn) "connected" else "disconnected"
        observableModel.mutate { tx ->
            tx.put(PATH_VPN_STATUS, vpnStatus)
        }
    }

    private fun vpnStatus(): String {
        return observableModel.get(PATH_VPN_STATUS) ?: ""
    }

    fun isConnectedToVpn(): Boolean {
        val vpnStatus = vpnStatus()
        return vpnStatus == "connected" || vpnStatus == "disconnecting"
    }
}