package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import org.getlantern.mobilesdk.model.SessionManager

/**
 * This is a model that uses the same db schema as the preferences in SessionManager so that those
 * settings can be observed.
 */
class SessionModel(
    flutterEngine: FlutterEngine? = null,
) : BaseModel("session", flutterEngine, masterDB.withSchema(SessionManager.PREFERENCES_SCHEMA)) {

    companion object {
        const val PATH_PROXY_ALL = "proxyAll"
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "switchProxyAll" -> {
                val on = call.argument<Boolean>("on") ?: false
                saveProxyAll(on)
            }
            else -> super.doMethodCall(call, notImplemented)
        }
    }

    fun saveProxyAll(on: Boolean) {
        db.mutate { tx ->
            tx.put(PATH_PROXY_ALL, on)
        }
    }
}
