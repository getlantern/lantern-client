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
class VpnViewModel(
    flutterEngine: FlutterEngine,
    private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null
) {

    private val vpnModel = Model(
        flutterEngine = flutterEngine,
        eventChannelName = "vpn_event_channel",
        methodChannelName = "vpn_method_channel",
        observableModel = vpnObservableModel,
        onMethodCall = ::onMethodCall
    )

    companion object {
        const val PATH_VPN_STATUS = "/vpn_status"
        const val PATH_SERVER_INFO = "/server_info"

        val vpnObservableModel = ObservableModel.build(
            ctx = LanternApp.getAppContext(),
            filePath = File(
                File(LanternApp.getAppContext().filesDir, ".lantern"),
                "vpn_db"
            ).absolutePath,
            password = "password" // TODO: make the password random and save it as an encrypted preference
        )
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "put" -> {
                val path = call.argument<String>("path")!!
                if (path.startsWith(PATH_VPN_STATUS)) {
                    val value = call.argument<String>("value")!!
                    when (value) {
                        "connecting" -> switchLantern(true)
                        "disconnecting" -> switchLantern(false)
                    }
                }
            }
        }
    }

    private fun switchLantern(value: Boolean) {
        switchLanternHandler?.invoke(value)
    }

    fun setVpnOn(vpnOn: Boolean) {
        val vpnStatus = if (vpnOn) "connected" else "disconnected"
        vpnModel.observableModel.mutate { tx ->
            tx.put(PATH_VPN_STATUS, vpnStatus)
        }
    }

    fun vpnStatus(): String {
        return vpnModel.observableModel.get(PATH_VPN_STATUS) ?: ""
    }

    fun isConnectedToVpn(): Boolean {
        val vpnStatus = vpnStatus()
        return vpnStatus == "connected" || vpnStatus == "disconnecting"
    }
}