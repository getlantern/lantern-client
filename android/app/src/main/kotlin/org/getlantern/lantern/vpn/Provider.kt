package org.getlantern.lantern.vpn

import android.net.VpnService

// A provider provides the implementation of VPN internals.
interface Provider {
    @Throws(Exception::class)
    fun run(
        vpnService: VpnService,
        builder: VpnService.Builder,
        socksAddr: String,
        dnsGrabAddr: String
    )

    @Throws(Exception::class)
    fun stop()
}
