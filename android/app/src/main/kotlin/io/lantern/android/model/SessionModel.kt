package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import org.getlantern.lantern.model.LanternSessionManager

class SessionModel(
    flutterEngine: FlutterEngine? = null
) : Model("session", flutterEngine) {

    companion object {
        const val PATH_PRO_USER = "/${LanternSessionManager.PRO_USER}"
        const val PATH_YINBI_ENABLED = "/${LanternSessionManager.YINBI_ENABLED}"
        const val PATH_SHOULD_SHOW_YINBI_BADGE = "/${LanternSessionManager.SHOULD_SHOW_YINBI_BADGE}"
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
        }
    }
}