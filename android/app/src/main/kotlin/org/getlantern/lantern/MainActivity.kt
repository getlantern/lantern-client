package org.getlantern.lantern

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import io.lantern.isimud.model.Messaging
import io.lantern.isimud.model.Model
import io.lantern.isimud.model.ProtobufMessageCodec
import kotlinx.collections.immutable.persistentListOf


class MainActivity: FlutterActivity(), EventChannel.StreamHandler {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

         // Prepare channels
        EventChannel(getFlutterEngine()?.dartExecutor, updatesChannel, StandardMethodCodec(ProtobufMessageCodec())).setStreamHandler(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannel, StandardMethodCodec(ProtobufMessageCodec())).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            when(call.method) {
                "get" -> {
                    val path = call.arguments<String>()
                    result.success(model.get(path))
                }
                "getRange" -> {
                    val path = call.argument<String>("path")
                    val start = call.argument<Int>("start")
                    val count = call.argument<Int>("count")
                    result.success(model.getRange<Any>(path!!, start!!, count!!))
                }
                "getRangeDetails" -> {
                    val path = call.argument<String>("path")
                    val detailsPrefix = call.argument<String>("detailsPrefix")
                    val start = call.argument<Int>("start")
                    val count = call.argument<Int>("count")
                    result.success(model.getRangeDetails<Any>(path!!, detailsPrefix!!, start!!, count!!))
                }
                "put" -> {
                    val path = call.argument<String>("path")
                    val value = call.argument<Any>("value")
                    model.put(path!!, value!!)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        var args = arguments as Map<String, String>
        val subscriberID = args["subscriberID"] as Int
        val path = args["path"] as String
        val detailsPrefix = args["detailsPrefix"]
        if (detailsPrefix != null) {
            model.subscribeDetails(subscriberID, path, detailsPrefix as String) { path: String, newValue: List<Any?> ->
                events?.success(mapOf("subscriberID" to subscriberID, "newValue" to newValue))
            }
        } else {
            model.subscribe(subscriberID, path) { path: String, newValue: Any? ->
                events?.success(mapOf("subscriberID" to subscriberID, "newValue" to newValue))
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return;
        }
        var args = arguments as Map<String, String>
        val subscriberID = args["subscriberID"] as Int
        val path = args["path"] as String
        model.unsubscribe(subscriberID, path)
    }

    companion object {
        private val model = Model()

        private const val methodChannel = "methodChannel"
        private const val updatesChannel = "updatesChannel"
    }

//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannel).setMethodCallHandler {
//            // Note: this method is invoked on the main thread.
//            call, result ->
//            when(call.method) {
//                "getUserID" -> result.success(echoSystem.client.userID)
//                "connect" -> try {
//                    echoSystem.connect(call.argument<String>("userID") ?: throw RuntimeException("Missing userID"))
//                    result.success(null)
//                } catch (e: Throwable) {
//                    e.printStackTrace()
//                    result.error("exception", e.localizedMessage, null)
//                }
//                "send" -> {
//                    try {
//                        echoSystem.send(call.argument<String>("userID")!!, call.argument<ByteArray>("message")!!)
//                        result.success(null)
//                    } catch (e: Throwable) {
//                        e.printStackTrace()
//                        result.error("exception", e.localizedMessage, null)
//                    }
//                }
//                else -> result.notImplemented()
//            }
//        }
//
//        // Prepare channel
//        EventChannel(getFlutterEngine()?.dartExecutor, eventsChannel).setStreamHandler(this)
//    }
//
//    override fun onListen(arguments: Any?, events: EventSink?) {
//        echoSystem.client.registerListener({ from: SignalProtocolAddress, plainText: ByteArray ->
//            events?.success(hashMapOf(
//                "from" to from.name,
//                "plainText" to plainText
//            ))
//        })
//    }
//
//    override fun onCancel(arguments: Any?) {
////        TODO("Not yet implemented")
//    }
//
//    companion object {
//        private val methodChannel = "methods"
//        private val eventsChannel = "events"
//
//        private val echoSystem = EchoSystem()
//    }

}

