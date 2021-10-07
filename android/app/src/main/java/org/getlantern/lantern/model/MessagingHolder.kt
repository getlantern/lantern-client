package org.getlantern.lantern.model

import android.app.Application
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import io.lantern.android.model.BaseModel
import io.lantern.android.model.MessagingModel
import io.lantern.db.ChangeSet
import io.lantern.db.Subscriber
import io.lantern.messaging.Messaging
import io.lantern.messaging.Model
import io.lantern.messaging.Schema
import io.lantern.messaging.WebRTCSignal
import io.lantern.messaging.directContactPath
import io.lantern.messaging.path
import io.lantern.messaging.tassis.websocket.WebSocketTransportFactory
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.lantern.util.Json
import java.io.File
import java.util.HashMap

internal const val messageNotificationChannelId = "10001"
internal const val callNotificationChannelId = "10002"
internal const val defaultNotificationChannelId = "default"

class MessagingHolder {
    lateinit var messaging: Messaging
    private val contactNotificationIds = HashMap<Model.ContactId, Int>()
    private val callNotificationIds = HashMap<String, Int>()
    private var nextNotificationId = 5000

    fun init(application: Application) {
        val lanternDir = File(application.filesDir, ".lantern")
        lanternDir.mkdirs()
        try {
            messaging = Messaging(
                BaseModel.masterDB,
                File(application.filesDir, "attachments"),
                WebSocketTransportFactory("wss://tassis.lantern.io/api"),
                numInitialPreKeysToRegister = 25,
            )

            val notificationManager =
                application.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // show notifications for new messages
            messaging.db.subscribe(
                object : Subscriber<String>(
                    "newMessageNotifications",
                    Schema.PATH_CONTACT_MESSAGES.path("%")
                ) {
                    override fun onChanges(changes: ChangeSet<String>) {
                        changes.updates.values.forEach { messagePath ->
                            notifyMessage(application, notificationManager, messagePath)
                        }
                    }
                },
                receiveInitial = false
            )

            // show notifications for incoming calls
            messaging.subscribeToWebRTCSignals("systemNotifications") { signal ->
                val msg = Json.gson.fromJson(signal.content.toString(Charsets.UTF_8), SignalingMessage::class.java)
                when (msg.type) {
                    "offer" -> notifyCall(application, notificationManager, signal)
                    "bye" -> {
                        callNotificationIds.remove(signal.senderId)?.let { notificationId ->
                            notificationManager.cancel(notificationId)
                        }
                    }
                }
            }
        } catch (t: Throwable) {
            throw RuntimeException(t)
        }
    }

    private fun notifyMessage(
        application: Application,
        notificationManager: NotificationManager,
        messagePath: String
    ) {
        val msg = messaging.db.get<Model.StoredMessage>(messagePath)
        msg?.let {
            if (msg.direction == Model.MessageDirection.OUT) {
                return@let
            }
            val contact =
                messaging.db.get<Model.Contact>(msg.senderId.directContactPath)
            contact?.let {
                if (contact.contactId.id == MessagingModel.currentConversationContact) {
                    return@let
                }
                var notificationId = contactNotificationIds[contact.contactId]
                if (notificationId == null) {
                    notificationId = nextNotificationId++
                    contactNotificationIds[contact.contactId] = notificationId
                }
                val mainActivityIntent =
                    Intent(application, MainActivity::class.java)
                mainActivityIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
                mainActivityIntent.putExtra(
                    "contactForConversation",
                    contact.toByteArray()
                )
                val openMainActivity = PendingIntent.getActivity(
                    application, notificationId, mainActivityIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT
                )
                val builder = NotificationCompat.Builder(
                    application,
                    defaultNotificationChannelId
                )
                builder.setContentTitle("New Message") // TODO: localize me
                builder.setContentText("from ${contact.displayName ?: contact.contactId.id}")
                builder.setSmallIcon(R.drawable.status_on)
                builder.setAutoCancel(true)
                builder.setOnlyAlertOnce(true)
                builder.setContentIntent(openMainActivity)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val importance = NotificationManager.IMPORTANCE_HIGH
                    val notificationChannel = NotificationChannel(
                        messageNotificationChannelId,
                        "MessageNotificationChannel",
                        importance
                    )
                    builder.setChannelId(messageNotificationChannelId)
                    notificationManager.createNotificationChannel(
                        notificationChannel
                    )
                }
                notificationManager.notify(notificationId, builder.build())
            }
        }
    }

    private fun notifyCall(
        application: Application,
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
//        if (MainActivity.visible) {
//            // don't bother notifying if the MainActivity is currently visible, since it has its
//            // own incoming call notification
//            return
//        }
        val contact =
            messaging.db.get<Model.Contact>(signal.senderId.directContactPath)
        contact?.let {
            var notificationId = callNotificationIds[signal.senderId]
            if (notificationId == null) {
                notificationId = nextNotificationId++
                callNotificationIds[signal.senderId] = notificationId!!
            }
            val mainActivityIntent =
                Intent(application, MainActivity::class.java)
            mainActivityIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
            mainActivityIntent.putExtra(
                "signal",
                Json.gson.toJson(signal)
            )
            val openMainActivity = PendingIntent.getActivity(
                application, notificationId!!, mainActivityIntent,
                PendingIntent.FLAG_UPDATE_CURRENT
            )
            val builder = NotificationCompat.Builder(
                application,
                defaultNotificationChannelId
            )

            val notificationLayout = RemoteViews(application.packageName, R.layout.notification_custom)
            notificationLayout.setOnClickPendingIntent(R.id.btnAccept, null) // TODO: define acceptIntent
            notificationLayout.setOnClickPendingIntent(R.id.btnDecline, null) // TODO: define declineIntent

            // set strings in custom notification
            notificationLayout.setTextViewText(R.id.name, contact.displayName)
            notificationLayout.setTextViewText(R.id.incomingCall, application.getString(R.string.incoming_call))
            notificationLayout.setTextViewText(R.id.btnAccept, application.getString(R.string.accept))
            notificationLayout.setTextViewText(R.id.btnDecline, application.getString(R.string.decline))

            builder.setContentTitle(application.getString(R.string.incoming_call))
            builder.setContentText(contact.displayName)
            builder.setSmallIcon(R.drawable.status_on)
            builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            builder.setCustomContentView(notificationLayout)
            builder.setOngoing(true)
            builder.setCategory(NotificationCompat.CATEGORY_CALL)
            builder.setContentIntent(openMainActivity) // TODO: this needs to change

            val ringtone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val importance = NotificationManager.IMPORTANCE_HIGH
                val notificationChannel = NotificationChannel(
                    callNotificationChannelId,
                    "CallNotificationChannel",
                    importance
                )
                notificationChannel.enableVibration(true)
                notificationChannel.enableLights(true)
                val ringtoneAttrs = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
                notificationChannel.setSound(ringtone, ringtoneAttrs)
                builder.setChannelId(callNotificationChannelId)
                notificationManager.createNotificationChannel(
                    notificationChannel
                )
            }
            builder.setDefaults(Notification.DEFAULT_ALL)
            builder.setTimeoutAfter(30000)
            notificationManager.notify(notificationId!!, builder.build())
        }
    }
}

class SignalingMessage {
    var type: String? = null
}
