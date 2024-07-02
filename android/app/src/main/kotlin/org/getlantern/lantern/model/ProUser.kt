package org.getlantern.lantern.model

import org.joda.time.Days
import org.joda.time.LocalDateTime
import org.joda.time.Months

data class ProUser(
    val userId: Long,
    val token: String,
    val referral: String = "",
    val email: String = "",
    val userStatus: String = "",
    val code: String = "",
    val subscription: String = "",
    val expiration: Long = 0,
    val devices: List<Device> = mutableListOf<Device>(),
    val userLevel: String = "",
) {
    private fun isUserStatus(status: String) = userStatus == status

    private fun expirationDate() =
        if (expiration == null) null else LocalDateTime(expiration * 1000)

    fun monthsLeft(): Int {
        val expDate = expirationDate()
        if (expDate == null) return 0
        return Months.monthsBetween(LocalDateTime.now(), expDate).months
    }

    fun daysLeft(): Int {
        val expDate = expirationDate()
        if (expDate == null) return 0
        return Days.daysBetween(LocalDateTime.now(), expDate).days
    }

    fun newUserDetails(): String {
        return "User ID $userId referral $referral"
    }

    val isProUser: Boolean
        get() = (isUserStatus("active") || userLevel == "pro")

    val isActive: Boolean
        get() = isUserStatus("active")

    val isExpired: Boolean
        get() = isUserStatus("expired")
}
