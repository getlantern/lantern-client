package org.getlantern.lantern.notification

import android.annotation.TargetApi
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.getlantern.lantern.Actions
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R

class Notifications(
    private val context: Context
) {
    val builder: (Service) -> NotificationCompat.Builder by lazy {
        {
        NotificationCompat.Builder(it as Context, CHANNEL_VPN)
            .setContentTitle(context.getString(R.string.service_connected))
            .setContentIntent(PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            ))
            .addAction(
                android.R.drawable.ic_delete,
                context.getString(R.string.disconnect),
                PendingIntent.getBroadcast(
                    context,
                    0,
                    Intent(Actions.DISCONNECT_VPN).setPackage(it.packageName),
                    /*Intent(context, MainActivity::class.java).apply {
                        action = Actions.DISCONNECT_VPN
                    },*/
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            .setOngoing(true)
            .setShowWhen(true)
            .setSmallIcon(R.drawable.lantern_notification_icon)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        }
    }

    companion object {
        private val TAG = Notifications::class.java.simpleName
        const val notificationId = 1
        private const val CHANNEL_VPN = "service-vpn"

        init {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                initChannels()
            }
        }

        @TargetApi(Build.VERSION_CODES.O)
        private fun initChannels() {
            LanternApp.notificationManager.createNotificationChannel(NotificationChannel(
                CHANNEL_VPN,
                LanternApp.getAppContext().resources.getString(R.string.lantern_service),
                NotificationManager.IMPORTANCE_HIGH,
            ))
        }
    }
}
