package org.getlantern.lantern.util

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

fun broadcastReceiver(callback: (Context, Intent) -> Unit): BroadcastReceiver =
    object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) = callback(context, intent)
    }