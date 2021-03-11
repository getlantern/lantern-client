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
    private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null
) : Model(

    flutterEngine = flutterEngine,
    eventChannelName = "updatesChannel", // TODO: use different channels for different models
    methodChannelName = "methodChannel", // TODO: use different channels for different models
    observableModel = ObservableModel.build(
        LanternApp.getAppContext(),
        File(File(LanternApp.getAppContext().filesDir, ".lantern"), "vpn_db").absolutePath,
        "password"
    ) // TODO: make the password random and save it as an encrypted preference

) {

    companion object {
        const val VPN_ON_PATH = "/vpnOn"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "put" -> {
                val path = call.argument<String>("path")!!
                if (path.startsWith(VPN_ON_PATH)) {
                    val value = call.argument<Boolean>("value")!!
                    switchLantern(value)
                } else {
                    super.onMethodCall(call, result)
                }
            }
            else -> super.onMethodCall(call, result)
        }
    }

    private fun switchLantern(value: Boolean) {
        setVpnOn(value)
        switchLanternHandler?.invoke(value)
    }

    fun setVpnOn(vpnOn: Boolean) {
        observableModel.mutate { tx ->
            tx.put(VPN_ON_PATH, vpnOn)
        }
    }
}