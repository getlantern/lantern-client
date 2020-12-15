package org.getlantern.lantern.model

class Bandwidth(
        val percent: Long, // [0, 100]
        val remaining: Long, // in MB
        val allowed: Long // in MB
) {

    val used: Long
        get() = allowed - remaining

    override fun toString(): String {
        return String.format("Bandwidth update: %d/%d (%d)",
                remaining, allowed, percent)
    }
}