package org.getlantern.lantern.model

class Bandwidth(
        val percent: Long, // [0, 100]
        val remaining: Long, // in MB
        val allowed: Long, // in MB
        val ttlSeconds: Long // number of seconds left before data reset
) {

    val used: Long
        get() = allowed - remaining

    override fun toString(): String {
        return String.format("Bandwidth update: %d/%d (%d). TTL: %d (seconds)",
                remaining, allowed, percent, ttlSeconds)
    }
}