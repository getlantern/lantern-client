package io.lantern.isimud.model

import io.flutter.embedding.engine.FlutterEngine
import io.lantern.observablemodel.ObservableModel
import org.getlantern.lantern.LanternApp
import java.io.File

/**
 * Created by DoNguyen on 10/3/21.
 */
class MessagingModel(flutterEngine: FlutterEngine) : Model("messaging", flutterEngine, ObservableModel.build(
        ctx = LanternApp.getAppContext(),
        filePath = File(
                File(LanternApp.getAppContext().filesDir, ".lantern"),
                "messaging_db"
        ).absolutePath,
        password = "password" // TODO: make the password random and save it as an encrypted preference
))