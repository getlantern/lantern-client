package org.getlantern.lantern.model;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;

import androidx.core.app.NotificationCompat;

import org.getlantern.lantern.activity.LanternFreeActivity;
import org.getlantern.lantern.R;

import org.getlantern.mobilesdk.Logger;

/**
 * Handles notifications.
 */
public class Notify extends BroadcastReceiver {
    private static final String TAG = "Notify";

    public void onReceive(Context context, Intent intent) {
        Logger.i(TAG, "Notifying" + intent.getAction());

        final int notificationId = 100;
        final Resources resources = context.getResources();
        Bitmap largeIcon = getBitmap(resources, R.drawable.app_icon);

        // See http://developer.android.com/guide/topics/ui/notifiers/notifications.html
        NotificationCompat.Builder mBuilder =
            new NotificationCompat.Builder(context)
            .setSmallIcon(R.drawable.notification_icon)
            .setContentTitle(resources.getString(R.string.lantern_notification))
            .setAutoCancel(true);

        switch (intent.getAction()) {
            case "org.getlantern.lantern.intent.DATA_USAGE":
                mBuilder.setContentText(intent.getStringExtra("text"));
                break;
            default:
                Logger.debug(TAG, "Got invalid broadcast " + intent.getAction());
                return;
        }

        final Intent resultIntent = new Intent(context,
                LanternFreeActivity.class);
        // For unknown reason, passing this (instead of zero) resumes the
        // existing activity if possible, instead of creating a new one.
        int requestCode = (int)System.currentTimeMillis();
        PendingIntent resultPendingIntent =
            PendingIntent.getActivity(context, requestCode,
                    resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        mBuilder.setContentIntent(resultPendingIntent);

        NotificationManager mNotificationManager =
            (NotificationManager)context.getSystemService(android.content.Context.NOTIFICATION_SERVICE);
        Notification notification = mBuilder.build();
        mNotificationManager.notify(notificationId, notification);
    }

    /**
     * See https://android.googlesource.com/platform/packages/experimental/+/363b69b578809b2d5f7ea49d186197797590fac4/NotificationShowcase/src/com/android/example/notificationshowcase/NotificationShowcaseActivity.java for example.
     */
    private Bitmap getBitmap(Resources resources, int iconId) {
        int width = (int) resources.getDimension(android.R.dimen.notification_large_icon_width);
        int height = (int) resources.getDimension(android.R.dimen.notification_large_icon_height);
        Drawable d = resources.getDrawable(iconId);
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas c = new Canvas(bitmap);
        d.setBounds(0, 0, width, height);
        d.draw(c);
        return bitmap;
    }
}
