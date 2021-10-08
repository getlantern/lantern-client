package org.getlantern.lantern.model

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.graphics.ColorUtils
import io.lantern.android.model.BaseModel
import io.lantern.android.model.MessagingModel
import io.lantern.db.ChangeSet
import io.lantern.db.Subscriber
import io.lantern.messaging.*
import io.lantern.messaging.tassis.websocket.WebSocketTransportFactory
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.lantern.util.Json
import java.io.File
import java.util.*

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
                    "answer" -> acceptCall(notificationManager, signal)
                    "bye" -> declineCall(notificationManager, signal)
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

    private fun declineCall(
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        callNotificationIds.remove(signal.senderId)?.let { notificationId ->
            notificationManager.cancel(notificationId)
        }
    }

    private fun acceptCall(
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        // do something to answer
    }

    private fun getAvatarBgColor(id: String): Int {
        val hash = id.hashCode()
        val maxHash = 2147483647.rem(2).toFloat()
        val hue = maxOf(0.toFloat(), hash / maxHash * 360)
        val color = floatArrayOf(hue, 1.toFloat(), 0.3.toFloat())
        return ColorUtils.setAlphaComponent(ColorUtils.HSLToColor(color), 255)
    }

    private fun notifyCall(
        application: Application,
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        val contact =
            messaging.db.get<Model.Contact>(signal.senderId.directContactPath)
        contact?.let {
            var notificationId = callNotificationIds[signal.senderId]
            if (notificationId == null) {
                notificationId = nextNotificationId++
                callNotificationIds[signal.senderId] = notificationId
            }
            val notificationIntent =
                Intent(application, MainActivity::class.java)
            notificationIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
            notificationIntent.putExtra(
                "signal",
                Json.gson.toJson(signal)
            )
            val declineIntent =
                Intent(application, MainActivity::class.java) // Technically this should be "webRTC class intent" or something? Or can we invoke declineCall() right away?
            declineIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
            declineIntent.putExtra("signal", Json.gson.toJson(signal))

            val acceptIntent =
                Intent(application, MainActivity::class.java) // Same as above
            acceptIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
            declineIntent.putExtra("signal", Json.gson.toJson(signal))

            val notificationPendingIntent = PendingIntent.getActivity(application, notificationId, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            val declinePendingIntent = PendingIntent.getBroadcast(application, notificationId, declineIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            val acceptPendingIntent = PendingIntent.getBroadcast(application, notificationId, acceptIntent, PendingIntent.FLAG_UPDATE_CURRENT)

            val builder = NotificationCompat.Builder(
                application,
                defaultNotificationChannelId
            )

            val customNotification = RemoteViews(application.packageName, R.layout.notification_custom)
            // set strings in custom notification
            customNotification.setTextViewText(R.id.caller, contact.displayName)
            customNotification.setTextViewText(R.id.incomingCall, application.getString(R.string.incoming_call))
            customNotification.setTextViewText(R.id.btnAccept, application.getString(R.string.accept))
            customNotification.setTextViewText(R.id.btnDecline, application.getString(R.string.decline))

            builder.setContentTitle(application.getString(R.string.incoming_call))
            builder.setContentText(contact.displayName)
            builder.setSmallIcon(R.drawable.status_on)
            builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            builder.setCustomContentView(customNotification)
            builder.setOngoing(true)
            builder.setCategory(NotificationCompat.CATEGORY_CALL)

            // paint avatar
            val bitmap = Bitmap.createBitmap(400, 400, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paintBg = Paint()
            val paintAv = Paint()
            paintAv.isAntiAlias = true
            paintBg.isAntiAlias = true
            paintBg.color = getAvatarBgColor(contact.contactId.id)
            canvas.drawCircle(200.toFloat(), 200.toFloat(), 200.toFloat(), paintBg)
            paintAv.color = Color.WHITE
            paintAv.textSize = 150.toFloat()
            canvas.drawText(contact.displayName.take(2).toUpperCase(Locale.getDefault()), 100.toFloat(), 250.toFloat(), paintAv)
            customNotification.setImageViewBitmap(R.id.avatar, bitmap)

            // set intents
            customNotification.setOnClickPendingIntent(R.id.btnAccept, declinePendingIntent)
            customNotification.setOnClickPendingIntent(R.id.btnDecline, acceptPendingIntent)
            builder.setContentIntent(notificationPendingIntent) // TODO: not sure

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
            } else {
                // This is a custom action assignment in case the API does not accept remote views
                val hangupAction = NotificationCompat.Action.Builder(android.R.drawable.ic_menu_delete, application.getString(R.string.decline), declinePendingIntent).build()
                val acceptAction = NotificationCompat.Action.Builder(android.R.drawable.ic_menu_call, application.getString(R.string.accept), declinePendingIntent).build()
                builder.addAction(hangupAction)
                builder.addAction(acceptAction)
            }
            builder.setDefaults(Notification.DEFAULT_ALL)
            builder.setTimeoutAfter(50000)

            notificationManager.notify(notificationId, builder.build())
        }
    }
}

class SignalingMessage {
    var type: String? = null
}
