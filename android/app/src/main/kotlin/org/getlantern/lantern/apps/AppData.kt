package org.getlantern.lantern.apps

data class AppData(
    val packageName: String,
    val iconRes: Int,
    val name: String,
    val isSystemApp: Boolean = false
)