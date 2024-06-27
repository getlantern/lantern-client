package org.getlantern.lantern.util

import com.google.gson.FieldNamingPolicy
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import java.lang.reflect.Type

object JsonUtil {
    val GSON: Gson = GsonBuilder().create()

    fun <T> fromJson(json: String, clazz: Class<T>): T {
        return GSON.fromJson(json, clazz)
    }

    fun <T> fromJson(json: String, typeOfT: Type): T {
        return GSON.fromJson(json, typeOfT)
    }

    inline fun <reified T> fromJson(json: String): T {
        return GSON.fromJson(json, object : TypeToken<T>() {}.type)
    }

    fun toJson(obj: Any): String {
        return GSON.toJson(obj)
    }
}