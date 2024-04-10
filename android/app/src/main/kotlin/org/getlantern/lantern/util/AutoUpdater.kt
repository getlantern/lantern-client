package org.getlantern.lantern.util

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Resources
import internalsdk.Internalsdk
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Utils
import org.getlantern.mobilesdk.Logger

class AutoUpdater(val context: Context, val activity: Activity? = null) {

    private var autoUpdateJob: Job? = null
    private var resources: Resources = context.resources

    private fun startUpdateActivity(updateURL: String) {
        context.startActivity(
            Intent().apply {
                component = ComponentName(
                    context.packageName,
                    "org.getlantern.lantern.activity.UpdateActivity_",
                )
                putExtra("updateUrl", updateURL)
                setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
    }

    private fun noUpdateAvailable() {
        if (activity == null) return
        activity.runOnUiThread {
            val appName = resources.getString(R.string.app_name)
            val noUpdateTitle = resources.getString(R.string.no_update_available)
            val noUpdateMsg = String.format(
                resources.getString(R.string.have_latest_version),
                appName,
                LanternApp.getSession().appVersion(),
            )
            activity.showAlertDialog(noUpdateTitle, noUpdateMsg)
        }
    }

    fun checkForUpdates() {
        if (LanternApp.getSession().isStoreVersion && activity != null) {
            Utils.openPlayStore(context)
            return
        }

        if (autoUpdateJob != null && autoUpdateJob!!.isActive) {
            Logger.d(TAG, "Already checking for updates")
            return
        }
        Logger.d(TAG, "Checking for updates")
        autoUpdateJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                val deviceInfo: internalsdk.DeviceInfo = DeviceInfo
                val updateURL = Internalsdk.checkForUpdates(deviceInfo)
                when {
                    updateURL.isEmpty() -> noUpdateAvailable()
                    else -> startUpdateActivity(updateURL)
                }
            } catch (e: Exception) {
                Logger.d(TAG, "Unable to check for update: %s", e.message)
            }
        }
        if (activity != null) runBlocking { autoUpdateJob?.let { it.join() } }
    }

    companion object {
        private val TAG = AutoUpdater::class.java.simpleName
    }
}
