package org.getlantern.lantern

import org.getlantern.lantern.messaging.Client
import org.getlantern.lantern.messaging.InMemoryServer
import org.whispersystems.libsignal.SignalProtocolAddress
import java.nio.charset.Charset
import java.util.concurrent.ConcurrentHashMap

class EchoSystem {
    private val server = InMemoryServer()
    private val echoBots = ConcurrentHashMap<String, Client>()

    val client = Client(server)

    fun connect(to: String) {
        if (!echoBots.contains(to)) {
            val echoBot = newEchoBot(to)
            echoBots[to] = echoBot
            client.connect(echoBot.addr)
        }
    }

    fun newEchoBot(to: String): Client {
        // For now, this just creates an in-memory echo bot
        val echoBot = Client(server, to)
        echoBot.registerListener({ from: SignalProtocolAddress, plainText: ByteArray ->
            val response = "You said '" + plainText.toString(Charset.defaultCharset()) + "'"
            echoBot.send(from, response.toByteArray(Charset.defaultCharset()))
        })
        return echoBot
    }

    fun send(to: String, message: ByteArray) {
        val addr = SignalProtocolAddress(to, 1)
        client.send(addr, message)
    }
}