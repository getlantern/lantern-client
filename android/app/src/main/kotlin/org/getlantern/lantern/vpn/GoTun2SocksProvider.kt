package org.getlantern.lantern.vpn

import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.ParcelFileDescriptor
import internalsdk.Internalsdk
import io.lantern.model.SessionModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.mobilesdk.Logger


import java.util.Locale

class GoTun2SocksProvider(
    val packageManager: PackageManager,
    val splitTunnelingEnabled: Boolean,
    val appsAllowedAccess: Set<String>,
) : Provider {

    companion object {
        private val TAG = GoTun2SocksProvider::class.java.simpleName
        private const val sessionName = "LanternVpn"
        private const val privateAddress = "10.0.0.2"
        private const val VPN_MTU = 1500
    }

    private var mInterface: ParcelFileDescriptor? = null

    @Synchronized
    private fun createBuilder(
        vpnService: VpnService,
        builder: VpnService.Builder,
    ): ParcelFileDescriptor? {
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

        if (splitTunnelingEnabled) {
            // Exclude any app that's not in our split tunneling allowed list
            for (installedApp in packageManager.getInstalledApplications(0)) {
                if (!appsAllowedAccess.contains(installedApp.packageName)) {
                    try {
                        Logger.debug(TAG, "Excluding " + installedApp.packageName + " from VPN")
                        builder.addDisallowedApplication(installedApp.packageName)
                    } catch (e: PackageManager.NameNotFoundException) {
                        throw RuntimeException(
                            "Unable to exclude " + installedApp.packageName + " from VPN",
                            e
                        )
                    }
                }
            }
        }

        // Never capture traffic originating from Lantern itself in the VPN.
        try {
            val ourPackageName = vpnService.packageName
            builder.addDisallowedApplication(ourPackageName)
        } catch (e: PackageManager.NameNotFoundException) {
            throw RuntimeException("Unable to exclude Lantern from routes", e)
        }

        // don't currently route IPv6 through VPN because our proxies don't currently support IPv6
        // see https://github.com/getlantern/lantern-internal/issues/4961
        // Note - if someone performs a DNS lookup for an IPv6 only host like ipv6.google.com, dnsgrab
        // will return an IPv4 address for that site, causing the traffic to get routed through the VPN.
        // builder.addRoute("0:0:0:0:0:0:0:0", 0)

        // this is a fake DNS server. The precise IP doesn't matter because Lantern will intercept and
        // route all DNS traffic to dnsgrab internally anyway.
        builder.addDnsServer(SessionModel.fakeDnsIP)

        val intent = Intent(vpnService, MainActivity::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            vpnService,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE,
        )
        builder.setConfigureIntent(pendingIntent)

        builder.setSession(sessionName)

        // Create a new mInterface using the builder and save the parameters.
        mInterface = builder.establish()
        Logger.d(TAG, "New mInterface: " + mInterface)
        return mInterface
    }

    override fun run(
        vpnService: VpnService,
        builder: VpnService.Builder,
        socksAddr: String,
        dnsGrabAddr: String,
    ) {
        Logger.d(TAG, "run")

        val defaultLocale = Locale.getDefault()
        try {
            Logger.debug(TAG, "Creating VpnBuilder before starting tun2socks")
            val intf: ParcelFileDescriptor? = createBuilder(vpnService, builder)
            Logger.debug(TAG, "Running tun2socks")
            if (intf != null) {
                val tunFd = intf!!.detachFd()
                Internalsdk.tun2Socks(
                    tunFd.toLong(),
                    socksAddr,
                    dnsGrabAddr,
                    VPN_MTU.toLong(),
                    LanternApp.getGoSession(),
                )
            }
        } catch (t: Throwable) {
            Logger.e(TAG, "Exception while handling TUN device", t)
        } finally {
            Locale.setDefault(defaultLocale)
        }
    }

    @Synchronized
    @Throws(Exception::class)
    override fun stop() {
        Logger.d(TAG, "stop")
        Internalsdk.stopTun2Socks()
        mInterface?.let {
            Logger.d(TAG, "closing interface")
            mInterface!!.close()
            mInterface = null
        }
    }
}
