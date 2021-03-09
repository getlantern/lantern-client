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
class VpnModel(flutterEngine: FlutterEngine) : Model(

    flutterEngine = flutterEngine,
    eventChannelName = "updatesChannel", // TODO: use different channels for different models
    methodChannelName = "methodChannel", // TODO: use different channels for different models
    observableModel = ObservableModel.build(
        LanternApp.getAppContext(),
        File(File(LanternApp.getAppContext().filesDir, ".lantern"), "vpn_db").absolutePath,
        "password"
    ) // TODO: make the password random and save it as an encrypted preference

) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "special method for vpn model" -> {
                // handle it here
            }
            else -> super.onMethodCall(call, result)
        }
    }
}