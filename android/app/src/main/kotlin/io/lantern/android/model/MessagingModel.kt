package io.lantern.android.model

import android.content.pm.PackageManager
import android.media.audiofx.AutomaticGainControl
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.lantern.messaging.*
import org.getlantern.lantern.MainActivity
import org.whispersystems.signalservice.internal.util.Util
import top.oply.opuslib.OpusRecorder
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.util.concurrent.atomic.AtomicReference

class MessagingModel constructor(private val activity: MainActivity, flutterEngine: FlutterEngine, private val messaging: Messaging) : BaseModel("messaging", flutterEngine, messaging.db) {
    private val voiceMemoFile = File(activity.cacheDir, "_voicememo.opus") // TODO: would be nice not to record the unencrypted voice memo to disk
    private val videoFile = File(activity.cacheDir, "_playingvideo") // TODO: would be nice to expose this via a MediaDataSource instead
    private val stopRecording = AtomicReference<Runnable>()

    init {
        // delete any lingering data in temporary media files (e.g. if we crashed during recording)
        voiceMemoFile.delete() // TODO: overwrite data with zeros rather than just deleting
        videoFile.delete()
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "setCurrentConversationContact" -> CurrentConversationContact.id = (call.arguments as String)
            "clearCurrentConversationContact" -> CurrentConversationContact.id = ""
            "setMyDisplayName" -> messaging.setMyDisplayName(call.argument("displayName") ?: "")
            "addProvisionalContact" -> messaging.addProvisionalContact(
                call.argument("contactId")!!
            )
            "deleteProvisionalContact" -> messaging.deleteProvisionalContact(
                call.argument("contactId")!!
            )
            "setDisappearSettings" -> messaging.setDisappearSettings(
                call.argument<String>("contactId")!!.directContactPath,
                call.argument("seconds")!!
            )
            "sendToDirectContact" ->
                messaging.sendToDirectContact(
                    call.argument("identityKey")!!,
                    text = call.argument("text"),
                    attachments = call.argument<List<ByteArray>>("attachments")?.map { Model.StoredAttachment.parseFrom(it) }?.toTypedArray(),
                    replyToId = call.argument("replyToId"),
                    replyToSenderId = call.argument("replyToSenderId")
                )
            // "getContactFromUsername" -> messaging.getContactFromUsername(
            //     call.argument("username")!!,
            // )
            "react" -> messaging.react(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath, call.argument("reaction")!!)
            "markViewed" -> messaging.markViewed(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteLocally" -> messaging.deleteLocally(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteGlobally" -> messaging.deleteGlobally(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteDirectContact" -> messaging.deleteDirectContact(call.argument<String>("id")!!)
            "introduce" -> messaging.introduce(recipientIds = call.argument<List<String>>("recipientIds")!!)
            "acceptIntroduction" -> messaging.acceptIntroduction(fromId= call.argument<String>("fromId")!!, toId = call.argument<String>("toId")!!)
            "rejectIntroduction" -> messaging.rejectIntroduction(fromId= call.argument<String>("fromId")!!, toId = call.argument<String>("toId")!!)
            "startRecordingVoiceMemo" -> startRecordingVoiceMemo()
            "stopRecordingVoiceMemo" -> {
                try {
                    stopRecordingVoiceMemo()
                    return messaging.createAttachment(
                        voiceMemoFile,
                        "audio/ogg",
                        lazy = false
                    ).toByteArray()
                } finally {
                    voiceMemoFile.delete()
                }
            }
            "filePickerLoadAttachment" -> {
                val filePath = call.argument<String>("filePath")
                val file = File(filePath!!)
                val metadata = call.argument<Map<String, String>?>("metadata")
                return messaging.createAttachment(file, "", metadata).toByteArray()
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
            "decryptVideoForPlayback" -> {
                val attachment = Model.StoredAttachment.parseFrom(call.argument<ByteArray>("attachment")!!)
                videoFile.delete()
                videoFile.outputStream().use { output ->
                    attachment.inputStream.use { input ->
                        Util.copy(input, output)
                    }
                }
                return videoFile.absolutePath
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

    //(TODO): On ocassions OPUS breaks the app, throwing the following error, need to investigate how to fix this.
    //F/libc    (12804): Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR),
    //fault addr 0x90 in tid 28989 (OpusRecorder re), pid 12804 (lantern.lantern)
    private fun doStartRecordingVoiceMemo() {
        stopRecording.set(
            OpusRecorder.startRecording(
                voiceMemoFile.absolutePath, OpusRecorder.OpusApplication.VOIP, 16000, 24000, false, 120000
            ) { audioSessionId ->
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
        )
    }

    private fun stopRecordingVoiceMemo(): ByteArray? {
        return stopRecording.get()?.let {
            it.run()
            val bytes = ByteArray(voiceMemoFile.length().toInt())
            FileInputStream(voiceMemoFile).use { input ->
                input.read(bytes)
            }
            bytes
        }
    }
}
