package org.getlantern.lantern.service

import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import org.getlantern.lantern.util.Json
import io.lantern.messaging.WebRTCSignal
import org.getlantern.lantern.LanternApp

class IncomingCallNotificationService : Service() {
    var notifying = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val signal = Json.gson.fromJson(intent!!.getStringExtra("signal"), WebRTCSignal::class.java)

        if (!notifying) {
            LanternApp.messaging.notifyCall(
                this,
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager,
                signal
            )
            stopSelf()
            notifying = true
        }
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onBind(intent: Intent?): IBinder? = null
}