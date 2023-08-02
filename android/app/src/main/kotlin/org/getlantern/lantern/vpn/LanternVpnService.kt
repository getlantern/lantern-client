package org.getlantern.lantern.vpn

import android.annotation.TargetApi
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.service.BaseService
import org.getlantern.lantern.service.LanternService_
import org.getlantern.mobilesdk.Logger

class LanternVpnService : VpnService(), BaseService.Service, Runnable {

    companion object {
        const val ACTION_CONNECT = "org.getlantern.lantern.vpn.START"
        const val ACTION_DISCONNECT = "org.getlantern.lantern.vpn.STOP"
        private val TAG = LanternVpnService::class.java.simpleName
    }

    private var provider: Provider? = null
    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        val service
            get() = this@LanternVpnService
    }

    private fun createNotification() {
        val channelID = "service-vpn"
        val channel = NotificationChannel(channelID, "Lantern VPN service", NotificationManager.IMPORTANCE_DEFAULT)
        val notify = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notify.createNotificationChannel(channel)
        startForeground(1, NotificationCompat.Builder(this, channelID)
                .setContentTitle("")
                .setContentText("").build())
    }

    override fun onCreate() {
        super.onCreate()
        Logger.d(TAG, "VpnService created")
    }

    override fun onDestroy() {
        Logger.d(TAG, "destroyed")
        doStop()
        super.onDestroy()
    }

    override fun onRevoke() {
        Logger.d(TAG, "revoked")
        stop()
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        return if (intent.action == ACTION_DISCONNECT) {
            stop()
            START_NOT_STICKY
        } else {
            //super<BaseService.Service>.onStart(intent)
            if (Build.VERSION.SDK_INT >= 26) createNotification()
            LanternApp.getSession().updateVpnPreference(true)
            connect()
            START_STICKY
        }
    }

    private fun connect() {
        Logger.d(TAG, "connect")
        Thread(this, "VpnService").start()
    }

    override fun run() {
        try {
            Logger.d(TAG, "Loading Lantern library")
            getOrInitProvider()?.run(
                this,
                Builder(),
                LanternApp.getSession().sOCKS5Addr,
                LanternApp.getSession().dNSGrabAddr,
            )
        } catch (e: Exception) {
            Logger.error(TAG, "Error running VPN", e)
        } finally {
            Logger.debug(TAG, "Lantern terminated.")
            stop()
        }
    }

    fun stop() {
        doStop()
        stopSelf()
        Logger.d(TAG, "Done stopping")
    }

    private fun doStop() {
        Logger.d(TAG, "stop")
        try {
            Logger.d(TAG, "getting provider")
            val provider: Provider? = getOrInitProvider()
            Logger.d(TAG, "stopping provider")
            provider?.stop()
        } catch (t: Throwable) {
            Logger.e(TAG, "error stopping provider", t)
        }
        try {
            Logger.d(TAG, "updating vpn preference")
            LanternApp.getSession().updateVpnPreference(false)
        } catch (t: Throwable) {
            Logger.e(TAG, "error updating vpn preference", t)
        }
    }

    @Synchronized fun getOrInitProvider(): Provider? {
        Logger.d(TAG, "getOrInitProvider()")
        if (provider == null) {
            Logger.d(TAG, "Using Go tun2socks")
            provider = GoTun2SocksProvider(
                getPackageManager(),
                LanternApp.getSession().splitTunnelingEnabled(),
                HashSet(LanternApp.getSession().appsAllowedAccess()),
            )
        }
        return provider
    }
}
