package io.lantern.model

import android.content.Context
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import com.google.protobuf.GeneratedMessageLite
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.db.DB
import io.lantern.db.DetailsChangeSet
import io.lantern.db.DetailsSubscriber
import io.lantern.db.RawChangeSet
import io.lantern.db.RawSubscriber
import io.lantern.messaging.AttachmentTooBigException
import io.lantern.messaging.clear
import io.lantern.secrets.InsecureSecretException
import io.lantern.secrets.Secrets
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.SessionManager
import java.io.File
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

abstract class BaseModel(
    private val name: String,
    flutterEngine: FlutterEngine,
    val db: DB,
) : EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    protected val activeSubscribers = ConcurrentSkipListSet<String>()
    protected val mainHandler = Handler(Looper.getMainLooper())
    private val asyncHandlerThread = HandlerThread("BaseModel-AsyncHandler")

    init {
        asyncHandlerThread.start()
    }

    private val asyncHandler = Handler(asyncHandlerThread.looper)

    protected lateinit var eventChannel: EventChannel
    protected lateinit var methodChannel: MethodChannel

    companion object {
        private const val TAG = "BaseModel"
        private const val dbPasswordKey = "dbPassword"
        private const val dbPasswordLength = 32

        val masterDB: DB

        init {
            val start = System.currentTimeMillis()
            val context = LanternApp.getAppContext()
            Logger.debug(
                TAG,
                "LanternApp.getAppContext() finished at ${System.currentTimeMillis() - start}"
            )
            val oldSecretsPreferences =
                context.getSharedPreferences("secrets", Context.MODE_PRIVATE)
            val secretsPreferences = context.getSharedPreferences("secretsv2", Context.MODE_PRIVATE)
            Logger.debug(
                TAG,
                "getSharedPreferences() finished at ${System.currentTimeMillis() - start}"
            )
            val secrets = Secrets("lanternMasterKey", secretsPreferences, oldSecretsPreferences)
            Logger.debug(TAG, "Secrets() finished at ${System.currentTimeMillis() - start}")

            val dbDir = File(context.filesDir, "masterDBv2")
            dbDir.mkdirs()
            val dbLocation = File(dbDir, "db").absolutePath
            var insecureDbPassword: String? = null
            val dbPassword = try {
                secrets.get(dbPasswordKey, dbPasswordLength)
            } catch (e: InsecureSecretException) {
                Logger.debug(
                    TAG,
                    "Old database password was stored insecurely, generate a new database password and prepare to copy data"
                )
                insecureDbPassword = e.secret
                e.regenerate(dbPasswordLength)
            }
            masterDB = DB.createOrOpen(context, dbLocation, dbPassword)
            dbPassword.clear()
            insecureDbPassword?.let { insecurePassword ->
                Logger.debug(
                    TAG,
                    "found old database encrypted with insecure password, migrate data to new secure database"
                )
                // What made the old password insecure is that it was stored as a String which
                // tends to stick around for a long time in memory. We only ever used string
                // passwords prior to the release of messaging, so nothing particularly sensitive
                // was encrypted with the old password and it's okay to just copy the data to the
                // new database.
                val insecureDbDir = File(context.filesDir, "masterDB")
                val insecureDB = DB.createOrOpen(
                    context,
                    File(insecureDbDir, "db").absolutePath,
                    insecurePassword.toByteArray(Charsets.UTF_8)
                )
                var keysMigrated = 0
                masterDB.withSchema(SessionManager.PREFERENCES_SCHEMA).mutate { tx ->
                    insecureDB
                        .withSchema(SessionManager.PREFERENCES_SCHEMA)
                        .listRaw<Any>("%").forEach {
                            tx.putRaw(it.path, it.value)
                            keysMigrated++
                        }
                }
                insecureDbDir.deleteRecursively()
                Logger.debug(TAG, "migrated $keysMigrated keys from insecure database")
            }
            Logger.debug(TAG, "createOrOpen finished at ${System.currentTimeMillis() - start}")
        }
    }

    init {
        flutterEngine.let {
            eventChannel = EventChannel(
                flutterEngine.dartExecutor,
                "${name}_event_channel"
            )
            eventChannel.setStreamHandler(this)

            methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "${name}_method_channel"
            )
            methodChannel.setMethodCallHandler(this)
        }
    }

    final override fun onMethodCall(call: MethodCall, mcResult: MethodChannel.Result) {
        // Process all calls on a separate thread to avoid blocking the UI, then post results back
        // on the main thread.
        asyncHandler.post {
            doOnMethodCall(
                call,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        mainHandler.post {
                            mcResult.success(result)
                        }
                    }

                    override fun error(
                        errorCode: String,
                        errorMessage: String?,
                        errorDetails: Any?
                    ) {
                        mainHandler.post {
                            mcResult.error(errorCode, errorMessage, errorDetails)
                        }
                    }

                    override fun notImplemented() {
                        mainHandler.post {
                            mcResult.notImplemented()
                        }
                    }
                }
            )
        }
    }

    open fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
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
            Logger.error(TAG, "Unexpected error calling ${call.method}: $t")
        }
    }

    open fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "get" -> {
                val path = call.arguments<String>()
                db.getRaw<Any>(path!!)?.valueOrProtoBytes
            }

            "list" -> {
                val path = call.argument<String>("path")
                val start = call.argument<Int?>("start") ?: 0
                val count = call.argument<Int?>("count") ?: Int.MAX_VALUE
                val fullTextSearch = call.argument<String?>("fullTextSearch")
                val reverseSort = call.argument<Boolean?>("reverseSort") ?: false
                db.listRaw<Any>(path!!, start, count, reverseSort)
                    .map { it.value.valueOrProtoBytes }
            }

            else -> notImplemented()
        }
    }

    protected val activeSink = AtomicReference<EventChannel.EventSink?>()

    @Synchronized
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        activeSink.set(events)
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as String
        val path = args["path"] as String
        val details = args["details"]?.let { it as Boolean } ?: false
        activeSubscribers.add(subscriberID)
        if (details) {
            val subscriber: DetailsSubscriber<Any> =
                object : DetailsSubscriber<Any>(subscriberID, path) {
                    override fun onChanges(changes: DetailsChangeSet<Any>) {
                        mainHandler.post {
                            synchronized(this@BaseModel) {
                                activeSink.get()?.success(
                                    mapOf(
                                        "s" to subscriberID,
                                        "u" to changes.updates.map { (path, value) -> path to value.value.valueOrProtoBytes }
                                            .toMap(),
                                        "d" to changes.deletions.toList()
                                    )
                                )
                            }
                        }
                    }
                }
            db.subscribe(subscriber)
        } else {
            val subscriber: RawSubscriber<Any> = object : RawSubscriber<Any>(subscriberID, path) {
                override fun onChanges(changes: RawChangeSet<Any>) {
                    mainHandler.post {
                        synchronized(this@BaseModel) {
                            activeSink.get()?.success(
                                mapOf(
                                    "s" to subscriberID,
                                    "u" to changes.updates.map { (path, value) -> path to value.valueOrProtoBytes }
                                        .toMap(),
                                    "d" to changes.deletions.toList()
                                )
                            )
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
