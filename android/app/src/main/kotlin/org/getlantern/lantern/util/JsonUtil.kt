package org.getlantern.lantern.util

import com.google.gson.JsonObject
import com.google.gson.JsonParser
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.getlantern.mobilesdk.Logger

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

    inline fun <reified T> tryParseJson(s: String?): T? {
        return try {
            fromJson(s ?: return null)
        } catch (e: Exception) {
            Logger.error("JsonUtil", "Unable to parse JSON", e)
            null
        }
    }

    fun asJsonObject(responseData: String): JsonObject {
        return JsonParser().parse(responseData).asJsonObject
    }
}
