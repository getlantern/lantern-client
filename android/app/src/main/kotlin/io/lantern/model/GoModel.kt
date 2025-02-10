package io.lantern.model

import internalsdk.Arguments
import internalsdk.SubscriptionRequest
import internalsdk.UpdaterModel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.db.DB
import minisql.Value
import org.getlantern.mobilesdk.Logger

open class GoModel<M : internalsdk.Model>(
    val name: String,
    flutterEngine: FlutterEngine,
    db: DB,
    protected val model: M,
) : BaseModel(name, flutterEngine, db) {
    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            val resultVal = model.invokeMethod(call.method, Arguments(call.arguments))
            result.success(resultVal.toJava())
        } catch (t: Throwable) {
            result.error("unknownError", t.message, null)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        activeSink.set(events)
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as? String ?: return  // Exit early if null
        val path = args["path"] as? String ?: return
        val details = args["details"] as? Boolean ?: false
        activeSubscribers.add(subscriberID)

        val req = SubscriptionRequest().apply {
            receiveInitial = true
            id = subscriberID
            joinDetails = details
            pathPrefixes = path
            updater = UpdaterModel {
                val updates = HashMap<String, Any>()
                val deletions = ArrayList<String>()
                while (it.hasUpdate()) {
                    val update = it.popUpdate()
                    updates[update.path] = update.value.toJava()
                }
                while (it.hasDelete()) {
                    deletions.add(it.popDelete())
                }
                Logger.debug("GoModel", "notifying $activeSink.get() on path $path updates: $updates")
                mainHandler.post {
                    synchronized(this@GoModel) {
                        activeSink.get()?.success(
                            mapOf(
                                "s" to subscriberID,
                                "u" to updates,
                                "d" to deletions,
                            )
                        )
                    }
                }
            }
        }
        model.subscribe(req)
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return
        }
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as String
        model.unsubscribe(subscriberID)
        activeSubscribers.remove(subscriberID)
    }
}

public class Arguments(args: Any) : Arguments {

    private var scalarValue: Value? = null
    private val dict: MutableMap<String, Value> = mutableMapOf()

    init {
        when (args) {
            is Map<*, *> -> {
                args.forEach { (key, value) ->
                    if (key is String) {
                        dict[key] = anyToValue(value)
                    }
                }
            }
            else -> {
                scalarValue = anyToValue(args)
            }
        }
    }

    override fun get(key: String): Value? = dict[key]

    override fun scalar(): Value? = scalarValue


    private fun anyToValue(v: Any?): Value {
        return when (v) {
            is String -> Value(v)
            is Boolean -> Value(v)
            is Int -> Value(v.toLong())
            is Long -> Value(v)
            is ByteArray -> Value(v)
            else -> throw IllegalArgumentException("Unrecognized value type: ${v?.javaClass}")
        }
    }
}

fun Value.toJava(): Any = when (type) {
    0L -> bytes()
    1L -> string()
    2L -> int_()
    3L -> bool()
    else -> throw RuntimeException("unknown value type $type")
}