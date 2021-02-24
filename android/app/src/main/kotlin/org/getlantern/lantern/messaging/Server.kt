package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.SignalProtocolAddress
import org.whispersystems.libsignal.protocol.CiphertextMessage
import org.whispersystems.libsignal.state.PreKeyBundle

/**
 * Server is the interface for servers that support discovery of Signal-style clients and exchange
 * of encrypted messages between those clients.
 */
interface Server {
    /**
     * Registers the given messaging client
     */
    fun register(client: Client)

    /**
     * Gets a pre-key bundle for the client at the given address. This uses up one of the registered
     * pre keys for that client, so it is NOT idempotent.
     */
    fun getPreKey(addr: SignalProtocolAddress): PreKeyBundle

    /**
     * Send the given cipherText to the given to address from the given from address
     */
    fun send(from: SignalProtocolAddress, to: SignalProtocolAddress, cipherText: CiphertextMessage)
}