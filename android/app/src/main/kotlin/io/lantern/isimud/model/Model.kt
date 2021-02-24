package io.lantern.isimud.model

import kotlinx.collections.immutable.PersistentMap
import kotlinx.collections.immutable.persistentHashMapOf
import kotlinx.collections.immutable.persistentListOf
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentNavigableMap
import java.util.concurrent.ConcurrentSkipListMap
import kotlin.math.min

class Model {
    val data = ConcurrentHashMap<String, Any>()
    val keyPathSubscribers = ConcurrentHashMap<String, PersistentMap<Int, (String, Any) -> Unit>?>()

    inline fun <reified T> subscribe(subscriberID: Int, path: String, noinline onUpdate: (String, T?) -> Unit) {
        val actualOnUpdate = { key: String, value: Any ->
            onUpdate(key, value?.let { it as T } ?: null)
        }

        synchronized(this) {
            keyPathSubscribers[path] = keyPathSubscribers[path]?.let { it.put(subscriberID, actualOnUpdate) } ?: persistentHashMapOf(subscriberID to actualOnUpdate)
        }

        get<T>(path)?.let {
            onUpdate(path, it)
        }
    }

    inline fun <reified T> subscribeDetails(subscriberID: Int, path: String, detailsPrefix: String, noinline onUpdate: (String, List<T?>) -> Unit) {
        subscribe<List<Any>>(subscriberID, path) { path: String, ids: List<Any>? ->
            onUpdate(path, ids?.let { it.map { get<T>("$detailsPrefix/$it") } } ?: emptyList())
        }
    }

    fun unsubscribe(subscriberID: Int, path: String) {
        synchronized(this) {
            keyPathSubscribers[path] = keyPathSubscribers[path]?.remove(subscriberID)
        }
    }

    inline fun <reified T> get(path: String): T? {
        return data[path]?.let { it as T } ?: null
    }

    inline fun <reified T> getRange(path: String, start: Int, count: Int): List<T> {
        return get<List<T>>(path)?.let { it.subList(start, min(start + count, it.size)) } ?: emptyList()
    }

    inline fun <reified T> getRangeDetails(path: String, detailsPrefix: String, start: Int, count: Int): List<T?> {
        val ids = getRange<Any>(path, start, count)
        return ids.map { get<T>("$detailsPrefix/$it") }
    }

    fun put(path: String, value: Any) {
        data[path] = value
        keyPathSubscribers[path]?.forEach { it.value(path, value) }
    }
}