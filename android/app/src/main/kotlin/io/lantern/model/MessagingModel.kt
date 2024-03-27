package io.lantern.model

import android.content.pm.PackageManager
import android.media.audiofx.AutomaticGainControl
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.messaging.WebRTCSignal
import org.getlantern.lantern.MainActivity
import top.oply.opuslib.OpusRecorder
import java.io.File
import java.io.FileInputStream
import java.util.concurrent.atomic.AtomicReference

class MessagingModel(
    private val activity: MainActivity,
    flutterEngine: FlutterEngine,
//    private val messaging: Messaging
) : BaseModel("messaging", flutterEngine, masterDB.withSchema("messaging")) {
    private val voiceMemoFile = File(
        activity.cacheDir,
        "_voicememo.opus"
    ) // TODO: would be nice not to record the unencrypted voice memo to disk
    private val videoFile = File(
        activity.cacheDir,
        "_playingvideo"
    ) // TODO: would be nice to expose this via a MediaDataSource instead
    private val stopRecording = AtomicReference<Runnable>()

    init {
        // delete any lingering data in temporary media files (e.g. if we crashed during recording)
        voiceMemoFile.delete() // TODO: overwrite data with zeros rather than just deleting
        videoFile.delete()

//        // subscribe to WebRTC signals and forward them to flutter
//        // TODO: handle incoming calls when UI is closed (similar to how we handle message
//        // notifications when UI is closed)
//        messaging.subscribeToWebRTCSignals("webrtc") { signal ->
//            sendSignal(signal, false) // since we have not accepted yet
//        }

        // default onboarding status to false if it hasn't been set yet
        db.mutate { tx ->
            if (!db.contains("onBoardingStatus")) {
                tx.put("onBoardingStatus", false)
            }
        }
    }

    fun sendSignal(signal: WebRTCSignal, acceptedCall: Boolean) {
        mainHandler.post {
            methodChannel.invokeMethod(
                "onSignal",
                mapOf(
                    "senderId" to signal.senderId,
                    "content" to signal.content.toString(Charsets.UTF_8),
                    "acceptedCall" to acceptedCall,
                )
            )
        }
    }

//    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        when (call.method) {
//            "sendSignal" -> {
//                messaging.sendWebRTCSignal(
//                    unsafeRecipientId = call.argument("recipientId")!!,
//                    call.argument<String>("content")!!.toByteArray(Charsets.UTF_8)
//                ) {
//                    if (it.succeeded) {
//                        result.success(null)
//                    } else {
//                        // for now, if there are any errors sending to any devices, we use the first
//                        result.error(
//                            "failed",
//                            it.error?.toString() ?: it.deviceErrors?.values?.first()?.toString(),
//                            null
//                        )
//                    }
//                }
//            }
//            "findChatNumberByShortNumber" -> {
//                messaging.findChatNumberByShortNumber(
//                    call.argument<String>("shortNumber")!!
//                ) { chatNumber, err ->
//                    if (err != null) {
//                        result.error(
//                            "failed",
//                            err.toString(),
//                            null,
//                        )
//                    } else {
//                        result.success(chatNumber!!.toByteArray())
//                    }
//                }
//            }
//            else -> super.doOnMethodCall(call, result)
//        }
//    }

    private fun startRecordingVoiceMemo(): Boolean {
        return if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M && activity.checkSelfPermission(
                android.Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
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

    // (TODO): Occasionally, OPUS breaks the app, throwing the following error, need to investigate how to fix this.
    // F/libc    (12804): Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR),
    // fault addr 0x90 in tid 28989 (OpusRecorder re), pid 12804 (lantern.lantern)
    private fun doStartRecordingVoiceMemo() {
        stopRecording.set(
            OpusRecorder.startRecording(
                voiceMemoFile.absolutePath,
                OpusRecorder.OpusApplication.VOIP,
                16000,
                24000,
                false,
                120000
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
        return stopRecording.getAndSet(null)?.let {
            it.run()
            val bytes = ByteArray(voiceMemoFile.length().toInt())
            FileInputStream(voiceMemoFile).use { input ->
                input.read(bytes)
            }
            bytes
        }
    }

    companion object {
        var currentConversationContact: TimestampedContactId? = null

        val snippetHighlight = "**"
    }
}

data class TimestampedContactId(val ts: Long, val contactId: String)
