package io.lantern.model

import internalsdk.Arguments
import internalsdk.SubscriptionRequest
import internalsdk.UpdaterModel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.db.DB
import io.lantern.db.DetailsChangeSet
import io.lantern.db.DetailsSubscriber
import io.lantern.db.RawChangeSet
import io.lantern.db.RawSubscriber
import minisql.Value

class GoModel constructor(
    val name: String,
    flutterEngine: FlutterEngine,
    db: DB,
    private val model: internalsdk.Model,
) : BaseModel(name, flutterEngine, db) {
    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            val resultVal = model.invokeMethod(call.method, Arguments(call))
            result.success(resultVal.toJava())
        } catch (t: Throwable) {
            result.error("unknownError", t.message, null)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        activeSink.set(events)
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as String
        val path = args["path"] as String
        val details = args["details"]?.let { it as Boolean } ?: false
        activeSubscribers.add(subscriberID)

        val req = SubscriptionRequest()
        req.id = subscriberID
        req.joinDetails = details
        req.pathPrefixes = path
        req.updater = UpdaterModel {
            val updates = HashMap<String, Any>()
            val deletions = ArrayList<String>()
            while (it.hasUpdate()) {
                val update = it.popUpdate()
                updates[update.path] = update.value.toJava()
            }
            while (it.hasDelete()) {
                deletions.add(it.popDelete())
            }
            activeSink.get()?.success(
                mapOf(
                    "s" to subscriberID,
                    "u" to updates,
                    "d" to deletions,
                )
            )
        }
        model.subscribe(req)
    }
}

private class Arguments constructor(private val call: MethodCall) : Arguments {
    override fun get(key: String): Value? =
        when (val arg = call.argument<Any>(key)) {
            is Long -> minisql.Value(arg)
            is Int -> minisql.Value(arg.toLong())
            is String -> minisql.Value(arg)
            is Boolean -> minisql.Value(arg)
            is ByteArray -> minisql.Value(arg)
            else -> null
        }

    override fun scalar(): Value? =
        when (val arg = call.arguments) {
            is Long -> minisql.Value(arg)
            is Int -> minisql.Value(arg.toLong())
            is String -> minisql.Value(arg)
            is Boolean -> minisql.Value(arg)
            is ByteArray -> minisql.Value(arg)
            else -> null
        }
}

fun Value.toJava(): Any = when (type) {
    0L -> bytes()
    1L -> string()
    2L -> int_()
    3L -> bool()
    else -> throw RuntimeException("unknown value type $type")
}