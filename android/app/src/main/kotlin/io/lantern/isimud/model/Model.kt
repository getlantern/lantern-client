package io.lantern.isimud.model

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import io.lantern.observablemodel.ObservableModel
import io.lantern.observablemodel.Subscriber
import io.lantern.secrets.Secrets
import org.getlantern.lantern.LanternApp
import java.io.File
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

abstract class Model(
    private val name: String,
    flutterEngine: FlutterEngine? = null,
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

    companion object {

        val observableModel: ObservableModel

        init {
            val context = LanternApp.getAppContext()
            val secretsPreferences = context.getSharedPreferences("secrets", Context.MODE_PRIVATE)
            val secrets = Secrets("lanternMasterKey", secretsPreferences)
            val dbLocation = File(File(context.filesDir, ".lantern"), "db").absolutePath
            val dbPassword = secrets.get("dbPassword", 16)
            observableModel = ObservableModel.build(context, dbLocation, dbPassword)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "get" -> {
                val path = call.arguments<String>()
                result.success(observableModel.get(namespacedPath(path)))
            }
            "getRange" -> {
                val path = call.argument<String>("path")
                val start = call.argument<Int>("start")!!
                val count = call.argument<Int>("count")!!
                if (path == "/conversationsByRecentActivity") { // TODO: temporary fix due to our current way of saving conversationsByRecentActivity
                    result.success(
                        observableModel.list<List<Any>>(namespacedPath(path), 0, 1)
                            .map { it.value }[0].subList(start, start + count)
                    )
                } else {
                    result.success(
                        observableModel.list<Any>(namespacedPath(path!!), start, count)
                            .map { it.value })
                }
            }
            "getRangeDetails" -> {
                val path = call.argument<String>("path")
                val detailsPrefix = call.argument<String>("detailsPrefix")
                val start = call.argument<Int>("start")
                val count = call.argument<Int>("count")
                result.success(
                    observableModel.listDetails<Any>(namespacedPath(path!!), start!!, count!!)
                        .map { it.value })
            }
            "put" -> {
                val path = call.argument<String>("path")!!
                val value = call.argument<Any>("value")
                observableModel.mutate { tx ->
                    tx.put(namespacedPath(path), value)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private val activeSink = AtomicReference<EventChannel.EventSink?>()

    private val handler = Handler(Looper.getMainLooper()) // a handler for the main thread

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
                Subscriber<Any>(namespacedSubscriberId(subscriberID), namespacedPath(path)) {
                override fun onUpdate(path: String, value: Any) {
                    handler.post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(
                                mapOf(
                                    "subscriberID" to subscriberID,
                                    "newValue" to value
                                )
                            )
                        }
                    }
                }

                override fun onDelete(path: String) {
                    handler.post {
                        synchronized(this@Model) {
                            activeSink.get()
                                ?.success(mapOf("subscriberID" to subscriberID, "newValue" to null))
                        }
                    }
                }
            })
        } else {
            observableModel.subscribe(object :
                Subscriber<Any>(namespacedSubscriberId(subscriberID), namespacedPath(path)) {
                override fun onUpdate(path: String, value: Any) {
                    handler.post {
                        synchronized(this@Model) {
                            activeSink.get()?.success(
                                mapOf(
                                    "subscriberID" to subscriberID,
                                    "newValue" to value
                                )
                            )
                        }
                    }
                }

                override fun onDelete(path: String) {
                    handler.post {
                        synchronized(this@Model) {
                            activeSink.get()
                                ?.success(mapOf("subscriberID" to subscriberID, "newValue" to null))
                        }
                    }
                }
            })
        }
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return
        }
        val args = arguments as Map<String, String>
        val subscriberID = args["subscriberID"] as Int
        observableModel.unsubscribe(namespacedSubscriberId(subscriberID))
        activeSubscribers.remove(subscriberID)
    }

    fun namespacedSubscriberId(id: Int): String {
        return "${name}_model_${id}"
    }

    fun namespacedPath(path: String): String {
        return "${name}${path}"
    }

    fun destroy() {
        activeSubscribers.forEach {
            observableModel.unsubscribe(namespacedSubscriberId(it))
        }
    }
}