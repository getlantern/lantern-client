package io.lantern.isimud.model

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import io.lantern.observablemodel.ObservableModel
import io.lantern.observablemodel.Subscriber
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

abstract class Model(
        private val name: String,
        flutterEngine: FlutterEngine? = null,
        protected val observableModel: ObservableModel
) : EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    private val activeSubscribers = ConcurrentSkipListSet<Int>()

    init {
        flutterEngine?.let {
            EventChannel(
                flutterEngine.dartExecutor,
                "${name}_event_channel",
                StandardMethodCodec(ProtobufMessageCodec())
            ).setStreamHandler(this)

            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "${name}_method_channel",
                StandardMethodCodec(ProtobufMessageCodec())
            ).setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "get" -> {
                val path = call.arguments<String>()
                result.success(observableModel.get(path))
            }
            "getRange" -> {
                val path = call.argument<String>("path")
                val start = call.argument<Int>("start")!!
                val count = call.argument<Int>("count")!!
                if (path == "/conversationsByRecentActivity") { // TODO: temporary fix due to our current way of saving conversationsByRecentActivity
                    result.success(
                            observableModel.list<List<Any>>(path, 0, 1).map { it.value }[0].subList(start, start + count)
                    )
                } else {
                    result.success(
                            observableModel.list<Any>(path!!, start, count).map { it.value })
                }
            }
            "getRangeDetails" -> {
                val path = call.argument<String>("path")
                val detailsPrefix = call.argument<String>("detailsPrefix")
                val start = call.argument<Int>("start")
                val count = call.argument<Int>("count")
                result.success(
                        observableModel.listDetails<Any>(path!!, start!!, count!!).map { it.value })
            }
            "put" -> {
                val path = call.argument<String>("path")!!
                val value = call.argument<Any>("value")
                observableModel.mutate { tx ->
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
        val args = arguments as Map<String, String>
        val subscriberID = args["subscriberID"] as Int
        val path = args["path"] as String
        val detailsPrefix = args["detailsPrefix"]
        activeSubscribers.add(subscriberID)
        if (detailsPrefix != null) {
            observableModel.subscribeDetails(object :
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
            })
        } else {
            observableModel.subscribe(object : Subscriber<Any>(namespacedSubscriberId(subscriberID), path) {
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
            })
        }
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return;
        }
        val args = arguments as Map<String, String>
        val subscriberID = args["subscriberID"] as Int
        observableModel.unsubscribe(namespacedSubscriberId(subscriberID))
        activeSubscribers.remove(subscriberID)
    }

    fun namespacedSubscriberId(id: Int): String {
        return "${name}_model_${id}"
    }

    fun destroy() {
        activeSubscribers.forEach {
            observableModel.unsubscribe(namespacedSubscriberId(it))
        }
    }
}