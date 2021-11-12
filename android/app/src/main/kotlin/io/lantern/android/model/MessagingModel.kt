package io.lantern.android.model

import android.content.pm.PackageManager
import android.media.audiofx.AutomaticGainControl
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.db.SnippetConfig
import io.lantern.messaging.Messaging
import io.lantern.messaging.Model
import io.lantern.messaging.WebRTCSignal
import io.lantern.messaging.dbPath
import io.lantern.messaging.directContactPath
import io.lantern.messaging.inputStream
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

        // subscribe to WebRTC signals and forward them to flutter
        // TODO: handle incoming calls when UI is closed (similar to how we handle message
        // notifications when UI is closed)
        messaging.subscribeToWebRTCSignals("webrtc") { signal ->
            sendSignal(signal, false) // since we have not accepted yet
        }

        messaging
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

    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendSignal" -> {
                messaging.sendWebRTCSignal(
                    unsafeRecipientId = call.argument("recipientId")!!,
                    call.argument<String>("content")!!.toByteArray(Charsets.UTF_8)
                ) {
                    if (it.succeeded) {
                        result.success(null)
                    } else {
                        // for now, if there are any errors sending to any devices, we use the first
                        result.error(
                            "failed",
                            it.error?.toString() ?: it.deviceErrors?.values?.first()?.toString(),
                            null
                        )
                    }
                }
            }
            "findChatNumberByShortNumber" -> {
                messaging.findChatNumberByShortNumber(
                    call.argument<String>("shortNumber")!!
                ) { chatNumber, err ->
                    if (err != null) {
                        result.error(
                            "failed",
                            err.toString(),
                            null,
                        )
                    } else {
                        result.success(chatNumber!!.toByteArray())
                    }
                }
            }
            else -> super.doOnMethodCall(call, result)
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            /*
            * Contacts
            */
            "setCurrentConversationContact" -> currentConversationContact = (call.arguments as String)
            "clearCurrentConversationContact" -> currentConversationContact = ""
            "addProvisionalContact" -> messaging.addProvisionalContact(
                call.argument("unsafeContactId")!!,
                when (call.argument<Any>("source")) {
                    "qr" -> Model.ContactSource.APP1
                    "id" -> Model.ContactSource.APP2
                    else -> null
                },
                Model.VerificationLevel.VERIFIED,
            ).let { result ->
                mapOf(
                    "mostRecentHelloTsMillis" to result.mostRecentHelloTsMillis,
                    "expiresAtMillis" to result.expiresAtMillis
                )
            }
            "deleteProvisionalContact" -> messaging.deleteProvisionalContact(
                call.argument("unsafeContactId")!!
            )
            "addOrUpdateDirectContact" -> {
                val unsafeId = call.argument<String>("unsafeId")
                val chatNumber = call.argument<ByteArray>("chatNumber")?.let {
                    Model.ChatNumber.parseFrom(it)
                }
                val displayName = call.argument<String>("displayName")
                val source = when (call.argument<Any>("source")) {
                    "qr" -> Model.ContactSource.APP1
                    "id" -> Model.ContactSource.APP2
                    else -> null
                }
                val minimumVerificationLevel = Model.VerificationLevel.UNVERIFIED
                return messaging.addOrUpdateDirectContact(
                    unsafeId,
                    displayName,
                    source,
                    minimumVerificationLevel = minimumVerificationLevel,
                    chatNumber = chatNumber,
                )
            }
            "acceptDirectContact" -> messaging.acceptDirectContact(call.argument("unsafeId")!!)
            "deleteDirectContact" -> messaging.deleteDirectContact(call.argument<String>("unsafeContactId")!!)
            "markDirectContactVerified" -> messaging.markDirectContactVerified(call.argument("unsafeId")!!)
            "blockDirectContact" -> messaging.blockDirectContact(call.argument("unsafeId")!!)
            "unblockDirectContact" -> messaging.unblockDirectContact(call.argument("unsafeId")!!)
            "introduce" -> messaging.introduce(unsafeRecipientIds = call.argument<List<String>>("unsafeRecipientIds")!!)
            "acceptIntroduction" -> messaging.acceptIntroduction(call.argument<String>("unsafeFromId")!!, call.argument<String>("unsafeToId")!!)
            "rejectIntroduction" -> messaging.rejectIntroduction(call.argument<String>("unsafeFromId")!!, call.argument<String>("unsafeToId")!!)
            "recover" -> messaging.recover(recoveryCode = call.argument<String>("recoveryCode")!!)
            /*
            * Messages
            */
            "setDisappearSettings" -> messaging.setDisappearSettings(
                call.argument<String>("contactId")!!.directContactPath,
                call.argument("seconds")!!
            )
            "sendToDirectContact" ->
                messaging.sendToDirectContact(
                    unsafeRecipientId = call.argument("identityKey")!!,
                    text = call.argument("text"),
                    unsafeReplyToSenderId = call.argument("replyToSenderId"),
                    replyToId = call.argument("replyToId"),
                    attachments = call.argument<List<ByteArray>>("attachments")?.map { Model.StoredAttachment.parseFrom(it) }?.toTypedArray(),
                )
            // "getContactFromUsername" -> messaging.getContactFromUsername(
            //     call.argument("username")!!,
            // )
            "react" -> messaging.react(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath, call.argument("reaction")!!)
            "markViewed" -> messaging.markViewed(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteLocally" -> messaging.deleteLocally(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            "deleteGlobally" -> messaging.deleteGlobally(Model.StoredMessage.parseFrom(call.argument<ByteArray>("msg")!!).dbPath)
            /*
            * Attachments
            */
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
            "allocateRelayAddress" -> {
                return internalsdk.Internalsdk.allocateRelayAddress(call.arguments as String)
            }
            "relayTo" -> {
                return internalsdk.Internalsdk.relayTo(call.arguments as String)
            }
            /*
            * Search
            */
            "searchContacts" ->
                messaging
                    .searchContacts(
                        call.argument<String>("query")!!,
                        SnippetConfig(
                            highlightStart = snippetHighlight,
                            highlightEnd = snippetHighlight,
                            numTokens = call.argument("numTokens")!!
                        )
                    ).map {
                        mapOf("snippet" to it.snippet, "path" to it.path, "contact" to it.value.bytes)
                    }
            "searchMessages" ->
                messaging
                    .searchMessages(
                        call.argument<String>("query")!!,
                        SnippetConfig(
                            highlightStart = snippetHighlight,
                            highlightEnd = snippetHighlight,
                            numTokens = call.argument("numTokens")!!
                        )
                    ).map {
                        mapOf("snippet" to it.snippet, "path" to it.path, "message" to it.value.bytes)
                    }
            /*
            * Reminders
            */
            "dismissVerificationReminder" -> {
                val unsafeId = call.argument<String>("unsafeId")
                return messaging.addOrUpdateDirectContact(
                    unsafeId = unsafeId
                ) { appData ->
                    appData["verificationReminderLastDismissed"] = System.currentTimeMillis()
                }
            }
            "markIsOnboarded" -> {
                db.mutate { tx ->
                    tx.put("/onBoardingStatus", true)
                }
            }
            // for dev purposes
            "overrideOnBoarded" -> {
                val newValue = call.argument<Boolean>("newValue")!!
                db.mutate { tx ->
                    tx.put("/onBoardingStatus", newValue)
                }
            }
            "markCopiedRecoveryKey" -> {
                db.mutate { tx ->
                    tx.put("/copiedRecoveryStatus", true)
                }
            }
            "saveNotificationsTS" -> {
                val ts = System.currentTimeMillis()
                db.mutate { tx ->
                    tx.put("/requestNotificationLastDismissed", ts)
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

    // (TODO): Occasionally, OPUS breaks the app, throwing the following error, need to investigate how to fix this.
    // F/libc    (12804): Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR),
    // fault addr 0x90 in tid 28989 (OpusRecorder re), pid 12804 (lantern.lantern)
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
        var currentConversationContact = ""

        val snippetHighlight = "**"
    }
}
