package org.getlantern.lantern

import org.junit.Test
import org.whispersystems.libsignal.SignalProtocolAddress
import java.nio.charset.Charset

class EchoSystemTest {
    @Test
    fun testConnect() {
        val echoSystem = EchoSystem()
        echoSystem.connect("someuser")

        echoSystem.client.registerListener({ from: SignalProtocolAddress, plainText: ByteArray -> println(from.name + " said: " + plainText.toString(Charset.defaultCharset()) + " : to " + echoSystem.client.userID)})
        echoSystem.send("someuser", "Hello there".toByteArray(Charset.defaultCharset()))
    }
}