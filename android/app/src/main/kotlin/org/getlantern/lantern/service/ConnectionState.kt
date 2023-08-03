package org.getlantern.lantern.service

enum class ConnectionState(
    val started: Boolean = false,
    val connected: Boolean = false,
) {
    Connecting(true, false),
    Connected(true, true),
    Disconnecting,
    Disconnected,
}
