package org.getlantern.lantern.plausible

import org.getlantern.lantern.util.JsonUtil

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
            JsonUtil.fromJson<Event>(json)
        } catch (ignored: Exception) {
            null
        }
    }
}

internal fun Event.toJson(): String = JsonUtil.toJson(this)
