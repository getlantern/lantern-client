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
class MessagingViewModel(flutterEngine: FlutterEngine) {

    private val messagingModel = Model(
        flutterEngine = flutterEngine,
        eventChannelName = "updatesChannel", // TODO: use different channels for different models
        methodChannelName = "methodChannel", // TODO: use different channels for different models
        observableModel = ObservableModel.build(
            ctx = LanternApp.getAppContext(),
            filePath = File(
                File(LanternApp.getAppContext().filesDir, ".lantern"),
                "messaging_db"
            ).absolutePath,
            password = "password" // TODO: make the password random and save it as an encrypted preference
        ),
        onMethodCall = ::onMethodCall
    )

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "special method for messaging view model" -> {
                // handle it here
            }
        }
    }
}