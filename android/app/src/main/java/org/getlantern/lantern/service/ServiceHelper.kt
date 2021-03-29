package org.getlantern.lantern.service

import android.annotation.TargetApi
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import androidx.core.app.NotificationCompat
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.Launcher
import java.util.concurrent.ConcurrentLinkedDeque
import java.util.concurrent.LinkedBlockingDeque

class ServiceHelper(private val service: Service, private val largeIcon: Int, private val smallIcon: Int, private val content: Int) {
    fun makeForeground() {
        val doIt = {
            var channelId: String? = null
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                channelId = createNotificationChannel()
            } else {
                // If earlier version channel ID is not used
                // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
            }
            val openMainActivity = PendingIntent.getActivity(service, 0, Intent(service, Launcher::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT);
            val notification = NotificationCompat.Builder(service, channelId!!).setSmallIcon(smallIcon)
                    .setLargeIcon((service.getResources().getDrawable(largeIcon) as BitmapDrawable).bitmap)
                    .setContentTitle(service.getText(R.string.app_name)).setContentText(service.getText(content)).setContentIntent(openMainActivity).build()
            service.startForeground(1, notification)
        }
        serviceDeque.push(doIt)
        doIt()
    }

    fun onDestroy() {
        serviceDeque.pop()
        // Put the prior service that was in the foreground back into the foreground
        serviceDeque.peekLast()?.let { it() }
    }

    @TargetApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(): String? {
        val channelId = "lantern_service"
        val mNotificationManager = service.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.createNotificationChannel(
                NotificationChannel(channelId, channelId, NotificationManager.IMPORTANCE_DEFAULT))
        return channelId
    }

    companion object ServiceHelper {
        private val serviceDeque = LinkedBlockingDeque<() -> Unit>();
    }
}