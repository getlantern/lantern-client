package io.lantern.isimud.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import io.lantern.observablemodel.ObservableModel
import io.lantern.observablemodel.Subscriber

open class Model(
    flutterEngine: FlutterEngine,

    eventChannelName: String,
    eventChannelCodec: MethodCodec? = StandardMethodCodec(ProtobufMessageCodec()),

    methodChannelName: String,
    methodChannelCodec: MethodCodec? = StandardMethodCodec(ProtobufMessageCodec()),

    val observableModel: ObservableModel

) : EventChannel.StreamHandler, MethodChannel.MethodCallHandler {

    init {
        EventChannel(
            flutterEngine.dartExecutor,
            eventChannelName,
            eventChannelCodec
        ).setStreamHandler(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName,
            methodChannelCodec
        ).setMethodCallHandler(this)
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

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val args = arguments as Map<String, String>
        val subscriberID = args["subscriberID"] as Int
        val path = args["path"] as String
        val detailsPrefix = args["detailsPrefix"]
        if (detailsPrefix != null) {
            observableModel.subscribeDetails(object :
                Subscriber<Any>(subscriberID.toString(), path) {
                override fun onUpdate(path: String, value: Any) {
                    events?.success(mapOf("subscriberID" to subscriberID, "newValue" to value))
                }

                override fun onDelete(path: String) {
                    events?.success(mapOf("subscriberID" to subscriberID, "newValue" to null))
                }
            })
        } else {
            observableModel.subscribe(object : Subscriber<Any>(subscriberID.toString(), path) {
                override fun onUpdate(path: String, value: Any) {
                    events?.success(mapOf("subscriberID" to subscriberID, "newValue" to value))
                }

                override fun onDelete(path: String) {
                    events?.success(mapOf("subscriberID" to subscriberID, "newValue" to null))
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
        val path = args["path"] as String
        observableModel.unsubscribe(subscriberID.toString())
    }
}