package io.lantern.android.model

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import io.lantern.db.DB
import io.lantern.db.Raw
import io.lantern.db.RawSubscriber
import io.lantern.db.Subscriber
import org.getlantern.mobilesdk.Logger
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

abstract class Model(
        private val name: String,
        flutterEngine: FlutterEngine? = null,
        protected val db: DB,
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
        try {
            val out = doMethodCall(call, { result.notImplemented() })
            when (out) {
                is Unit -> result.success(null)
                else -> result.success(out)
            }
        } catch (t: Throwable) {
            Logger.error(TAG, "Unexpected error calling " + call.method, t)
        }
    }

    open fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "get" -> {
                val path = call.arguments<String>()
                db.get(path)
            }
            "list" -> {
                val path = call.argument<String>("path")
                val start = call.argument<Int?>("start") ?: 0
                val count = call.argument<Int?>("count") ?: Int.MAX_VALUE
                val fullTextSearch = call.argument<String?>("fullTextSearch")
                val reverseSort = call.argument<Boolean?>("reverseSort") ?: false
                db.listRaw<Any>(path!!, start, count, fullTextSearch, reverseSort).map { it.value.valueOrProtoBytes }
            }
            else -> notImplemented()
        }
    }

    private val activeSink = AtomicReference<EventChannel.EventSink?>()

    @Synchronized
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        activeSink.set(events)
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as Int
        val path = args["path"] as String
        val details = args["details"]?.let { it as Boolean } ?: false
        activeSubscribers.add(subscriberID)

        val tail = args["tail"]?.let { it as Boolean } ?: false
        if (tail) {
//            val dump = db.list<Any>("%")
            val count = args["count"]?.let { it as Int } ?: Int.MAX_VALUE
            val subscriber = object : Subscriber<List<Raw<Any>>>(namespacedSubscriberId(subscriberID), path) {
                override fun onUpdate(path: String, value: List<Raw<Any>>) {
                    Handler(Looper.getMainLooper()).post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(mapOf("subscriberID" to subscriberID, "newValue" to value.map { it.valueOrProtoBytes }))
                        }
                    }
                }

                override fun onDelete(path: String) {
                    // ignored
                }
            }
            if (details) {
                db.tailDetails(subscriber, count)
            } else {
                db.tail(subscriber, count)
            }
            return
        }

        val subscriber: RawSubscriber<Any> = object : RawSubscriber<Any>(namespacedSubscriberId(subscriberID), path) {
            override fun onUpdate(path: String, raw: Raw<Any>) {
                Handler(Looper.getMainLooper()).post {
                    synchronized(this@Model) {
                        activeSink.get()?.success(mapOf("subscriberID" to subscriberID, "newValue" to raw.valueOrProtoBytes))
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

    companion object {
        private const val TAG = "Model"
    }
}