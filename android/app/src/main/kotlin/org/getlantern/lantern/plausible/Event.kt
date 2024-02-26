package org.getlantern.lantern.plausible

import org.getlantern.lantern.util.Json

internal data class Event(
    val domain: String,
    val name: String,
    val url: String,
    val referrer: String,
    val screenWidth: Int,
    val props: Map<String, String>?
) {
    companion object {
        fun fromJson(json: String): Event? = try {
            Json.gson.fromJson(json, Event::class.java)
        } catch (ignored: Exception) {
            null
        }
    }
}

internal fun Event.toJson(): String = Json.gson.toJson(this)
