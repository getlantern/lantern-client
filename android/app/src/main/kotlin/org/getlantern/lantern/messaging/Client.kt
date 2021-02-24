package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.IdentityKey
import org.whispersystems.libsignal.SessionBuilder
import org.whispersystems.libsignal.SessionCipher
import org.whispersystems.libsignal.SignalProtocolAddress
import org.whispersystems.libsignal.protocol.CiphertextMessage
import org.whispersystems.libsignal.protocol.PreKeySignalMessage
import org.whispersystems.libsignal.protocol.SignalMessage
import org.whispersystems.libsignal.state.PreKeyBundle
import org.whispersystems.libsignal.state.PreKeyRecord
import org.whispersystems.libsignal.util.KeyHelper
import java.nio.charset.Charset
import java.util.*

class Client(val server: Server, val userID: String = "12345678901234567890123"){
    private val sessionStore = InMemorySessionStore()
    private val preKeyStore = InMemoryPreKeyStore()
    private val signedPreKeyStore = InMemorySignedPreKeyStore()
    private val identityKeyStore = InMemoryIdentityKeyStore()
    private var currentPreKeyIndex = 1

    private val messageListeners = ArrayList<(SignalProtocolAddress, ByteArray) -> Unit>()

    val deviceID = 1 // TODO: this should really be unique like Random().nextInt(20000). This can't be more than the max uint32
    val addr = SignalProtocolAddress(userID, deviceID)
    val signedPreKey = KeyHelper.generateSignedPreKey(identityKeyStore.identityKeyPair, 1) // TODO: figure out if/why/when we should rotate this and how that affects keys registered on the server

    val registrationId: Int
        get() = identityKeyStore.localRegistrationId

    val publicKey: IdentityKey
        get() = identityKeyStore.identityKeyPair.publicKey

    init {
        signedPreKeyStore.storeSignedPreKey(signedPreKey.id, signedPreKey)
        server.register(this)
    }

    @Synchronized fun generatePreKeys(count: Int): List<PreKeyRecord> {
        val preKeys = KeyHelper.generatePreKeys(currentPreKeyIndex, count)
        preKeys.forEach { preKeyStore.storePreKey(it.id, it) }
        currentPreKeyIndex += count
        return preKeys
    }

    /**
     * Connect connects to the given to address.
     * Currently, it assumes that this user is represented by the "other" Signal property
     */
    fun connect(to: SignalProtocolAddress) {
        val preKeyBundle = server.getPreKey(to)
        identityKeyStore.saveIdentity(to, preKeyBundle.identityKey)

        val sessionBuilder = SessionBuilder(
                sessionStore,
                preKeyStore,
                signedPreKeyStore,
                identityKeyStore,
                to)

        sessionBuilder.process(preKeyBundle)
    }

    fun buildSessionCipher(remote: SignalProtocolAddress): SessionCipher {
        return SessionCipher(sessionStore, preKeyStore, signedPreKeyStore, identityKeyStore, remote)
    }

    /**
     * Sends the given plainText to the given to address.
     */
    fun send(to: SignalProtocolAddress, plainText: ByteArray) {
        val cipher = buildSessionCipher(to)
        val cipherText = cipher.encrypt(plainText)
        server.send(addr, to, cipherText)
    }

    /**
     * Receives a message.
     */
    fun receive(from: SignalProtocolAddress, message: CiphertextMessage) {
        val cipher = buildSessionCipher(from)
        val roundTrippedPlainText = when(message) {
            is SignalMessage -> cipher.decrypt(message)
            is PreKeySignalMessage -> {
                identityKeyStore.saveIdentity(from, message.identityKey) // TODO: prompt the user to confirm this, or mark the session as untrusted or something
                cipher.decrypt(message)
            }
            else -> throw RuntimeException("Unexpected message type: " + message.javaClass.name)
        }
        notifyListeners(from, roundTrippedPlainText)
    }

    @Synchronized fun registerListener(listener: (SignalProtocolAddress, ByteArray) -> Unit) {
        messageListeners.add(listener)
    }

    @Synchronized fun notifyListeners(from: SignalProtocolAddress, plainText: ByteArray) {
        messageListeners.forEach { it(from, plainText )}
    }
}