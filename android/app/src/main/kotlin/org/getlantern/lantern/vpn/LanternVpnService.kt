package org.getlantern.lantern.vpn

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.VpnService
import android.os.IBinder
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.service.LanternService
import org.getlantern.mobilesdk.Logger

class LanternVpnService : VpnService(), Runnable {

    companion object {
        const val ACTION_CONNECT = "org.getlantern.lantern.vpn.START"
        const val ACTION_DISCONNECT = "org.getlantern.lantern.vpn.STOP"
        private val TAG = LanternVpnService::class.java.simpleName
    }

    private var provider: Provider? = null

    private val lanternServiceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceDisconnected(name: ComponentName) {
            Logger.e(TAG, "LanternService disconnected, disconnecting VPN")
            stop()
        }

        override fun onServiceConnected(name: ComponentName, service: IBinder) {}
    }

    override fun onCreate() {
        super.onCreate()
        Logger.d(TAG, "VpnService created")
        bindService(
            Intent(this, LanternService::class.java),
            lanternServiceConnection,
            Context.BIND_AUTO_CREATE,
        )
    }

    override fun onDestroy() {
        Logger.d(TAG, "destroyed")
        doStop()
        super.onDestroy()
        unbindService(lanternServiceConnection)
    }

    override fun onRevoke() {
        Logger.d(TAG, "revoked")
        stop()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Somehow we are getting null here when running on Android 5.0
        // Handling null intent scenario
        if (intent == null) {
            Logger.d(TAG, "LanternVpnService: Received null intent, service is being restarted")
            return START_STICKY
        }
        return if (intent.action == ACTION_DISCONNECT) {
            stop()
            START_NOT_STICKY
        } else {
            LanternApp.session.updateVpnPreference(true)
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
            // If flashlight has not successfully started with a valid
            // SOCKS5 address, we should not start the VPN, as it will
            // simply fail.
            if (LanternApp.session.sOCKS5Addr.isNullOrEmpty()) {
                Logger.e(TAG, "socksAddr is null or empty")
                return
            }
            Logger.d(TAG, "Loading Lantern library")
            getOrInitProvider()?.run(
                this,
                Builder(),
                LanternApp.session.sOCKS5Addr,
                LanternApp.session.dNSGrabAddr,
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
            LanternApp.session.updateVpnPreference(false)
        } catch (t: Throwable) {
            Logger.e(TAG, "error updating vpn preference", t)
        }
    }

    @Synchronized
    fun getOrInitProvider(): Provider? {
        Logger.d(TAG, "getOrInitProvider()")
        if (provider == null) {
            Logger.d(TAG, "Using Go tun2socks")
            provider = GoTun2SocksProvider(
                packageManager,
                LanternApp.session.splitTunnelingEnabled(),
                HashSet(LanternApp.session.appsAllowedAccess()),
            )
        }
        return provider
    }
}
