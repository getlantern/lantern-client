package io.lantern.model

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
    flutterEngine: FlutterEngine,
) : BaseModel("replica", flutterEngine, masterDB.withSchema("replica")) {

    companion object {
        private const val TAG = "ReplicaModel"
        const val PATH_SEARCH_TERM = "/searchTerm"
        const val PATH_SEARCH_TAB = "/searchTab"
        const val PATH_TO_SHOW_NEW_BADGE = "/showNewBadge"
    }

    init {
        db.mutate { tx ->
            tx.put(PATH_SEARCH_TERM, "")
            tx.put(PATH_SEARCH_TAB, 0)
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "downloadFile" -> downloadFile(call)
            "setSuppressUploadWarning" -> setSuppressUploadWarning(call)
            "setSearchTerm" -> {
                db.mutate { tx ->
                    tx.put(PATH_SEARCH_TERM, call.argument<String>("searchTerm")!!)
                }
            }

            "setSearchTab" -> {
                db.mutate { tx ->
                    tx.put(PATH_SEARCH_TAB, call.argument<String>("searchTab")!!)
                }
            }

            "setShowNewBadge" -> {
                db.mutate { tx ->
                    tx.put(PATH_TO_SHOW_NEW_BADGE, call.argument<Boolean>("showNewBadge")!!)
                }
            }

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
