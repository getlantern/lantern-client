package org.getlantern.lantern.model

import android.app.Application
import io.lantern.messaging.Messaging
import io.lantern.messaging.store.MessagingStore
import io.lantern.messaging.tassis.websocket.WebSocketTransportFactory
import java.io.File

class MessagingHolder {
    lateinit var messaging: Messaging

    fun init(application: Application) {
        val lanternDir = File(application.filesDir, ".lantern")
        lanternDir.mkdirs()
        try {
            messaging = Messaging(
                    File(application.filesDir, "attachments"),
                    MessagingStore(application.applicationContext, File(lanternDir, "messagingdb").absolutePath),
                    WebSocketTransportFactory("wss://tassis.lantern.io/api"))
        } catch (t: Throwable) {
            throw RuntimeException(t);
        }
    }
}