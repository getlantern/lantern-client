package org.getlantern.lantern.notification

import android.annotation.TargetApi
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import androidx.core.app.NotificationCompat
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.mobilesdk.Logger

/**
 * Handles notifications.
 */
class Notifier : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        Logger.i(TAG, "Notifying" + intent.action)

        val notificationId: Int
        val resources = context.resources

        // See http://developer.android.com/guide/topics/ui/notifiers/notifications.html
        val builder = NotificationCompat.Builder(context)
            .setContentTitle(resources.getString(R.string.lantern_notification))
            .setAutoCancel(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setSmallIcon(R.drawable.icon_alert_white)
        } else {
            builder.setSmallIcon(R.drawable.notification_icon)
        }

        when (intent.action) {

            ACTION_DATA_USAGE -> {
                notificationId = NOTIFICATION_ID_DATA_USAGE
                val text = intent.getStringExtra(EXTRA_TEXT)

                builder.setChannelId(CHANNEL_DATA_USAGE)
                builder.setContentText(text)
                builder.setStyle(NotificationCompat.BigTextStyle().bigText(text))
            }

            else -> {
                Logger.debug(TAG, "Got invalid broadcast " + intent.action)
                return
            }
        }

        val resultIntent = Intent(context, MainActivity::class.java)

        // For unknown reason, passing this (instead of zero) resumes the
        // existing activity if possible, instead of creating a new one.
        val requestCode = System.currentTimeMillis().toInt()
        val resultPendingIntent = PendingIntent.getActivity(
            context,
            requestCode,
            resultIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        builder.setContentIntent(resultPendingIntent)
        val notification = builder.build()

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, notification)
    }

    /**
     * See https://android.googlesource.com/platform/packages/experimental/+/363b69b578809b2d5f7ea49d186197797590fac4/NotificationShowcase/src/com/android/example/notificationshowcase/NotificationShowcaseActivity.java for example.
     */
    private fun getBitmap(resources: Resources, iconId: Int): Bitmap {
        val width = resources.getDimension(android.R.dimen.notification_large_icon_width).toInt()
        val height = resources.getDimension(android.R.dimen.notification_large_icon_height).toInt()
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val c = Canvas(bitmap)
        val d = resources.getDrawable(iconId)
        d.setBounds(0, 0, width, height)
        d.draw(c)
        return bitmap
    }

    companion object {
        private const val TAG = "Notifier"

        const val CHANNEL_DATA_USAGE = "Data Usage"

        const val ACTION_DATA_USAGE = BuildConfig.APPLICATION_ID + ".intent.DATA_USAGE"

        const val NOTIFICATION_ID_DATA_USAGE = 100

        const val EXTRA_TEXT = "text"

        init {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                createNotificationChannels()
            }
        }

        @TargetApi(Build.VERSION_CODES.O)
        private fun createNotificationChannels() {
            val notificationManager = LanternApp.getAppContext()
                .getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // create a channel for data usage notifications
            notificationManager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_DATA_USAGE,
                    CHANNEL_DATA_USAGE,
                    NotificationManager.IMPORTANCE_DEFAULT
                )
            )

            // create other notification channels
        }
    }
}
