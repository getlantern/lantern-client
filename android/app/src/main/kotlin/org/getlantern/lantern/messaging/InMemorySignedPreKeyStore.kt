package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.InvalidKeyIdException
import org.whispersystems.libsignal.state.PreKeyRecord
import org.whispersystems.libsignal.state.SignedPreKeyRecord
import org.whispersystems.libsignal.state.SignedPreKeyStore
import java.util.concurrent.ConcurrentHashMap

class InMemorySignedPreKeyStore: SignedPreKeyStore {
    private val preKeys = ConcurrentHashMap<Int, SignedPreKeyRecord?>()

    @Throws(InvalidKeyIdException::class)
    override fun loadSignedPreKey(signedPreKeyId: Int): SignedPreKeyRecord? {
        val result = preKeys[signedPreKeyId]
        if (result == null) {
            throw InvalidKeyIdException("key " + signedPreKeyId + " not found")
        }
        return result
    }

    override fun loadSignedPreKeys(): List<SignedPreKeyRecord?>? {
        return ArrayList(preKeys.values)
    }

    override fun storeSignedPreKey(signedPreKeyId: Int, record: SignedPreKeyRecord?) {
        preKeys[signedPreKeyId] = record
    }

    override fun containsSignedPreKey(signedPreKeyId: Int): Boolean {
        return preKeys.containsKey(signedPreKeyId)
    }

    override fun removeSignedPreKey(signedPreKeyId: Int) {
        preKeys.remove(signedPreKeyId)
    }
}
