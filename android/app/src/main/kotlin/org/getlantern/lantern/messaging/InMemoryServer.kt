package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.SignalProtocolAddress
import org.whispersystems.libsignal.protocol.CiphertextMessage
import org.whispersystems.libsignal.state.PreKeyBundle
import org.whispersystems.libsignal.state.PreKeyRecord
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentLinkedQueue

class InMemoryServer: Server {
    private val clients = ConcurrentHashMap<SignalProtocolAddress, Client>()
    private val preKeysByClient = ConcurrentHashMap<SignalProtocolAddress, ConcurrentLinkedQueue<PreKeyRecord>>()

    @Synchronized override fun register(client: Client) {
        clients[client.addr] = client
        var preKeys = preKeysByClient[client.addr] ?: ConcurrentLinkedQueue()
        preKeys.addAll(client.generatePreKeys(100))
        preKeysByClient[client.addr] = preKeys
    }

    @Synchronized override fun getPreKey(addr: SignalProtocolAddress): PreKeyBundle {
        val them = clients[addr] ?: throw RuntimeException("Unknown addr " + addr)
        val preKeys = preKeysByClient[addr] ?: throw RuntimeException("No pre-keys available for " + addr)
        val preKey = preKeys.poll() ?: throw RuntimeException("No pre-key available for " + addr)
        return PreKeyBundle(
                        them.registrationId, them.deviceID,
                        preKey.id, preKey.keyPair.publicKey,
                        them.signedPreKey.id, them.signedPreKey.keyPair.publicKey, them.signedPreKey.signature,
                        them.publicKey)
    }

    @Synchronized override fun send(from: SignalProtocolAddress, to: SignalProtocolAddress, cipherText: CiphertextMessage) {
        val client = clients[to] ?: throw RuntimeException("Unknown addr " + to)
        client.receive(from, cipherText)
    }
}