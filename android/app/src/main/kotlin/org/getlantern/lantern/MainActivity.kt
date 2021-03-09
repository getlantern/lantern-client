package org.getlantern.lantern

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.isimud.model.Messaging
import io.lantern.isimud.model.MessagingModel
import io.lantern.isimud.model.VpnModel


class MainActivity : FlutterActivity() {

    private lateinit var messagingModel: MessagingModel
    private lateinit var vpnModel: VpnModel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        messagingModel = MessagingModel(flutterEngine)
        vpnModel = VpnModel(flutterEngine)

//        val handler = Handler(Looper.getMainLooper())
//        handler.postDelayed({
//            messagingModel.observableModel.mutate { tx ->
//                tx.put(
//                    "/contact/0",
//                    Messaging.Contact.newBuilder()
//                        .setUserID("0")
//                        .setName("This is a new name")
//                        .build()
//                )
//            }
//        }, 3000)
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

