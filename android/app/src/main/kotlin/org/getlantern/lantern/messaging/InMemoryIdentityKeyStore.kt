package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.IdentityKey
import org.whispersystems.libsignal.IdentityKeyPair
import org.whispersystems.libsignal.SignalProtocolAddress
import org.whispersystems.libsignal.state.IdentityKeyStore
import org.whispersystems.libsignal.util.KeyHelper
import java.util.concurrent.ConcurrentHashMap

class InMemoryIdentityKeyStore: IdentityKeyStore {
    private val identities = ConcurrentHashMap<SignalProtocolAddress?, IdentityKey?>()

    override fun getIdentity(address: SignalProtocolAddress?): IdentityKey? {
        return identities[address];
    }

    override fun getIdentityKeyPair(): IdentityKeyPair {
        return staticIdentityKeyPair
    }

    override fun getLocalRegistrationId(): Int {
        return registrationId
    }

    override fun saveIdentity(address: SignalProtocolAddress?, identityKey: IdentityKey?): Boolean {
        val existed = identities.contains(address);
        identities[address] = identityKey
        return existed;
    }

    override fun isTrustedIdentity(address: SignalProtocolAddress?, identityKey: IdentityKey?, direction: IdentityKeyStore.Direction?): Boolean {
        return identities.containsKey(address)
    }

    companion object {
        private val staticIdentityKeyPair = KeyHelper.generateIdentityKeyPair()
        private val registrationId = KeyHelper.generateRegistrationId(true) // TODO: persist this
    }
}