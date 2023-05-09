package org.getlantern.mobilesdk.util

import android.content.Context
import android.content.Context.CONNECTIVITY_SERVICE
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.net.NetworkRequest
import androidx.annotation.NonNull
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.Event
import org.greenrobot.eventbus.EventBus
import java.net.Inet6Address
import java.net.NetworkInterface
import java.net.SocketException

/**
 * Provides a facility for detecting the current DNS server.
 * <p>
 * Based on work by Madalin Grigore-Enescu on 2/24/18.
 */
class DnsDetector(val context: Context, val fakeDnsIP: String) {
    private var connectivityManager: ConnectivityManager = context.getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
    private var allNetworks = mutableListOf<Network>()

    val dnsServer: String get() = doGetDnsServer() 

    init {
        connectivityManager.registerNetworkCallback(
            NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
                .build(),
            object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(@NonNull network: Network) {
                    Logger.debug(TAG, "Adding available network")
                    allNetworks.add(network)
                    EventBus.getDefault().postSticky(Event.NetworkAvailable)
                }

                override fun onLost(@NonNull network: Network) {
                    Logger.debug(TAG, "Removing lost network")
                    allNetworks.remove(network)
                    publishNetworkAvailability()
                }
            },
        )
    }

    fun doGetDnsServer(): String {
        val network: Network? = findActiveNetwork()
        if (network == null) {
            return DEFAULT_DNS_SERVER
        }

        val linkProperties: LinkProperties? = connectivityManager.getLinkProperties(network)
        val dnsServers = linkProperties?.getDnsServers()
        for (address in dnsServers.orEmpty()) {
            var ip = address.getHostAddress()
            if (fakeDnsIP.equals(ip) || address !is Inet6Address) {
                continue
            }
            try {
                val ipv6Address: Inet6Address = address
                if (ipv6Address.isLinkLocalAddress()) {
                    // For IPv6, the DNS server address can be a link-local address.
                    // For Go to know how to route this, it needs to know the zone
                    // (interface ID). In some cases, that's missing, in other cases it's a
                    // name rather than an interface ID (which our Go code can't handle).
                    // This fixes that.
                    linkProperties?.let {
                        val intf = NetworkInterface.getByInetAddress(
                            linkProperties.getLinkAddresses().get(0).getAddress(),
                        )
                        ip = ip.split("%")[0] + "%" + intf.getIndex()
                    }
                }
                return ip
            } catch (se: SocketException) {
                Logger.debug(TAG, "Unable to get NetworkInterface", se)
            }
        }

        return DEFAULT_DNS_SERVER
    }

    fun publishNetworkAvailability() {
        if (findActiveNetwork() == null) {
            Logger.debug(TAG, "No network available")
            EventBus.getDefault().postSticky(Event.NoNetworkAvailable)
        }
    }

    private fun findActiveNetwork(): Network? {
        val networkInfos = mutableListOf<NetworkInfo?>()
        for (network in allNetworks) {
            networkInfos.add(connectivityManager.getNetworkInfo(network))
        }

        // search order goes ETHERNET -> WIFI -> MOBILE
        for (type in NETWORK_PRIORITY) {
            val activeNetwork: Network? = availableNetworkOfType(
                networkInfos,
                type,
            )
            if (activeNetwork != null) {
                return activeNetwork
            }
        }

        return null
    }

    private fun availableNetworkOfType(networkInfos: MutableList<NetworkInfo?>, type: Int): Network? {
        networkInfos.forEachIndexed { index, info ->
            if (info != null && info.isAvailable() && info.getType() == type) {
                return allNetworks[index]
            }
        }
        return null
    }

    companion object {
        private val TAG = DnsDetector::class.java.simpleName
        private const val DEFAULT_DNS_SERVER = "8.8.8.8"
        private val NETWORK_PRIORITY = intArrayOf(
            ConnectivityManager.TYPE_ETHERNET,
            ConnectivityManager.TYPE_WIFI,
            ConnectivityManager.TYPE_MOBILE,
        )
    }
}
