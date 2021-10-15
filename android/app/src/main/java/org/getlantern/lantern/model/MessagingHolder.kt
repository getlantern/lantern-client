package org.getlantern.lantern.model

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Build
import android.os.Bundle
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
import org.getlantern.lantern.service.IncomingCallNotificationService
import org.getlantern.lantern.util.Json
import java.io.File

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
                    "bye" -> declineAndDismiss(application, notificationManager, signal)
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
                    PendingIntent.FLAG_ONE_SHOT
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

    fun notifyCall(
        context: Context,
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        val intent = Intent(context, IncomingCallNotificationService::class.java)
        val intentExtras = Bundle()
        intentExtras.putString("signal", Json.gson.toJson(signal))
        intent.putExtras(intentExtras)
        context.startService(intent)

        val serializedSignal = Json.gson.toJson(signal)
        val contact =
            messaging.db.get<Model.Contact>(signal.senderId.directContactPath)
        contact?.let {
            val calledFromService = context is IncomingCallNotificationService
            var notificationId = if (calledFromService) nextNotificationId else nextNotificationId++
            callNotificationIds[signal.senderId] = notificationId

            // decline intent
            val declineIntentExtras = Bundle()
            val declineIntent =
                Intent(context, DeclineCallBroadcastReceiver::class.java)
            declineIntentExtras.putString("signal", serializedSignal)
            declineIntent.putExtras(declineIntentExtras)

            // accept intent
            val acceptIntentExtras = Bundle()
            val acceptIntent =
                Intent(context, MainActivity::class.java)
            acceptIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
            acceptIntentExtras.putString("signal", serializedSignal)
            acceptIntentExtras.putBoolean("accepted", true)
            acceptIntent.putExtras(acceptIntentExtras)

            val declinePendingIntent = PendingIntent.getBroadcast(
                context,
                notificationId,
                declineIntent,
                PendingIntent.FLAG_ONE_SHOT
            )
            val acceptPendingIntent = PendingIntent.getActivity(
                context,
                notificationId,
                acceptIntent,
                PendingIntent.FLAG_ONE_SHOT
            )

            val builder = NotificationCompat.Builder(
                context,
                defaultNotificationChannelId
            )

            // RemoteViews styles
            val customNotification = RemoteViews(context.packageName, R.layout.notification_custom)
            customNotification.setTextViewText(R.id.caller, contact.displayName)
            customNotification.setTextViewText(R.id.incomingCall, context.getString(R.string.incoming_call))
            customNotification.setTextViewText(R.id.btnAccept, context.getString(R.string.accept))
            customNotification.setTextViewText(R.id.btnDecline, context.getString(R.string.decline))
            paintAvatar(contact, customNotification)

            // Set button intents
            customNotification.setOnClickPendingIntent(R.id.btnDecline, declinePendingIntent)
            customNotification.setOnClickPendingIntent(R.id.btnAccept, acceptPendingIntent)

            // Attach RemoteView to builder()
            builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            builder.setCustomContentView(customNotification)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val importance = NotificationManager.IMPORTANCE_HIGH
                val notificationChannel = NotificationChannel(
                    callNotificationChannelId,
                    "CallNotificationChannel",
                    importance
                )
                notificationChannel.enableVibration(true)
                notificationChannel.enableLights(true)
                // TODO: Confirm - handling ringtone on Dart side for now
//            val ringtone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
//                val ringtoneAttrs = AudioAttributes.Builder()
//                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
//                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
//                    .build()
//                notificationChannel.setSound(ringtone, ringtoneAttrs)
                builder.setChannelId(callNotificationChannelId)
                notificationManager.createNotificationChannel(
                    notificationChannel
                )
            } else {
                // This is a custom action assignment in case the API does not accept remote views
                // TODO: need to test this
                val declineAction = NotificationCompat.Action.Builder(android.R.drawable.ic_menu_delete, context.getString(R.string.decline), declinePendingIntent).build()
                val acceptAction = NotificationCompat.Action.Builder(android.R.drawable.ic_menu_call, context.getString(R.string.accept), acceptPendingIntent).build()
                builder.addAction(declineAction)
                builder.addAction(acceptAction)
            }

            builder.setContentTitle(context.getString(R.string.incoming_call))
            builder.setContentText(contact.displayName)
            builder.setSmallIcon(R.drawable.status_on)
            builder.setAutoCancel(false)
            builder.setVibrate(longArrayOf(1000, 1000, 1000, 1000, 1000))
            builder.priority = NotificationCompat.PRIORITY_MAX
            builder.setCategory(NotificationCompat.CATEGORY_CALL)
            builder.setDefaults(Notification.FLAG_ONGOING_EVENT)
            builder.setTimeoutAfter(10000)
            builder.setDeleteIntent(declinePendingIntent)

            // This convoluted scheme is necessary to keep heads up notification up on some phones
            // like Huawei. See https://stackoverflow.com/a/61593818.
            if (calledFromService) {
                val notification = builder.build()
                notificationManager.notify(notificationId, notification)
                return
            }
            val serviceIntent = Intent(context, IncomingCallNotificationService::class.java)
            val intentExtras = Bundle()
            intentExtras.putString("signal", serializedSignal)
            serviceIntent.putExtras(intentExtras)
            val pendingServiceIntent = PendingIntent.getService(
                context,
                notificationId,
                serviceIntent,
                0
            )
            context.startService(serviceIntent)
        }
    }

    // TODO: fix when we merge messaging-android updates
    private fun getAvatarBgColor(id: String): Int {
        val hash = id.hashCode()
        val maxHash = 2147483647.rem(2).toFloat()
        val hue = maxOf(0.toFloat(), hash / maxHash * 360)
        val color = floatArrayOf(hue, 1.toFloat(), 0.3.toFloat())
        return ColorUtils.setAlphaComponent(ColorUtils.HSLToColor(color), 255)
    }

    fun declineAndDismiss(
        context: Context,
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        callNotificationIds.remove(signal.senderId)?.let { notificationId ->
            notificationManager.cancel(notificationId)
        }
        context.stopService(Intent(context, IncomingCallNotificationService::class.java))
    }

    private fun paintAvatar(contact: Model.Contact, customNotification: RemoteViews) {
        val bitmap = Bitmap.createBitmap(400, 400, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paintBg = Paint()
        val paintAv = Paint()
        val paintStroke = Paint()
        paintAv.isAntiAlias = true
        paintBg.isAntiAlias = true
        paintStroke.isAntiAlias = true
        paintBg.color = getAvatarBgColor(contact.contactId.id)
        paintStroke.color = Color.WHITE
        canvas.drawCircle(200.toFloat(), 200.toFloat(), 200.toFloat(), paintStroke)
        canvas.drawCircle(200.toFloat(), 200.toFloat(), 195.toFloat(), paintBg)
        paintAv.color = Color.WHITE
        paintAv.textSize = 150.toFloat()
        canvas.drawText(contact.displayName.take(2).toUpperCase(), 100.toFloat(), 250.toFloat(), paintAv)

        // update customNotification
        customNotification.setImageViewBitmap(R.id.avatar, bitmap)
    }
}

class SignalingMessage {
    var type: String? = null
}
