@file:JvmName("ServiceHelper")

package org.getlantern.lantern.service

import android.annotation.TargetApi
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.mobilesdk.Logger
import java.util.concurrent.LinkedBlockingDeque
import java.util.concurrent.atomic.AtomicBoolean

class ServiceHelper(
    private val service: Service,
    private val defaultIcon: Int?,
    private val defaultText: Int
) {
    private val foregrounded = AtomicBoolean(false)

    fun makeForeground() {
        try {
            val serviceIcon = defaultIcon
                ?: if (LanternApp.session.chatEnabled()) {
                    R.drawable.status_chat
                } else {
                    R.drawable.status_plain
                }
            if (foregrounded.compareAndSet(false, true)) {
                val doIt = {
                    service.startForeground(
                        notificationId,
                        buildNotification(serviceIcon, defaultText)
                    )
                }
                serviceDeque.push(doIt)
                doIt()
            }
        } catch (e: Exception) {
            Logger.debug("ServiceHelper", "Failed to make service foreground", e)
        }

    }

    fun onDestroy() {
        if (foregrounded.compareAndSet(true, false)) {
            serviceDeque.pop()
            // Put the prior service that was in the foreground back into the foreground
            serviceDeque.peekLast()?.let { it() }
        }
    }

    fun updateNotification(icon: Int, text: Int) {
        with(NotificationManagerCompat.from(service)) {
            notify(notificationId, buildNotification(icon, text))
        }
    }

    private fun buildNotification(icon: Int, text: Int): Notification {
        var channelId: String? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            channelId = createNotificationChannel()
        } else {
            // If earlier version channel ID is not used
            // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
        }
        val openMainActivity = PendingIntent.getActivity(
            service, 0, Intent(service, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        val notificationBuilder = channelId?.let { NotificationCompat.Builder(service, it) }
            ?: NotificationCompat.Builder(service)
        notificationBuilder.setSmallIcon(icon)
        val appName = service.getText(R.string.app_name)
        notificationBuilder.setContentTitle(appName)
        val content = service.getText(text)
        notificationBuilder.setContentText(content)
        notificationBuilder.setContentIntent(openMainActivity)
        notificationBuilder.setBadgeIconType(NotificationCompat.BADGE_ICON_NONE)
        notificationBuilder.setNumber(0)
        notificationBuilder.setOngoing(true)
        return notificationBuilder.build()
    }

    @TargetApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(): String {
        val channelId = "lantern_service"
        val channelName = LanternApp.getAppContext().resources.getString(R.string.lantern_service)
        val mNotificationManager =
            service.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.createNotificationChannel(
            NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
        )
        return channelId
    }

    companion object ServiceHelper {
        private const val notificationId = 1
        private val serviceDeque = LinkedBlockingDeque<() -> Unit>()
    }
}
