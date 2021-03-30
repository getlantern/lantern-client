package io.lantern.android.model

import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.lantern.messaging.Messaging
import org.getlantern.lantern.MainActivity
import top.oply.opuslib.OpusRecorder
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileInputStream
import java.util.concurrent.atomic.AtomicReference

class MessagingModel constructor(private val activity: MainActivity, flutterEngine: FlutterEngine, private val messaging: Messaging) : Model("messaging", flutterEngine, messaging.db) {
    private val voiceMemoFile = File(activity.filesDir, "_voicememo.opus")
    private val stopRecording = AtomicReference<Runnable>()

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "setMyDisplayName" -> messaging.setMyDisplayName(call.argument("displayName") ?: "")
            "addOrUpdateDirectContact" -> messaging.addOrUpdateDirectContact(call.argument("identityKey")!!, call.argument("displayName")!!)
            "sendToDirectContact" -> {
                messaging.sendToDirectContact(call.argument("identityKey")!!, text = call.argument("text"), oggVoice = call.argument("oggVoice"))
                null
            }
            "startRecordingVoiceMemo" -> startRecordingVoiceMemo()
            "stopRecordingVoiceMemo" -> stopRecordingVoiceMemo()
            else -> super.doMethodCall(call, notImplemented)
        }
    }

    private fun startRecordingVoiceMemo() {
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.M) {
            doStartRecordingVoiceMemo()
        } else if (activity.checkSelfPermission(android.Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(android.Manifest.permission.RECORD_AUDIO),
                    MainActivity.RECORD_AUDIO_PERMISSIONS_REQUEST
            )
        } else {
            doStartRecordingVoiceMemo()
        }
    }

    private fun doStartRecordingVoiceMemo() {
        stopRecording.set(OpusRecorder.startRecording(voiceMemoFile.absolutePath, OpusRecorder.OpusApplication.VOIP, 16000, 16000, false))
    }

    private fun stopRecordingVoiceMemo(): ByteArray? {
        return stopRecording.get()?.let {
            it.run()
            val bytes = ByteArray(voiceMemoFile.length().toInt())
            val out = ByteArrayInputStream(bytes)
            val input = FileInputStream(voiceMemoFile)
            try {
                input.read(bytes)
            } finally {
                input.close()
            }
            bytes
        } ?: null
    }
}