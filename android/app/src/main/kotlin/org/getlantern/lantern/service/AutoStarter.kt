package org.getlantern.lantern.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.getlantern.mobilesdk.Logger

open class AutoStarter : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Logger.d(TAG, "Automatically starting Lantern Service on: ${intent.action}")
        val serviceIntent = Intent(context, LanternService_::class.java)
            .putExtra(LanternService.AUTO_BOOTED, intent.action == Intent.ACTION_BOOT_COMPLETED)
        context.startService(serviceIntent)
    }

    companion object {
        private val TAG = AutoStarter::class.java.simpleName
    }
}
