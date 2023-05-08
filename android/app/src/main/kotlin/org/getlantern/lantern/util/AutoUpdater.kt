package org.getlantern.lantern.util

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.content.ComponentName
import android.content.Intent
import androidx.lifecycle.lifecycleScope
import internalsdk.Internalsdk
import kotlinx.coroutines.*
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.R
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.mobilesdk.Logger

class AutoUpdater(val context:Context, val activity:Activity?) {

	private var autoUpdateJob: Job? = null
	private var resources: Resources = context.resources

    private fun startUpdateActivity(updateURL:String) {
        val intent = Intent()
        intent.component = ComponentName(
            context.packageName,
            "org.getlantern.lantern.activity.UpdateActivity_",
        )
        intent.putExtra("updateUrl", updateURL)
        context.startActivity(intent)
    }

    private fun noUpdateAvailable() {
        if (activity == null) return
        GlobalScope.launch {
        	withContext(Dispatchers.Main) {
	            val appName = resources.getString(R.string.app_name)
	            val noUpdateTitle = resources.getString(R.string.no_update_available)
	            val noUpdateMsg = String.format(resources.getString(R.string.have_latest_version), appName, LanternApp.getSession().appVersion())
	            activity.showAlertDialog(noUpdateTitle, noUpdateMsg)
	        }
	    }
    }


	fun checkForUpdates() {
	    if (LanternApp.getSession().isPlayVersion && activity != null) {
	        Utils.openPlayStore(context)
	        return
	    }

	    if (autoUpdateJob != null && autoUpdateJob!!.isActive) {
            Logger.d(TAG, "Already checking for updates")
            return
        }
        autoUpdateJob = GlobalScope.launch(Dispatchers.IO) {
            try {
              val deviceInfo:internalsdk.DeviceInfo = DeviceInfo
              val updateURL = Internalsdk.checkForUpdates(deviceInfo)
              when {
                updateURL.isEmpty() -> noUpdateAvailable()
                else -> startUpdateActivity(updateURL)
              }
            } catch (e:Exception) {
              Logger.d(TAG, "Unable to check for update: %s", e.message)
            }
        }
        if (activity != null) runBlocking { autoUpdateJob?.let { it.join() } }
	}

    companion object {
        private val TAG = AutoUpdater::class.java.simpleName
    }

}
