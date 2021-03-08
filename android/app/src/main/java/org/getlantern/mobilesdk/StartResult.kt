package org.getlantern.mobilesdk

/**
 * This replaces go.lantern.Lantern.StartResult to avoid introducing a direct dependency to that
 * library.
 */
class StartResult(val httpAddr: String, val socks5Addr: String, val dnsGrabAddr: String)