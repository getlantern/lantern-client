package org.getlantern.mobilesdk.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.LinkProperties;
import android.net.Network;
import android.net.NetworkInfo;
import android.net.NetworkRequest;
import android.net.RouteInfo;

import androidx.annotation.NonNull;

import org.getlantern.mobilesdk.Logger;

import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.concurrent.atomic.AtomicReference;

import static android.content.Context.CONNECTIVITY_SERVICE;

/**
 * Provides a facility for detecting the current DNS server.
 * <p>
 * Based on work by Madalin Grigore-Enescu on 2/24/18.
 */

public class DnsDetector {

    private static final String TAG = "DnsServersDetector";
    private final String fakeDnsIP;
    private final AtomicReference<String> dnsServer = new AtomicReference<>("8.8.8.8");
    private final ConnectivityManager connectivityManager;

    /**
     * Constructor
     */
    public DnsDetector(Context context, String fakeDnsIP) {
        this.fakeDnsIP = fakeDnsIP;
        connectivityManager = (ConnectivityManager) context.getSystemService(CONNECTIVITY_SERVICE);
        update();
        connectivityManager.registerNetworkCallback(
                new NetworkRequest.Builder().build(),
                new ConnectivityManager.NetworkCallback() {
                    @Override
                    public void onAvailable(@NonNull Network network) {
                        super.onAvailable(network);
                        update();
                    }

                    @Override
                    public void onLinkPropertiesChanged(@NonNull Network network, @NonNull LinkProperties linkProperties) {
                        super.onLinkPropertiesChanged(network, linkProperties);
                        update();
                    }
                }
        );
    }

    public String getDnsServer() {
        return dnsServer.get();
    }

    private void update() {
        // This code only works on LOLLIPOP and higher
        try {
            // First pass looks for default route
            if (!doUpdate(true)) {
                doUpdate(false);
            }
        } catch (Exception ex) {
            Logger.debug(TAG, "Exception detecting DNS servers using ConnectivityManager method", ex);
        }
    }

    private boolean doUpdate(boolean lookForDefault) {
        for (Network network : connectivityManager.getAllNetworks()) {
            NetworkInfo networkInfo = connectivityManager.getNetworkInfo(network);
            if (networkInfo.isConnected()) {
                LinkProperties linkProperties = connectivityManager.getLinkProperties(network);
                if (lookForDefault && !linkPropertiesHasDefaultRoute(linkProperties)) {
                    continue;
                }

                for (InetAddress element : linkProperties.getDnsServers()) {
                    String dnsHost = element.getHostAddress();
                    if (!fakeDnsIP.equals(dnsHost)) {
                        try {
                            InetAddress address = network.getByName(dnsHost);
                            String ip = address.getHostAddress();
                            if (address instanceof Inet6Address) {
                                Inet6Address ipv6Address = (Inet6Address) address;
                                if (ipv6Address.isLinkLocalAddress() && !ip.contains("%")) {
                                    // For IPv6, the DNS server address can be a link-local address.
                                    // For Go to know how to route this, it needs to know the zone
                                    // (interface ID). In some cases, that seems to be missing from
                                    // the ip, so we add it manually here.
                                    NetworkInterface intf = NetworkInterface.getByInetAddress(
                                            linkProperties.getLinkAddresses().get(0).getAddress());
                                    ip = ip + "%" + intf.getIndex();
                                }
                            }
                            Logger.debug(TAG, "Setting DNS server to " + ip);
                            dnsServer.set(ip);
                            return true;
                        } catch (UnknownHostException uhe) {
                            Logger.debug(TAG, "Unable to resolve hostname", uhe);
                        } catch (SocketException se) {
                            Logger.debug(TAG, "Unable to get NetworkInterface", se);
                        }
                    }
                }
            }
        }

        return false;
    }

    /**
     * Returns true if the specified link properties have any default route
     *
     * @param linkProperties
     * @return true if the specified link properties have default route or false otherwise
     */
    private boolean linkPropertiesHasDefaultRoute(LinkProperties linkProperties) {
        for (RouteInfo route : linkProperties.getRoutes()) {
            if (route.isDefaultRoute()) {
                return true;
            }
        }
        return false;
    }
}