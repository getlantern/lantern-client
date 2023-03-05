package org.getlantern.lantern.apps

data class AppData(
    val packageName: String,
    val iconRes: Long,
    val name: String,
    val isSystemApp: Boolean = false
)