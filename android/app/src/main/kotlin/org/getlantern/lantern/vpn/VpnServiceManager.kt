package org.getlantern.lantern.vpn

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.lantern.notification.NotificationReceiver
import org.getlantern.mobilesdk.Logger


class VpnServiceManager(private val context: Context) {
	private val broadcastReceiver = NotificationReceiver()
	private val notifications = NotificationHelper(context, broadcastReceiver)
	private var lanternVpnService: LanternVpnService? = null

	private val serviceConnection = object : ServiceConnection {
	    override fun onServiceConnected(name: ComponentName?, binder: IBinder) {
	      lanternVpnService = (binder as LanternVpnService.LocalBinder).service
	    }

	    override fun onServiceDisconnected(name: ComponentName?) {
	      lanternVpnService = null
	    }
	 }

  	fun init() {
  		val packageName = context.packageName
    	LocalBroadcastManager.getInstance(context)
      		.registerReceiver(broadcastReceiver, IntentFilter("$packageName.intent.VPN_DISCONNECTED"))
  	}

  	fun connect() {
  		val intent = Intent(context, LanternVpnService::class.java).apply {
  			action = LanternVpnService.ACTION_CONNECT
  		}
  		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
  			context.startForegroundService(intent)
  		} else {
  			context.startService(intent)
  			notifications.vpnConnectedNotification()
  		}
  	}

  	fun disconnect() {
  		context.sendBroadcast(notifications.disconnectIntent())
        context.startService(Intent(context, LanternVpnService::class.java).apply {
        	action = LanternVpnService.ACTION_DISCONNECT
        })
  	}

    fun bind() {
        if (lanternVpnService != null) return
        val intent = Intent(context, LanternVpnService::class.java)
        context.bindService(intent, serviceConnection, 0)
    }

	fun unbind() {
	    LocalBroadcastManager.getInstance(context).unregisterReceiver(broadcastReceiver)
		context.unbindService(serviceConnection)    
  	}

}