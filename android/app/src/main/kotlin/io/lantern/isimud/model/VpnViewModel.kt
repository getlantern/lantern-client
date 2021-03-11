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
        observableModel = ObservableModel.build(
            ctx = LanternApp.getAppContext(),
            filePath = File(
                File(LanternApp.getAppContext().filesDir, ".lantern"),
                "vpn_db"
            ).absolutePath,
            password = "password" // TODO: make the password random and save it as an encrypted preference
        ),
        onMethodCall = ::onMethodCall
    )

    companion object {
        const val VPN_ON_PATH = "/vpnOn"
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "put" -> {
                val path = call.argument<String>("path")!!
                if (path.startsWith(VPN_ON_PATH)) {
                    val value = call.argument<Boolean>("value")!!
                    switchLantern(value)
                }
            }
        }
    }

    private fun switchLantern(value: Boolean) {
        switchLanternHandler?.invoke(value)
    }

    fun setVpnOn(vpnOn: Boolean) {
        vpnModel.observableModel.mutate { tx ->
            tx.put(VPN_ON_PATH, vpnOn)
        }
    }
}