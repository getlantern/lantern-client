package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.lantern.messaging.Messaging

class MessagingModel constructor(flutterEngine: FlutterEngine, private val messaging: Messaging) : Model("messaging", flutterEngine, messaging.db) {
    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "setMyDisplayName" -> messaging.setMyDisplayName(call.argument("displayName") ?: "")
            "addOrUpdateDirectContact" -> messaging.addOrUpdateDirectContact(call.argument("identityKey")!!, call.argument("displayName")!!)
            "sendToDirectContact" -> {
                messaging.sendToDirectContact(call.argument("identityKey")!!, text = call.argument("text"), oggVoice = call.argument("oggVoice"))
                null
            }
            else -> super.doMethodCall(call, notImplemented)
        }
    }
}