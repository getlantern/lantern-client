package org.getlantern.lantern.model

import android.app.Application
import io.lantern.messaging.Messaging
import io.lantern.messaging.store.MessagingStore
import io.lantern.messaging.tassis.websocket.WebSocketTransportFactory
import java.io.File

class MessagingHolder {
    lateinit var messaging: Messaging

    fun init(application: Application) {
        try {
            messaging = Messaging(
                    File(application.filesDir, "attachments"),
                    MessagingStore(application.applicationContext, File(File(application.filesDir, ".lantern"), "messagingdb").absolutePath),
                    WebSocketTransportFactory("wss://tassis.lantern.io/api"))
        } catch (t: Throwable) {
            throw RuntimeException(t);
        }
    }
}