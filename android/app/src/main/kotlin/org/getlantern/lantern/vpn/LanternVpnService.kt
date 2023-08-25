package org.getlantern.lantern.vpn

import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.ParcelFileDescriptor
import internalsdk.Internalsdk
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.notification.Notifications
import org.getlantern.lantern.service.ServiceManager
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.SessionManager
import java.util.Locale

class LanternVpnService : VpnService(), ServiceManager.Runner {

    companion object {
        private val TAG = LanternVpnService::class.java.simpleName
        private const val sessionName = "LanternVpn"
        private const val privateAddress = "10.0.0.2"
        private const val VPN_MTU = 1500
    }

    lateinit var conn: ParcelFileDescriptor
    private val binder = LocalBinder()
    override val data = ServiceManager.Data(this)

    inner class LocalBinder : Binder() {
        val service
            get() = this@LanternVpnService
    }

    override fun onRevoke() = stopRunner()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return super<ServiceManager.Runner>.onStartCommand(intent, flags, startId)
    }

    override suspend fun startProcesses() = startVpn()

    @Synchronized
    private fun createBuilder(): ParcelFileDescriptor? {
        val builder = Builder()
        // Set the locale to English
        // since the VpnBuilder encounters
        // issues with non-English numerals
        // See https://code.google.com/p/android/issues/detail?id=61096
        Locale.setDefault(Locale("en"))

        // Configure a builder while parsing the parameters.
        builder.setMtu(VPN_MTU)
        builder.addAddress(privateAddress, 24)
        // route IPv4 through VPN
        builder.addRoute("0.0.0.0", 0)

        if (LanternApp.getSession().splitTunnelingEnabled()) {
            val appsAllowedAccess = HashSet(LanternApp.getSession().appsAllowedAccess())
            // Exclude any app that's not in our split tunneling allowed list
            for (installedApp in packageManager.getInstalledApplications(0)) {
                if (!appsAllowedAccess.contains(installedApp.packageName)) {
                    try {
                        Logger.debug(TAG, "Excluding " + installedApp.packageName +
                            " from VPN")
                        builder.addDisallowedApplication(installedApp.packageName)
                    } catch (e: PackageManager.NameNotFoundException) {
                        throw RuntimeException("Unable to exclude " +
                            installedApp.packageName + " from VPN", e)
                    }
                }
            }
        }

        // Never capture traffic originating from Lantern itself in the VPN.
        try {
            val ourPackageName = getPackageName()
            builder.addDisallowedApplication(ourPackageName)
        } catch (e: PackageManager.NameNotFoundException) {
            throw RuntimeException("Unable to exclude Lantern from routes", e)
        }
        // don't currently route IPv6 through VPN because our proxies don't currently
        // support IPv6. see https://github.com/getlantern/lantern-internal/issues/4961
        // Note - if someone performs a DNS lookup for an IPv6 only host like
        // ipv6.google.com, dnsgrab will return an IPv4 address for that site, causing
        // the traffic to get routed through the VPN.

        // this is a fake DNS server. The precise IP doesn't matter because Lantern will
        // intercept and  route all DNS traffic to dnsgrab internally anyway.
        builder.addDnsServer(SessionManager.fakeDnsIP)

        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE,
        )
        builder.setConfigureIntent(pendingIntent)

        builder.setSession(sessionName)

        // Create a new mInterface using the builder and save the parameters.
        return builder.establish()
    }

    private fun serviceNotification() = startForeground(1,
        Notifications.builder(this).build())

    private fun startVpn() {
        val builder = Builder()
        val defaultLocale = Locale.getDefault()
        try {
            if (Build.VERSION.SDK_INT >= 26) serviceNotification()
            Logger.debug(TAG, "Creating VpnBuilder before starting tun2socks")
            conn = createBuilder() ?: return
            val tunFd = conn.getFd()
            Logger.debug(TAG, "Running tun2socks")
            Internalsdk.tun2Socks(
                tunFd.toLong(),
                LanternApp.getSession().sOCKS5Addr,
                LanternApp.getSession().dNSGrabAddr,
                VPN_MTU.toLong(),
                LanternApp.getSession(),
            )
        } catch (t: Throwable) {
            Logger.e(TAG, "Exception while handling TUN device", t)
        } finally {
            Locale.setDefault(defaultLocale)
        }
    }

    @Synchronized
    private fun stopVpn() {
        if (::conn.isInitialized) conn.close()
    }

    override fun killProcesses() {
        Logger.d(TAG, "stop")
        try {
            Logger.d(TAG, "stop")
            Internalsdk.stopTun2Socks()
            stopVpn()
            stopForeground(true)
        } catch (t: Throwable) {
            Logger.e(TAG, "error stopping tun2socks", t)
        }
    }
}
