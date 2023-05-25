package io.lantern.apps

data class AppData(
    val packageName: String,
    val icon: String,
    val name: String,
    var isExcluded: Boolean
)