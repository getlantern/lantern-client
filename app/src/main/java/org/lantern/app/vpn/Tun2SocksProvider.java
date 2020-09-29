package org.lantern.app.vpn;

import android.app.PendingIntent;
import android.content.Intent;
import android.net.VpnService;
import android.os.ParcelFileDescriptor;

import org.lantern.app.activity.LanternFreeActivity;
import org.lantern.app.android.vpn.Tun2Socks;

import org.lantern.mobilesdk.Logger;

import java.util.Locale;

public class Tun2SocksProvider implements Provider {
  private static final String TAG = "Tun2SocksProvider";

  private final static String sessionName = "LanternVpn";

  private final static String netMask = "255.255.255.0";

  private final static String privateAddress = "10.0.0.1";
  private final static String router = "10.0.0.2";
  private final static String dnsGw = "10.0.0.1:8153";

  private final static int VPN_MTU = 1500;

  private ParcelFileDescriptor mInterface;

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
    builder.addRoute("0.0.0.0", 0);
    builder.addDnsServer("8.8.8.8");

    Intent intent = new Intent(vpnService, LanternFreeActivity.class);
    PendingIntent pendingIntent = PendingIntent.getActivity(vpnService, 0, intent, 0);
    builder.setConfigureIntent(pendingIntent);

    builder.setSession(sessionName);

    // Create a new mInterface using the builder and save the parameters.
    mInterface = builder.establish();
    Logger.d(TAG, "New mInterface: " + mInterface);
    return mInterface;
  }

  public void run(final VpnService vpnService, final VpnService.Builder builder, final String socksAddr)
      throws Exception {
    Logger.d(TAG, "Configuring");

    final Locale defaultLocale = Locale.getDefault();
    try {
      ParcelFileDescriptor intf = createBuilder(vpnService, builder);
      Tun2Socks.Start(intf, VPN_MTU, router, netMask, socksAddr, dnsGw);
    } finally {
      Locale.setDefault(defaultLocale);
    }
  }

  public synchronized void stop() throws Exception {
    Logger.d(TAG, "stop");
    Tun2Socks.Stop();
    if (mInterface != null) {
      Logger.d(TAG, "closing interface");
      mInterface.close();
      mInterface = null;
    }
  }
}
