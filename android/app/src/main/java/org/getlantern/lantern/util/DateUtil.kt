package org.getlantern.lantern.util

import org.joda.time.LocalDate
import org.joda.time.LocalDateTime

object DateUtil {
    fun LocalDateTime?.isToday(): Boolean {
        return this?.toLocalDate() == LocalDate.now()
    }

    fun LocalDateTime?.isBefore(): Boolean {
        return this?.toLocalDate() == LocalDate.now()
    }

    fun LocalDateTime?.isAfter(): Boolean {
        return this?.toLocalDate() == LocalDate.now()
    }
}
