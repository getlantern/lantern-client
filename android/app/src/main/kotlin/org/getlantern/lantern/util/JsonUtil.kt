package org.getlantern.lantern.util

import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

object JsonUtil {

    val json = Json {
        encodeDefaults = true
        ignoreUnknownKeys = true
        explicitNulls = false
        prettyPrint = true
    }

    inline fun <reified T : Any> fromJson(s: String): T {
        return json.decodeFromString<T>(s)
    }

    inline fun <reified T> toJson(obj: T): String {
        return json.encodeToString(obj)
    }
}