package io.lantern.android.model

import android.content.pm.PackageManager
import android.media.audiofx.AutomaticGainControl
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.lantern.messaging.Messaging
import io.lantern.messaging.Model
import io.lantern.messaging.dbPath
import io.lantern.messaging.inputStream
import org.getlantern.lantern.MainActivity
import org.whispersystems.signalservice.internal.util.Util
import top.oply.opuslib.OpusRecorder
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.util.concurrent.atomic.AtomicReference

class MessagingModel constructor(private val activity: MainActivity, flutterEngine: FlutterEngine, private val messaging: Messaging) : BaseModel("messaging", flutterEngine, messaging.db) {
    private val voiceMemoFile = File(activity.cacheDir, "_voicememo.opus") // TODO: would be nice not to record the unencrypted voice memo to disk
    private val startedRecording = AtomicReference<Long>()
    private val stopRecording = AtomicReference<Runnable>()
    init {
        // delete any lingering data in voiceMemoFile (e.g. if we crashed during recording)
        voiceMemoFile.delete() // TODO: overwrite data with zeros rather than just deleting
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "setMyDisplayName" -> messaging.setMyDisplayName(call.argument("displayName") ?: "")
            "addOrUpdateDirectContact" -> messaging.addOrUpdateDirectContact(call.argument("identityKey")!!, call.argument("displayName")!!)
            "setDisappearSettings" -> messaging.setDisappearSettings(call.argument("contactId")!!, call.argument("seconds")!!)
            "sendToDirectContact" ->
                messaging.sendToDirectContact(
                        call.argument("identityKey")!!,
                        text = call.argument("text"),
                        attachments = call.argument<List<ByteArray>>("attachments")?.map { Model.StoredAttachment.parseFrom(it) }?.toTypedArray())
            "react" -> messaging.react(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath, call.argument("reaction")!!)
            "markViewed" -> messaging.markViewed(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteLocally" -> messaging.deleteLocally(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteGlobally" -> messaging.deleteGlobally(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "startRecordingVoiceMemo" -> startRecordingVoiceMemo()
            "stopRecordingVoiceMemo" -> {
                try {
                    val started = startedRecording.get()
                    stopRecordingVoiceMemo()
                    val duration = (System.currentTimeMillis() - started).toDouble() / 1000.0
                    return messaging.createAttachment(
                            "audio/ogg",
                            voiceMemoFile,
                            mapOf("duration" to duration.toString(), "role" to "voiceMemo")).toByteArray()
                } finally {
                    voiceMemoFile.delete() // TODO: overwrite data with zeros rather than just deleting
                }
            }
            "filePickerLoadAttachment" -> {
                try {
                    return messaging.createAttachment("image/*",call.argument("filePath")!!).toByteArray() 
                } finally {
                    // TODO: clear attachment data?
                }
            }
            "decryptAttachment" -> {
                val attachment = Model.StoredAttachment.parseFrom(call.argument<ByteArray>("attachment")!!)
                ByteArrayOutputStream(attachment.attachment.plaintextLength.toInt()).use { output ->
                    attachment.inputStream.use { input ->
                        Util.copy(input, output)
                    }
                    return output.toByteArray()
                }
            }
            else -> super.doMethodCall(call, notImplemented)
        }
    }

    private fun startRecordingVoiceMemo(): Boolean {
        return if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M && activity.checkSelfPermission(android.Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(android.Manifest.permission.RECORD_AUDIO),
                    MainActivity.RECORD_AUDIO_PERMISSIONS_REQUEST
            )
            false
        } else {
            doStartRecordingVoiceMemo()
            true
        }
    }

    private fun doStartRecordingVoiceMemo() {
        startedRecording.set(System.currentTimeMillis())
        stopRecording.set(OpusRecorder.startRecording(voiceMemoFile.absolutePath, OpusRecorder.OpusApplication.VOIP, 16000, 24000, false, 120000, object : OpusRecorder.EffectsInitializer {
            override fun init(audioSessionId: Int) {
                if (AutomaticGainControl.isAvailable()) {
                    try {
                        val automaticGainControl = AutomaticGainControl.create(audioSessionId)
                        if (automaticGainControl != null) automaticGainControl.enabled = true
                    } catch (t: Throwable) {
                        // couldn't init automatic gain control, won't use
                    }
                }
                if (NoiseSuppressor.isAvailable()) {
                    try {
                        val noiseSuppressor = NoiseSuppressor.create(audioSessionId)
                        if (noiseSuppressor != null) noiseSuppressor.enabled = true
                    } catch (t: Throwable) {
                        // couldn't init noise suppressor, won't use
                    }
                }
            }
        }))
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