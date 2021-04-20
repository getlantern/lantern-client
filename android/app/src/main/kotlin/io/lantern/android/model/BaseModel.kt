package io.lantern.android.model

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.protobuf.GeneratedMessageLite
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import io.lantern.db.*
import io.lantern.messaging.AttachmentTooBigException
import io.lantern.secrets.Secrets
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import java.io.File
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

abstract class BaseModel(
        private val name: String,
        flutterEngine: FlutterEngine? = null,
        val db: DB,
) : EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    private val activeSubscribers = ConcurrentSkipListSet<String>()
    private val handler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "Model"

        internal val masterDB: DB

        init {
            val context = LanternApp.getAppContext()
            val secretsPreferences = context.getSharedPreferences("secrets", Context.MODE_PRIVATE)
            val secrets = Secrets("lanternMasterKey", secretsPreferences)
            val dbLocation = File(File(context.filesDir, ".lantern"), "db").absolutePath
            val dbPassword = secrets.get("dbPassword", 32)
            masterDB = DB.createOrOpen(context, dbLocation, dbPassword)
        }
    }

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
            when (val out = doMethodCall(call, { result.notImplemented() })) {
                is Unit -> result.success(null)
                is GeneratedMessageLite<*, *> -> result.success(out.toByteArray())
                else -> result.success(out)
            }
        } catch (e: AttachmentTooBigException) {
            result.error("attachmentTooBig", e.message, e.maxAttachmentBytes)
        } catch (t: Throwable) {
            result.error("unknownError", t.message, null)
            Logger.error(TAG, "Unexpected error calling ${call.method}: ${t}")
        }
    }

    open fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "get" -> {
                val path = call.arguments<String>()
                db.getRaw<Any>(path)?.valueOrProtoBytes
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
        val subscriberID = args["subscriberID"] as String
        val path = args["path"] as String
        val details = args["details"]?.let { it as Boolean } ?: false
        activeSubscribers.add(subscriberID)

        if (details) {
            val subscriber: DetailsSubscriber<Any> = object : DetailsSubscriber<Any>(subscriberID, path) {
                override fun onChanges(changes: DetailsChangeSet<Any>) {
                    handler.post {
                        synchronized(this@BaseModel) {
                            activeSink.get()?.success(
                                    mapOf("s" to subscriberID,
                                            "u" to changes.updates.map { (path, value) -> path to value.value.valueOrProtoBytes }.toMap(),
                                            "d" to changes.deletions.toList()))
                        }
                    }
                }
            }
            db.subscribe(subscriber)
        } else {
            val subscriber: RawSubscriber<Any> = object : RawSubscriber<Any>(subscriberID, path) {
                override fun onChanges(changes: RawChangeSet<Any>) {
                    handler.post {
                        synchronized(this@BaseModel) {
                            activeSink.get()?.success(
                                    mapOf("s" to subscriberID,
                                            "u" to changes.updates.map { (path, value) -> path to value.valueOrProtoBytes }.toMap(),
                                            "d" to changes.deletions.toList()))
                        }
                    }
                }
            }
            db.subscribe(subscriber)
        }
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return
        }
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as String
        db.unsubscribe(subscriberID)
        activeSubscribers.remove(subscriberID)
    }

    fun destroy() {
        activeSubscribers.forEach {
            db.unsubscribe(it)
        }
    }
}