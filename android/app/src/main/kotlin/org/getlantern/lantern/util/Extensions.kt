package org.getlantern.lantern.util

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.getlantern.lantern.BuildConfig

inline fun debugOnly(block: () -> Unit) {
    if (BuildConfig.DEBUG) {
        block()
    }
}

//convert a data class to a map
fun <T> T.serializeToMap(): Map<String, Any> {
    return convert()
}

//convert a map to a data class
inline fun <reified T> Map<String, Any>.toDataClass(): T {
    return convert()
}

//convert an object of type I to type O
inline fun <I, reified O> I.convert(): O {
    val gson = Gson()
    val json = gson.toJson(this)
    return gson.fromJson(json, object : TypeToken<O>() {}.type)
}

/**
 * Sometimes, preferences values from old clients that are supposed to be booleans will actually
 * be stored as numeric values or as strings. This normalizes them all to Booleans.
 */
fun castToBoolean(value: Any?, defaultValue: Boolean): Boolean {
    return when (value) {
        is Boolean -> value
        is Number -> value.toInt() == 1
        is String -> value.toBoolean()
        else -> defaultValue
    }
}