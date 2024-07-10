package io.lantern.model

import android.app.Activity
import internalsdk.SessionModel
import internalsdk.SessionModelOpts
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.model.dbadapter.DBAdapter
import org.getlantern.lantern.LanternApp

class SessionModel(
    private val activity: Activity,
    flutterEngine: FlutterEngine,
    opts: SessionModelOpts
) : GoModel<SessionModel>(
    "session",
    flutterEngine,
    LanternApp.getSession().db,
    SessionModel(DBAdapter(masterDB.db),opts),
    ) {

}