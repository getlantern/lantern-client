package org.getlantern.lantern.vpn;

import android.net.VpnService;

// A provider provides the implementation of VPN internals.
interface Provider {
  void run(final VpnService vpnService, final VpnService.Builder builder, final String socksAddr) throws Exception;

  void stop() throws Exception;
}
