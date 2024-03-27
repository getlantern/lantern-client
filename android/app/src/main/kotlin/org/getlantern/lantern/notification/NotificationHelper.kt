package org.getlantern.lantern.notification

import android.annotation.TargetApi
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContextWrapper
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R

class NotificationHelper(
    private val activity: Activity,
    private val receiver: NotificationReceiver
) : ContextWrapper(activity) {

    // Used to notify a user of events that happen in the background
    private val manager: NotificationManager =
        getSystemService(NOTIFICATION_SERVICE) as NotificationManager

    private lateinit var dataUsageNotificationChannel: NotificationChannel
    private lateinit var vpnNotificationChannel: NotificationChannel
    private lateinit var vpnBuilder: NotificationCompat.Builder
    private lateinit var dataUsageBuilder: NotificationCompat.Builder


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
        notificationChannel.setSound(null, null)
        manager.createNotificationChannel(notificationChannel)
    }

    fun disconnectIntent(): Intent {
        val packageName = activity.packageName
        return Intent(activity, NotificationReceiver::class.java).apply {
            action = "$packageName.intent.VPN_DISCONNECTED"
        }
    }

    private fun disconnectBroadcast(): PendingIntent {
        // Retrieve a PendingIntent that will perform a broadcast
        return PendingIntent.getBroadcast(
            activity,
            0,
            disconnectIntent(),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }


    fun vpnConnectedNotification() {
        manager.notify(VPN_CONNECTED, vpnBuilder.build())
    }

    fun dataUsageNotification() {
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
        private const val CHANNEL_VPN = "lantern_vpn"
        private const val CHANNEL_DATA_USAGE = "data_usage"
        private const val VPN_DESC = "VPN"
        private const val DATA_USAGE_DESC = "Data Usage"
    }

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            initChannels()
        }
        val contentIntent = PendingIntent.getActivity(
            activity,
            0,
            Intent(activity, MainActivity::class.java),
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
            .setContentTitle(activity.getString(R.string.service_connected))
            .addAction(
                android.R.drawable.ic_delete,
                activity.getString(R.string.disconnect),
                disconnectBroadcast()
            )
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setShowWhen(true)
            .setSmallIcon(R.drawable.lantern_notification_icon)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    }
}
