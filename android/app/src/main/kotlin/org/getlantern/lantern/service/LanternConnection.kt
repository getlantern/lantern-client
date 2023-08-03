package org.getlantern.lantern.service

import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import org.getlantern.lantern.vpn.LanternVpnService

class LanternConnection(private var isVpnService: Boolean = false) : ServiceConnection {
    private var binder: IBinder? = null

    // private var callback: Callback? = null
    private var connectionActive = false
    var service: Service? = null

    val serviceClass
        get() = when (isVpnService) {
            true -> LanternVpnService::class
            else -> LanternService::class
        }.java

    override fun onServiceConnected(name: ComponentName?, binder: IBinder) {
        this.binder = binder
        this.service = (binder as LanternVpnService.LocalBinder).service
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        service = null
        binder = null
    }

    fun connect(context: Context) {
        if (connectionActive) return
        connectionActive = true
        val intent = Intent(context, serviceClass)
        context.bindService(intent, this, Context.BIND_AUTO_CREATE)
    }

    fun disconnect(context: Context) {
        if (connectionActive) {
            try {
                context.unbindService(this)
            } catch (_: IllegalArgumentException) {
            }
        }
        connectionActive = false
        binder = null
        service = null
    }
}
