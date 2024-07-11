package org.getlantern.lantern.util

import io.lantern.model.SessionModel
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.ProxySelector
import java.net.SocketAddress
import java.net.URI

class LanternProxySelector(private val session: SessionModel) : ProxySelector() {

    init {
        setDefault(this)
    }

    override fun select(uri: URI): MutableList<Proxy> {
        val proxyAddress: SocketAddress = addrFromString(
            session.settings.httpProxyHost + ":" +
                    session.settings.httpProxyPort,
        )
        val proxiesList: MutableList<Proxy> = mutableListOf()
        proxiesList.add(Proxy(Proxy.Type.HTTP, proxyAddress))
        return proxiesList
    }

    override fun connectFailed(uri: URI?, sa: SocketAddress?, ioe: IOException?) {
    }

    private fun addrFromString(addr: String): InetSocketAddress {
        try {
            val uri: URI = URI("my://$addr")
            return InetSocketAddress(uri.host, uri.port)
        } catch (e: Exception) {
            throw RuntimeException(e)
        }
    }
}
