package org.getlantern.lantern.messaging

import org.whispersystems.libsignal.SignalProtocolAddress
import org.whispersystems.libsignal.state.SessionRecord
import org.whispersystems.libsignal.state.SessionStore
import java.util.concurrent.ConcurrentHashMap

class InMemorySessionStore: SessionStore {
    private val sessions = ConcurrentHashMap<SignalProtocolAddress?, SessionRecord?>()
    private val addressesByName = ConcurrentHashMap<String?, ArrayList<SignalProtocolAddress?>>()

    /**
     * Returns a copy of the [SessionRecord] corresponding to the recipientId + deviceId tuple,
     * or a new SessionRecord if one does not currently exist.
     *
     *
     * It is important that implementations return a copy of the current durable information.  The
     * returned SessionRecord may be modified, but those changes should not have an effect on the
     * durable session state (what is returned by subsequent calls to this method) without the
     * store method being called here first.
     *
     * @param address The name and device ID of the remote client.
     * @return a copy of the SessionRecord corresponding to the recipientId + deviceId tuple, or
     * a new SessionRecord if one does not currently exist.
     */
    @Synchronized override fun loadSession(address: SignalProtocolAddress?): SessionRecord? {
        var session = sessions[address]
        if (session == null) {
            session = SessionRecord()
            storeSession(address, session)
        }
        return session
    }

    /**
     * Returns all known devices with active sessions for a recipient
     *
     * @param name the name of the client.
     * @return all known sub-devices with active sessions.
     */
    override fun getSubDeviceSessions(name: String?): List<Int?>? {
        return addressesByName[name]?.map { it?.deviceId }
    }

    /**
     * Commit to storage the [SessionRecord] for a given recipientId + deviceId tuple.
     * @param address the address of the remote client.
     * @param record the current SessionRecord for the remote client.
     */
    @Synchronized override fun storeSession(address: SignalProtocolAddress?, record: SessionRecord?) {
        sessions[address] = record
        val addresses = addressesByName[address!!.name] ?: ArrayList<SignalProtocolAddress?>()
        addresses.add(address)
        addressesByName[address!!.name] = addresses
    }

    /**
     * Determine whether there is a committed [SessionRecord] for a recipientId + deviceId tuple.
     * @param address the address of the remote client.
     * @return true if a [SessionRecord] exists, false otherwise.
     */
    override fun containsSession(address: SignalProtocolAddress?): Boolean {
        return sessions.containsKey(address)
    }

    /**
     * Remove a [SessionRecord] for a recipientId + deviceId tuple.
     *
     * @param address the address of the remote client.
     */
    @Synchronized override fun deleteSession(address: SignalProtocolAddress?) {
        sessions.remove(address)
        addressesByName[address!!.name]?.remove(address)
    }

    /**
     * Remove the [SessionRecord]s corresponding to all devices of a recipientId.
     *
     * @param name the name of the remote client.
     */
    @Synchronized override fun deleteAllSessions(name: String?) {
        addressesByName[name]?.forEach { sessions.remove(it) }
        addressesByName.remove(name)
    }
}