package org.getlantern.lantern.messaging

import org.junit.Test
import org.whispersystems.libsignal.SignalProtocolAddress
import java.nio.charset.Charset

class ClientTest {
    @Test
    fun testConnect() {
        val server = InMemoryServer()
        val us = Client(server)
        val them = Client(server)

        us.connect(them.addr)
        them.registerListener({ from: SignalProtocolAddress, plainText: ByteArray -> println(from.name + " said: " + plainText.toString(Charset.defaultCharset()) + " : to " + them.userID)})
        us.send(them.addr, "Hello there".toByteArray(Charset.defaultCharset()))
    }
}