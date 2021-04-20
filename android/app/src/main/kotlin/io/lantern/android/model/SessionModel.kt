package io.lantern.android.model

import io.flutter.embedding.engine.FlutterEngine
import org.getlantern.mobilesdk.model.SessionManager

/**
 * This is a model that uses the same db schema as the preferences in SessionManager so that those
 * settings can be observed.
 */
class SessionModel(
        flutterEngine: FlutterEngine? = null,
) : BaseModel("session", flutterEngine, masterDB.withSchema(SessionManager.PREFERENCES_SCHEMA))