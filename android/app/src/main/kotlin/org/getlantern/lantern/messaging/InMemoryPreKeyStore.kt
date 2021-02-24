package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.InvalidKeyIdException
import org.whispersystems.libsignal.state.PreKeyRecord
import org.whispersystems.libsignal.state.PreKeyStore
import java.util.concurrent.ConcurrentHashMap

class InMemoryPreKeyStore: PreKeyStore {
    private val preKeys = ConcurrentHashMap<Int, PreKeyRecord?>()

    @Throws(InvalidKeyIdException::class)
    override fun loadPreKey(preKeyId: Int): PreKeyRecord? {
        val result = preKeys[preKeyId]
        if (result == null) {
            throw InvalidKeyIdException("key " + preKeyId + " not found")
        }
        return result
    }

    override fun storePreKey(preKeyId: Int, record: PreKeyRecord?) {
        preKeys[preKeyId] = record
    }

    override fun containsPreKey(preKeyId: Int): Boolean {
        return preKeys.containsKey(preKeyId)
    }

    override fun removePreKey(preKeyId: Int) {
        preKeys.remove(preKeyId)
    }
}