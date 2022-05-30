package org.getlantern.lantern.util

import junit.framework.TestCase
import org.getlantern.lantern.util.DateUtil.isAfter
import org.getlantern.lantern.util.DateUtil.isBefore
import org.getlantern.lantern.util.DateUtil.isToday
import org.joda.time.LocalDateTime

class DateUtilTest : TestCase() {
    fun `test date is today`() {
        val date = LocalDateTime()
        assertTrue(date.isToday())
    }

    fun `test date is before`() {
        val date = LocalDateTime(
            2021, 4, 1, 0, 0
        )
        assertTrue(date.isBefore())
        assertFalse(date.isToday())
        assertFalse(date.isAfter())
    }

    fun `test date is after`() {
        val date = LocalDateTime().plusDays(1)
        assertFalse(date.isBefore())
        assertFalse(date.isToday())
        assertTrue(date.isAfter())
    }
}
