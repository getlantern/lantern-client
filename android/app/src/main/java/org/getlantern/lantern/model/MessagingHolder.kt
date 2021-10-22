package org.getlantern.lantern.model

import android.app.Application
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.graphics.ColorUtils
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
import java.math.BigInteger
import java.security.MessageDigest
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference
import kotlin.concurrent.thread

internal const val messageNotificationChannelId = "10001"
internal const val callNotificationChannelId = "10002"
internal const val defaultNotificationChannelId = "default"

class MessagingHolder {
    lateinit var messaging: Messaging
    private val contactNotificationIds = HashMap<Model.ContactId, Int>()
    private var nextNotificationId = 5000
    private val incomingCalls = HashMap<String, Notification>()
    private val ringer = Executors.newSingleThreadScheduledExecutor { r ->
        Thread(r, "ringer-thread")
    }

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
            messaging.subscribeToWebRTCSignals("messagingholder") { signal ->
                val msg = Json.gson.fromJson(
                    signal.content.toString(Charsets.UTF_8),
                    SignalingMessage::class.java
                )
                when (msg.type) {
                    "offer" -> notifyCall(application, notificationManager, signal)
                    "bye" -> dismissIncomingCallNotification(notificationManager, signal)
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
                builder.setContentTitle(application.getString(R.string.new_message))
                val contentString = application.getString(
                    R.string.from_sender,
                    displayName(application, contact)
                )
                builder.setContentText(contentString)
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
        context: Context,
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        val serializedSignal = Json.gson.toJson(signal)
        val contact =
            messaging.db.get<Model.Contact>(signal.senderId.directContactPath)
        contact?.let {
            val notificationId = nextNotificationId++
            val acceptPendingIntent = acceptIntent(
                context,
                notificationId,
                serializedSignal
            )
            val declinePendingIntent = declineIntent(
                context,
                notificationId,
                serializedSignal
            )

            val notification = incomingCallNotification(
                context,
                notificationManager,
                notificationId,
                contact,
                acceptPendingIntent,
                declinePendingIntent
            )
            val ring = object : Runnable {
                override fun run() {
                    playRingtone(context)
                    notificationManager.notify(notificationId, notification)
                    // on some phones like Huawei, the heads up notification only stays heads up
                    // for a few seconds, so we re-notify every second while ringing in order to
                    // keep it heads up
                    ringer.schedule(
                        {
                            if (incomingCalls.containsKey(signal.senderId)) {
                                run()
                            }
                        },
                        2, TimeUnit.SECONDS
                    )
                }
            }
            ringer.execute {
                incomingCalls[signal.senderId] = notification
                ring.run()
            }
        }
    }

    private fun acceptIntent(
        context: Context,
        notificationId: Int,
        serializedSignal: String
    ): PendingIntent {
        // accept intent - we use Bundle() since we are sending two params
        val acceptIntentExtras = Bundle()
        val acceptIntent =
            Intent(context, MainActivity::class.java)
        acceptIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
        acceptIntentExtras.putString("signal", serializedSignal)
        acceptIntentExtras.putBoolean("accepted", true)
        acceptIntent.putExtras(acceptIntentExtras)

        return PendingIntent.getActivity(
            context,
            notificationId,
            acceptIntent,
            PendingIntent.FLAG_ONE_SHOT
        )
    }

    private fun declineIntent(
        context: Context,
        notificationId: Int,
        serializedSignal: String
    ): PendingIntent {
        // decline intent
        val declineIntent =
            Intent(context, DeclineCallBroadcastReceiver::class.java)
        val declineIntentExtras = Bundle()
        declineIntent.flags = Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
        declineIntentExtras.putString("signal", serializedSignal)
        declineIntentExtras.putInt("notificationId", notificationId)
        declineIntent.putExtras(declineIntentExtras)

        return PendingIntent.getBroadcast(
            context,
            notificationId,
            declineIntent,
            PendingIntent.FLAG_ONE_SHOT
        )
    }

    fun incomingCallNotification(
        context: Context,
        notificationManager: NotificationManager,
        notificationId: Int,
        contact: Model.Contact,
        acceptPendingIntent: PendingIntent,
        declinePendingIntent: PendingIntent
    ): Notification {
        val builder = NotificationCompat.Builder(
            context,
            defaultNotificationChannelId
        )

        // Attach RemoteView to builder()
        builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
        builder.setCustomContentView(
            incomingCallRemoteView(
                context,
                contact,
                acceptPendingIntent,
                declinePendingIntent,
            )
        )
        builder.setContentTitle(context.getString(R.string.incoming_call))
        builder.setContentText(displayName(context, contact))
        builder.setSmallIcon(R.drawable.status_on)
        builder.setAutoCancel(false)
        builder.priority = NotificationCompat.PRIORITY_MAX
        builder.setCategory(NotificationCompat.CATEGORY_CALL)
        builder.setTimeoutAfter(30000)
        builder.setDeleteIntent(declinePendingIntent)
        builder.extras.putInt("notificationId", notificationId)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val notificationChannel = NotificationChannel(
                callNotificationChannelId,
                "CallNotificationChannel",
                importance
            )
            notificationChannel.enableVibration(true)
            notificationChannel.enableLights(true)
            builder.setChannelId(callNotificationChannelId)
            notificationManager.createNotificationChannel(
                notificationChannel
            )
        } else {
            // This is a custom action assignment in case the API does not accept remote views
            // TODO: need to test this
            val declineAction = NotificationCompat.Action.Builder(
                android.R.drawable.ic_menu_delete,
                context.getString(R.string.decline),
                declinePendingIntent
            ).build()
            val acceptAction = NotificationCompat.Action.Builder(
                android.R.drawable.ic_menu_call,
                context.getString(R.string.accept),
                acceptPendingIntent
            ).build()
            builder.addAction(declineAction)
            builder.addAction(acceptAction)
        }

        return builder.build()
    }

    private fun incomingCallRemoteView(
        context: Context,
        contact: Model.Contact,
        acceptPendingIntent: PendingIntent,
        declinePendingIntent: PendingIntent,
    ): RemoteViews {
        // RemoteViews styles
        val remoteView = RemoteViews(context.packageName, R.layout.notification_custom)
        remoteView.setTextViewText(R.id.caller, displayName(context, contact))
        remoteView.setTextViewText(R.id.incomingCall, context.getString(R.string.incoming_call))
        remoteView.setTextViewText(R.id.btnAccept, context.getString(R.string.accept))
        remoteView.setTextViewText(R.id.btnDecline, context.getString(R.string.decline))
        paintAvatar(contact, remoteView)

        // Set button intents
        remoteView.setOnClickPendingIntent(R.id.btnDecline, declinePendingIntent)
        remoteView.setOnClickPendingIntent(R.id.btnAccept, acceptPendingIntent)

        return remoteView
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
        canvas.drawText(contact.displayName.take(2).toUpperCase(), 125.toFloat(), 250.toFloat(), paintAv)

        // update customNotification
        customNotification.setImageViewBitmap(R.id.avatar, bitmap)
    }

    private fun getAvatarBgColor(id: String): Int {
        val color = floatArrayOf(id.sha1(360).toFloat(), 1.toFloat(), 0.3.toFloat())
        return ColorUtils.setAlphaComponent(ColorUtils.HSLToColor(color), 255)
    }

    /**
     * Calculates a SHA1 hash of the string's UTF-8 representation, coerced to a scaled integer between
     * 0 and max inclusive.
     */
    private fun String.sha1(max: Long): Long {
        val maxSha1Hash = BigInteger.valueOf(2).pow(160)
        val bytes = MessageDigest.getInstance("SHA-1").digest(this.toByteArray(Charsets.UTF_8))
        return BigInteger(1, bytes).times(BigInteger.valueOf(max)).div(maxSha1Hash).toLong()
    }

    // remove notification, stop ringtone
    fun dismissIncomingCallNotification(
        notificationManager: NotificationManager,
        signal: WebRTCSignal
    ) {
        ringer.execute {
            incomingCalls.remove(signal.senderId)?.let { notification ->
                notificationManager.cancel(notification.extras.getInt("notificationId"))
                stopPlayingRingtone()
            }
        }
    }

    private fun displayName(context: Context, contact: Model.Contact): String =
        if (contact.displayName.isEmpty())
            context.getString(R.string.unnamed_contact)
        else
            contact.displayName

    companion object {
        private val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        private val vibrationPattern = longArrayOf(0, 10, 200, 500, 700, 1000, 300, 200, 50, 10)
        private var playingRingtone = false
        private var ringtone: Ringtone? = null
        private var vibrator: Vibrator? = null

        @Synchronized
        private fun playRingtone(context: Context) {
            if (!playingRingtone) {
                playingRingtone = true
                vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                vibrator!!.vibrate(VibrationEffect.createWaveform(vibrationPattern, 0))
                ringtone = RingtoneManager.getRingtone(context, ringtoneUri)
                val rtone = ringtone!!
                thread {
                    rtone.play()
                }
            }
        }

        @Synchronized
        private fun stopPlayingRingtone() {
            if (playingRingtone) {
                playingRingtone = false
                ringtone!!.stop()
                ringtone = null
                vibrator!!.cancel()
                vibrator = null
            }
        }
    }
}

class SignalingMessage {
    var type: String? = null
}
