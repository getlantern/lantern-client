package org.getlantern.lantern.notification

import android.annotation.TargetApi
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R

class NotificationHelper(
    private val context: Context,
    private val receiver: NotificationReceiver
) : ContextWrapper(context) {

    // Used to notify a user of events that happen in the background
    private val manager: NotificationManager =
        getSystemService(NOTIFICATION_SERVICE) as NotificationManager

    private lateinit var dataUsageNotificationChannel: NotificationChannel
    private lateinit var vpnNotificationChannel: NotificationChannel
    private var vpnBuilder: NotificationCompat.Builder
    private var dataUsageBuilder: NotificationCompat.Builder


    @TargetApi(Build.VERSION_CODES.O)
    private fun initChannels() {
        dataUsageNotificationChannel = NotificationChannel(
            CHANNEL_DATA_USAGE,
            DATA_USAGE_DESC,
            NotificationManager.IMPORTANCE_HIGH,
        )
        vpnNotificationChannel = NotificationChannel(
            CHANNEL_VPN,
            VPN_DESC,
            NotificationManager.IMPORTANCE_HIGH,
        )
        val channels: Array<NotificationChannel> = arrayOf(
            dataUsageNotificationChannel,
            vpnNotificationChannel,
        )
        channels.forEach { setChannelOptions(it) }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun setChannelOptions(notificationChannel: NotificationChannel) {
        notificationChannel.enableLights(true)
        notificationChannel.lightColor = Color.GREEN
        notificationChannel.enableVibration(false)
        manager.createNotificationChannel(notificationChannel)
    }

    fun disconnectIntent(): Intent {
        val packageName = context.packageName
        return Intent(context, NotificationReceiver::class.java).apply {
            action = "$packageName.intent.VPN_DISCONNECTED"
        }
    }

    private fun disconnectBroadcast(): PendingIntent {
        // Retrieve a PendingIntent that will perform a broadcast
        return PendingIntent.getBroadcast(
            context,
            0,
            disconnectIntent(),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }


    public fun vpnConnectedNotification() {
        manager.notify(VPN_CONNECTED, vpnBuilder.build())
    }

    public fun dataUsageNotification() {
        manager.notify(DATA_USAGE, dataUsageBuilder.build())
    }

    fun clearNotification() {
        manager.cancelAll()
    }

    companion object {
        private val TAG = NotificationHelper::class.java.simpleName
        private const val LANTERN_NOTIFICATION = "lantern.notification"
        private const val DATA_USAGE = 36
        const val VPN_CONNECTED = 37
        private const val CHANNEL_VPN = "vpn"
        private const val CHANNEL_DATA_USAGE = "data_usage"
        private const val VPN_DESC = "VPN"
        private const val DATA_USAGE_DESC = "Data Usage"
    }

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            initChannels()
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        // Configure vpnBuilder
        vpnBuilder = buildNotification(CHANNEL_VPN, contentIntent)

        // Configure dataUsageBuilder
        dataUsageBuilder = buildNotification(CHANNEL_DATA_USAGE, contentIntent)
    }


    private fun buildNotification(
        channelId: String,
        contentIntent: PendingIntent
    ): NotificationCompat.Builder {
        return NotificationCompat.Builder(this, channelId) // Channel ID provided as parameter
            .setContentTitle(context.getString(R.string.service_connected))
            .addAction(
                android.R.drawable.ic_delete,
                context.getString(R.string.disconnect),
                disconnectBroadcast()
            )
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setShowWhen(true)
            .setSmallIcon(R.drawable.lantern_notification_icon)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    }
}
