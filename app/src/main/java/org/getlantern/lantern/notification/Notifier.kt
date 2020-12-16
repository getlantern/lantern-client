package org.getlantern.lantern.notification

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.core.app.NotificationCompat
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.LanternFreeActivity
import org.getlantern.mobilesdk.Logger

/**
 * Handles notifications.
 */
class Notifier : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        Logger.i(TAG, "Notifying" + intent.action)

        val notificationId = 100
        val resources = context.resources
        val largeIcon = getBitmap(resources, R.drawable.app_icon)

        // See http://developer.android.com/guide/topics/ui/notifiers/notifications.html
        val mBuilder = NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.notification_icon)
                .setContentTitle(resources.getString(R.string.lantern_notification))
                .setAutoCancel(true)

        when (intent.action) {

            ACTION_DATA_USAGE -> mBuilder.setContentText(intent.getStringExtra("text"))

            else -> {
                Logger.debug(TAG, "Got invalid broadcast " + intent.action)
                return
            }
        }

        val resultIntent = Intent(context, LanternFreeActivity::class.java)

        // For unknown reason, passing this (instead of zero) resumes the
        // existing activity if possible, instead of creating a new one.
        val requestCode = System.currentTimeMillis().toInt()
        val resultPendingIntent = PendingIntent.getActivity(
                context,
                requestCode,
                resultIntent,
                PendingIntent.FLAG_UPDATE_CURRENT)
        mBuilder.setContentIntent(resultPendingIntent)
        val notification = mBuilder.build()

        val mNotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.notify(notificationId, notification)
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

        const val ACTION_DATA_USAGE = BuildConfig.APPLICATION_ID + ".intent.DATA_USAGE"
    }
}