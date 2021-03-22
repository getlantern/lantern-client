package io.lantern.isimud.model

import io.flutter.embedding.engine.FlutterEngine
import org.getlantern.lantern.model.LanternSessionManager

class SessionModel(
    flutterEngine: FlutterEngine? = null
) : Model("session", flutterEngine) {

    companion object {
        const val PATH_PRO_USER = "/${LanternSessionManager.PRO_USER}"
        const val PATH_YINBI_ENABLED = "/${LanternSessionManager.YINBI_ENABLED}"
    }

    init {
        observableModel.mutate { tx ->
            // initialize data for fresh install
            tx.put(
                namespacedPath(PATH_PRO_USER),
                tx.get<Boolean>(namespacedPath(PATH_PRO_USER)) ?: false
            )
        }
    }
}