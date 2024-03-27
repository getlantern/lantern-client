package org.getlantern.lantern.util

import android.app.Activity
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageInstaller
import android.content.pm.PackageInstaller.SessionParams
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import internalsdk.Internalsdk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.getlantern.mobilesdk.Logger
import java.io.File
import java.io.IOException

// ApkInstaller is a utility class for installing APKs
class ApkInstaller(
    private val activity: Activity,
    private val apkFile: File,
    private val context: Context = activity,
    private val packageManager: PackageManager = context.packageManager,
    private val packageInstaller: PackageInstaller = packageManager.packageInstaller,
) {
    private val callback: SessionCallback = SessionCallback(activity)

    init {
        packageInstaller.registerSessionCallback(callback)
    }

    fun unregisterCallback() {
        packageInstaller.unregisterSessionCallback(callback)
    }

    suspend fun execute() {
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                installWithPackageInstaller()
            }

            Build.VERSION.SDK_INT >= Build.VERSION_CODES.N -> {
                createInstallIntentContentUri()?.let(this::launchInstaller)
            }

            else -> {
                createInstallIntentFileUri()?.let(this::launchInstaller)
            }
        }
    }

    // installWithPackageInstaller uses PackageInstaller to install an update of Lantern on a device
    private suspend fun installWithPackageInstaller() =
        withContext(Dispatchers.IO) {
            try {
                val params = SessionParams(SessionParams.MODE_FULL_INSTALL)
                // create a new session using the given params, returning a unique ID that represents the session
                val sessionId = packageInstaller.createSession(params)
                // open an existing session to actively perform work
                packageInstaller.openSession(sessionId).use { session ->
                    try {
                        session.openWrite("apk", 0, apkFile.length())
                            .use { outputStream ->
                                apkFile.inputStream().use { inputStream ->
                                    inputStream.copyTo(outputStream)
                                }
                                session.fsync(outputStream)
                            }
                        // attempt to commit everything staged in this session
                        session.commit(createIntentSender(sessionId))
                        Logger.debug(TAG, "session committed")
                    } catch (e: RuntimeException) {
                        Logger.error(TAG, "Failed to install apk", e)
                        session.abandon()
                    }
                }
            } catch (e: IOException) {
                Logger.error(TAG, "Failed to create PackageInstaller session", e)
            } catch (e: SecurityException) {
                Logger.error(TAG, "Failed to create PackageInstaller session", e)
            }
        }

    private fun createIntentSender(sessionId: Int): IntentSender {
        val broadcastIntent = Intent(PACKAGE_INSTALLED_ACTION)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_MUTABLE
        } else {
            0
        }
        // Retrieve a PendingIntent that will perform a broadcast when an install finishes
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            sessionId,
            broadcastIntent,
            flags
        )
        return pendingIntent.intentSender
    }

    private fun launchInstaller(intent: Intent) = try {
        context.startActivity(intent)
    } catch (e: ActivityNotFoundException) {
        Logger.error(TAG, "Failed to launch apk installer", e)
    }

    private fun createInstallIntentContentUri(): Intent {
        val packageName = context.packageName
        val authority = "$packageName.fileProvider"
        val apkFileUri = FileProvider.getUriForFile(context, authority, apkFile)
        return Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            data = apkFileUri
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }

    private suspend fun createInstallIntentFileUri(): Intent? =
        withContext(Dispatchers.IO) {
            val externalApkFile =
                File(context.getExternalFilesDir(null), "apk").resolve(apkFile.name)
            if (!externalApkFile.exists()) {
                try {
                    apkFile.copyTo(externalApkFile)
                } catch (e: IOException) {
                    Logger.error(TAG, "Failed to copy apk file", e)
                    return@withContext null
                }
            }

            Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
                setDataAndType(
                    Uri.fromFile(externalApkFile),
                    "application/vnd.android.package-archive"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
        }

    // SessionCallback is used to observe events of a Session lifecycle
    private class SessionCallback(private val activity: Activity) :
        PackageInstaller.SessionCallback() {
        override fun onCreated(sessionId: Int) {
            Logger.debug(TAG, "onCreated: sessionId=$sessionId")
        }

        override fun onBadgingChanged(sessionId: Int) {
            Logger.debug(TAG, "onBadgingChanged")
        }

        override fun onActiveChanged(sessionId: Int, active: Boolean) {
            Logger.debug(TAG, "onActiveChanged: sessionId=$sessionId, active=$active")
        }

        override fun onProgressChanged(sessionId: Int, progress: Float) {
            Logger.debug(TAG, "onProgressChanged: sessionId=$sessionId, progress=$progress")
        }

        // onFinished is called when an installer commits or abandons the session, resulting in the session
        // being finished.
        override fun onFinished(sessionId: Int, success: Boolean) {
            Logger.debug(TAG, "onFinished: sessionId=$sessionId, success=$success")
            Logger.debug(TAG, "App install result " + success)
            Internalsdk.installFinished(DeviceInfo, success)
            activity.finish()
        }
    }

    companion object {
        private const val TAG = "ApkInstaller"
        private const val PACKAGE_INSTALLED_ACTION =
            "org.getlantern.lantern.SESSION_API_PACKAGE_INSTALLED"
    }
}