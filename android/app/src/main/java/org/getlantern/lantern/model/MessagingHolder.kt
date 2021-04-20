package org.getlantern.lantern.model

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import io.lantern.android.model.BaseModel
import io.lantern.db.ChangeSet
import io.lantern.db.Subscriber
import io.lantern.messaging.*
import io.lantern.messaging.tassis.websocket.WebSocketTransportFactory
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import java.io.File
import java.util.*

internal const val notificationChannelId = "10001"
internal const val defaultNotificationChannelId = "default"

class MessagingHolder {
    lateinit var messaging: Messaging
    private val contactNotificationIds = HashMap<Model.ContactId, Int>()
    private var nextNotificationId = 5000;

    fun init(application: Application) {
        val lanternDir = File(application.filesDir, ".lantern")
        lanternDir.mkdirs()
        try {
            messaging = Messaging(
                    BaseModel.masterDB,
                    File(application.filesDir, "attachments"),
                    WebSocketTransportFactory("wss://tassis.lantern.io/api"))

            messaging.db.subscribe(object : Subscriber<String>("newMessageNotifications", Schema.PATH_CONTACT_MESSAGES.path("%")) {
                override fun onChanges(changes: ChangeSet<String>) {
                    changes.updates.values.forEach { messagePath ->
                        val msg = messaging.db.get<Model.StoredMessage>(messagePath)
                        msg?.let {
                            if (msg.direction == Model.MessageDirection.OUT) {
                                return
                            }
                            val contact = messaging.db.get<Model.Contact>(msg.senderId.directContactPath)
                            contact?.let {
                                var notificationId = contactNotificationIds[contact.contactId]
                                if (notificationId == null) {
                                    notificationId = nextNotificationId++
                                    contactNotificationIds[contact.contactId] = notificationId
                                }
                                val mainActivityIntent = Intent(application, MainActivity::class.java)
                                mainActivityIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
                                mainActivityIntent.putExtra("contactForConversation", contact.toByteArray())
                                val openMainActivity = PendingIntent.getActivity(application, notificationId, mainActivityIntent,
                                        PendingIntent.FLAG_UPDATE_CURRENT);
                                val notificationManager = application.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                                val builder = NotificationCompat.Builder(application, defaultNotificationChannelId)
                                builder.setContentTitle("New Message") // TODO: localize me
                                builder.setContentText("from ${contact.displayName ?: contact.contactId.id}")
                                builder.setTicker("Notification Listener Service Example")
                                builder.setSmallIcon(R.drawable.status_on)
                                builder.setAutoCancel(true)
                                builder.setOnlyAlertOnce(true)
                                builder.setContentIntent(openMainActivity)
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    val importance = NotificationManager.IMPORTANCE_HIGH
                                    val notificationChannel = NotificationChannel(notificationChannelId, "NOTIFICATION_CHANNEL_NAME", importance)
                                    builder.setChannelId(notificationChannelId)
                                    notificationManager.createNotificationChannel(notificationChannel)
                                }
                                notificationManager.notify(notificationId, builder.build())
                            }
                        }
                    }
                }
            }, receiveInitial = false)
        } catch (t: Throwable) {
            throw RuntimeException(t);
        }
    }
}