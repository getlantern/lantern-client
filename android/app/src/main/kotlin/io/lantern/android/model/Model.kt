package io.lantern.android.model

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import io.lantern.db.DB
import io.lantern.db.Raw
import io.lantern.db.RawSubscriber
import io.lantern.db.Subscriber
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

abstract class Model(
        private val name: String,
        flutterEngine: FlutterEngine? = null,
        protected val db: DB
) : EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    private val activeSubscribers = ConcurrentSkipListSet<Int>()

    init {
        flutterEngine?.let {
            EventChannel(
                flutterEngine.dartExecutor,
                "${name}_event_channel"
            ).setStreamHandler(this)

            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "${name}_method_channel"
            ).setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "get" -> {
                val path = call.arguments<String>()
                result.success(db.get(path))
            }
            "getRange" -> {
                val path = call.argument<String>("path")
                val start = call.argument<Int>("start")!!
                val count = call.argument<Int>("count")!!
                if (path == "/conversationsByRecentActivity") { // TODO: temporary fix due to our current way of saving conversationsByRecentActivity
                    result.success(
                            db.list<List<Any>>(path, 0, 1).map { it.value }[0].subList(start, start + count)
                    )
                } else {
                    result.success(
                            db.list<Any>(path!!, start, count).map { it.value })
                }
            }
            "getRangeDetails" -> {
                val path = call.argument<String>("path")
                val start = call.argument<Int>("start")
                val count = call.argument<Int>("count")
                result.success(
                        db.listDetails<Any>(path!!, start!!, count!!).map { it.value })
            }
            "put" -> {
                val path = call.argument<String>("path")!!
                val value = call.argument<Any>("value")
                db.mutate { tx ->
                    tx.put(path, value)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private val activeSink = AtomicReference<EventChannel.EventSink?>()

    @Synchronized
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        activeSink.set(events)
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as Int
        val path = args["path"] as String
        val details = args["details"]?.let { it as Boolean} ?: false
        val raw = args["raw"]?.let { it as Boolean } ?: false
        activeSubscribers.add(subscriberID)
        val subscriber: RawSubscriber<Any> = if (raw) {
            object :
                    RawSubscriber<Any>(namespacedSubscriberId(subscriberID), path) {
                override fun onUpdate(path: String, raw: Raw<Any>) {
                    Handler(Looper.getMainLooper()).post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(mapOf("subscriberID" to subscriberID, "newValue" to raw.bytes))
                        }
                    }
                }

                override fun onDelete(path: String) {
                    Handler(Looper.getMainLooper()).post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(mapOf("subscriberID" to subscriberID, "newValue" to null))
                        }
                    }
                }
            }
        } else {
            object :
                    Subscriber<Any>(namespacedSubscriberId(subscriberID), path) {
                override fun onUpdate(path: String, value: Any) {
                    Handler(Looper.getMainLooper()).post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(mapOf("subscriberID" to subscriberID, "newValue" to value))
                        }
                    }
                }

                override fun onDelete(path: String) {
                    Handler(Looper.getMainLooper()).post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(mapOf("subscriberID" to subscriberID, "newValue" to null))
                        }
                    }
                }
            }
        }
        if (details) {
            db.subscribeDetails(subscriber)
        } else {
            db.subscribe(subscriber)
        }
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return;
        }
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as Int
        db.unsubscribe(namespacedSubscriberId(subscriberID))
        activeSubscribers.remove(subscriberID)
    }

    fun namespacedSubscriberId(id: Int): String {
        return "${name}_model_${id}"
    }

    fun destroy() {
        activeSubscribers.forEach {
            db.unsubscribe(namespacedSubscriberId(it))
        }
    }
}