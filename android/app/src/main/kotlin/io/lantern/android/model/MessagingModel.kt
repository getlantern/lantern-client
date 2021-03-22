package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.lantern.messaging.Messaging

class MessagingModel constructor(flutterEngine: FlutterEngine, private val messaging: Messaging) : Model("messaging", flutterEngine, messaging.db) {
    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "addOrUpdateContact" -> messaging.addOrUpdateContact(call.argument("contactId")!!, call.argument("displayName")!!)
            "sendToContact" -> messaging.sendToContact(call.argument("contactId")!!, text = call.argument("text"), oggVoice = call.argument("oggVoice"))
            else -> super.doMethodCall(call, notImplemented)
        }
    }
}