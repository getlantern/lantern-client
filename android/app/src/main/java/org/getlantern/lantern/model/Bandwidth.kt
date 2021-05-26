package org.getlantern.lantern.model

import java.text.DateFormat
import java.util.Calendar

class Bandwidth(
    val percent: Long, // [0, 100]
    val remaining: Long, // in MB
    val allowed: Long, // in MB
    val ttlSeconds: Long // number of seconds left before data reset
) {

    val used: Long
        get() = allowed - remaining
    val expiresAtString: String

    init {
        // the ttlSeconds from Go is relative to the system timezone, adjust accordingly for correct
        // display
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.SECOND, ttlSeconds.toInt())
        calendar[Calendar.SECOND] = 0

        val format = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT)
        expiresAtString = format.format(calendar.time)
    }

    override fun toString(): String {
        return String.format(
            "Bandwidth update: %d/%d (%d). TTL: %d (seconds) Expires At: %s",
            remaining, allowed, percent, ttlSeconds, expiresAtString
        )
    }
}
