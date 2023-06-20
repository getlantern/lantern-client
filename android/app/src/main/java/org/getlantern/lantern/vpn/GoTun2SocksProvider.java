package org.getlantern.lantern.vpn;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.VpnService;
import android.os.ParcelFileDescriptor;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.MainActivity;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.model.SessionManager;

import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import internalsdk.Internalsdk;

public class GoTun2SocksProvider implements Provider {
    private static final String TAG = "GoTun2SocksProvider";

    private final static String sessionName = "LanternVpn";

    private final static String privateAddress = "10.0.0.2";
    private final static int VPN_MTU = 1500;

    private ParcelFileDescriptor mInterface;

    private final PackageManager packageManager;
    private final boolean splitTunnelingEnabled;
    private final Set<String> appsAllowedAccess;

    public GoTun2SocksProvider(
            PackageManager packageManager,
            boolean splitTunnelingEnabled,
            List<String> appsAllowedAccess
    ) {
        this.packageManager = packageManager;
        this.splitTunnelingEnabled = splitTunnelingEnabled;
        this.appsAllowedAccess = new HashSet(appsAllowedAccess);
    }

    private synchronized ParcelFileDescriptor createBuilder(final VpnService vpnService,
                                                            final VpnService.Builder builder) {
        // Set the locale to English
        // since the VpnBuilder encounters
        // issues with non-English numerals
        // See https://code.google.com/p/android/issues/detail?id=61096
        Locale.setDefault(new Locale("en"));

        // Configure a builder while parsing the parameters.
        builder.setMtu(VPN_MTU);
        builder.addAddress(privateAddress, 24);
        // route IPv4 through VPN
        builder.addRoute("0.0.0.0", 0);

        if (splitTunnelingEnabled) {
            // Exclude any app that's not in our split tunneling allowed list
            for (ApplicationInfo installedApp : packageManager.getInstalledApplications(0)) {
                if (!appsAllowedAccess.contains(installedApp.packageName)) {
                    try {
                        Logger.debug(TAG, "Excluding " + installedApp.packageName + " from VPN");
                        builder.addDisallowedApplication(installedApp.packageName);
                    } catch (PackageManager.NameNotFoundException e) {
                        throw new RuntimeException("Unable to exclude " + installedApp.packageName + " from VPN", e);
                    }
                }
            }
        }

        // Never capture traffic originating from Lantern itself in the VPN.
        try {
            String ourPackageName = vpnService.getPackageName();
            builder.addDisallowedApplication(ourPackageName);
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException("Unable to exclude Lantern from VPN", e);
        }

        // don't currently route IPv6 through VPN because our proxies don't currently support IPv6
        // see https://github.com/getlantern/lantern-internal/issues/4961
        // Note - if someone performs a DNS lookup for an IPv6 only host like ipv6.google.com, dnsgrab
        // will return an IPv4 address for that site, causing the traffic to get routed through the VPN.
        // builder.addRoute("0:0:0:0:0:0:0:0", 0);

        // this is a fake DNS server. The precise IP doesn't matter because Lantern will intercept and
        // route all DNS traffic to dnsgrab internally anyway.
        builder.addDnsServer(SessionManager.getFakeDnsIP());

        Intent intent = new Intent(vpnService, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(vpnService, 0, intent, PendingIntent.FLAG_IMMUTABLE);
        builder.setConfigureIntent(pendingIntent);

        builder.setSession(sessionName);

        // Create a new mInterface using the builder and save the parameters.
        mInterface = builder.establish();
        Logger.d(TAG, "New mInterface: " + mInterface);
        return mInterface;
    }

    public void run(final VpnService vpnService, final VpnService.Builder builder, final String socksAddr, final String dnsGrabAddr) {
        Logger.d(TAG, "run");

        final Locale defaultLocale = Locale.getDefault();
        try {
            Logger.debug(TAG, "Creating VpnBuilder before starting tun2socks");
            ParcelFileDescriptor intf = createBuilder(vpnService, builder);
            Logger.debug(TAG, "Running tun2socks");
            Internalsdk.tun2Socks(intf.getFd(), socksAddr, dnsGrabAddr, VPN_MTU, LanternApp.getSession());
        } catch (Throwable t) {
            Logger.e(TAG, "Exception while handling TUN device", t);
        } finally {
            Locale.setDefault(defaultLocale);
        }
    }

    public synchronized void stop() throws Exception {
        Logger.d(TAG, "stop");
        Internalsdk.stopTun2Socks();
        if (mInterface != null) {
            Logger.d(TAG, "closing interface");
            mInterface.close();
            mInterface = null;
        }
    }
}
