package org.getlantern.lantern.model

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

// see https://www.tutorialspoint.com/how-to-create-android-notification-with-broadcastreceiver

class DeclineCallBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
//        intent!!.getStringExtra("signal")?.let { signal ->
//            LanternApp.messaging.dismissIncomingCallNotification(
//                (context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager?)!!,
//                Json.gson.fromJson(signal, WebRTCSignal::class.java)
//            )
//        }
    }
}
