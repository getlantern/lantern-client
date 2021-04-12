package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.model.LanternSessionManager
import org.getlantern.mobilesdk.model.SessionManager

class SessionModel(
    flutterEngine: FlutterEngine? = null
) : Model("session", flutterEngine) {

    companion object {
        const val PATH_PRO_USER = "/${LanternSessionManager.PRO_USER}"
        const val PATH_YINBI_ENABLED = "/${LanternSessionManager.YINBI_ENABLED}"
        const val PATH_SHOULD_SHOW_YINBI_BADGE = "/${LanternSessionManager.SHOULD_SHOW_YINBI_BADGE}"
        const val PATH_PROXY_ALL = "/${SessionManager.PROXY_ALL}"
    }

    init {
        db.mutate { tx ->
            // initialize data for fresh install // TODO remove the need to do this for each data path
            tx.put(
                namespacedPath(PATH_PRO_USER),
                tx.get<Boolean>(namespacedPath(PATH_PRO_USER)) ?: false
            )
            tx.put(
                namespacedPath(PATH_YINBI_ENABLED),
                tx.get<Boolean>(namespacedPath(PATH_YINBI_ENABLED)) ?: false
            )
            tx.put(
                namespacedPath(PATH_SHOULD_SHOW_YINBI_BADGE),
                tx.get<Boolean>(namespacedPath(PATH_SHOULD_SHOW_YINBI_BADGE)) ?: true
            )
            tx.put(
                namespacedPath(PATH_PROXY_ALL),
                tx.get<Boolean>(namespacedPath(PATH_PROXY_ALL)) ?: false
            )
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "switchProxyAll" -> {
                val on = call.argument<Boolean>("on") ?: false
                saveProxyAll(on)
                result.success(true)
            }
            else -> super.onMethodCall(call, result)
        }
    }

    fun saveProxyAll(on: Boolean) {
        db.mutate { tx ->
            tx.put(namespacedPath(PATH_PROXY_ALL), on)
        }
    }
}