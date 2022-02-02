package io.lantern.android.model

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R


class ReplicaModel(
    private val activity: MainActivity,
    flutterEngine: FlutterEngine? = null,
) : BaseModel("replica", flutterEngine, masterDB.withSchema("replica")) {

    companion object {
        private const val TAG = "ReplicaModel"
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "downloadFile" -> downloadFile(call)
            "setSuppressUploadWarning" -> setSuppressUploadWarning(call)
            else -> super.doMethodCall(call, notImplemented)
        }
    }

    private fun downloadFile(call: MethodCall) {
        Log.d(TAG, "downloadFile: ")
        val url = call.argument<String>("url")!!
        val displayName = call.argument<String>("displayName")!!
        val request: DownloadManager.Request = DownloadManager.Request(Uri.parse(url))
        request.setTitle(displayName)
        request.setDescription(activity.getString(R.string.replica_download))
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
        // Note - the DownloadManager correctly handles the case where a file with the same name
        // already exists by appending a sequence number to it.
        request.setDestinationInExternalPublicDir(
            Environment.DIRECTORY_DOWNLOADS,
            displayName
        )
        activity.getSystemService(Context.DOWNLOAD_SERVICE)?.let { manager ->
            (manager as DownloadManager).enqueue(request)
        }
    }

    private fun setSuppressUploadWarning(call: MethodCall) {
        val suppress = call.argument<Boolean>("suppress")
        db.mutate { tx ->
            tx.put("suppressUploadWarning", suppress)
        }
    }
}

