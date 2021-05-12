package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.model.SessionManager

/**
 * This is a model that uses the same db schema as the preferences in SessionManager so that those
 * settings can be observed.
 */
class SessionModel(
    flutterEngine: FlutterEngine? = null,
) : BaseModel("session", flutterEngine, masterDB.withSchema(SessionManager.PREFERENCES_SCHEMA)) {

    companion object {
        const val PATH_PRO_USER = "prouser"
        const val PATH_YINBI_ENABLED = "yinbienabled"
        const val PATH_SHOULD_SHOW_YINBI_BADGE = "should_show_yinbi_badge"
        const val PATH_PROXY_ALL = "proxyAll"
    }

    init {
        db.mutate { tx ->
            // initialize data for fresh install // TODO remove the need to do this for each data path
            tx.put(
                PATH_PRO_USER,
                tx.get(PATH_PRO_USER) ?: false
            )
            tx.put(
                PATH_YINBI_ENABLED,
                tx.get(PATH_YINBI_ENABLED) ?: false
            )
            tx.put(
                PATH_SHOULD_SHOW_YINBI_BADGE,
                tx.get(PATH_SHOULD_SHOW_YINBI_BADGE) ?: true
            )
            tx.put(
                PATH_PROXY_ALL,
                tx.get(PATH_PROXY_ALL) ?: false
            )
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "switchProxyAll" -> {
                val on = call.argument<Boolean>("on") ?: false
                saveProxyAll(on)
            }
            "setLanguage" -> {
                LanternApp.getSession().setLanguage(call.argument("lang"))
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
