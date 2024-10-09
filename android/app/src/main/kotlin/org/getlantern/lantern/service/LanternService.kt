package org.getlantern.lantern.service


import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.annotation.Nullable
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.event.EventHandler
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.LanternStatus.Status
import org.getlantern.lantern.util.AutoUpdater
import org.getlantern.mobilesdk.Lantern
import org.getlantern.mobilesdk.LanternNotRunningException
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.StartResult
import java.util.Random
import java.util.concurrent.atomic.AtomicBoolean

open class LanternService : Service(), Runnable {

    companion object {
        private val TAG = LanternService::class.java.simpleName
        private const val MAX_CREATE_USER_TRIES = 11
        private const val baseWaitMs = 3000

        val AUTO_BOOTED = "autoBooted"
    }

    private val random: Random = Random()
    private val serviceIcon: Int = if (LanternApp.session.chatEnabled()) {
        R.drawable.status_chat
    } else {
        R.drawable.status_plain
    }
    private val helper: ServiceHelper = ServiceHelper(this, serviceIcon, R.string.ready_to_connect)
    private val started: AtomicBoolean = AtomicBoolean()
    private lateinit var autoUpdater: AutoUpdater

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_NOT_STICKY
        autoUpdater = AutoUpdater(this)
        val autoBooted = intent.getBooleanExtra(AUTO_BOOTED, false)
        Logger.d(TAG, "Called onStartCommand, autoBooted?: $autoBooted")
        if (autoBooted) {
            Logger.debug(
                TAG,
                "Attempted to auto boot but user has not onboarded to messaging, stop LanternService",
            )
            stopSelf()
            return START_NOT_STICKY
        }
        if (started.compareAndSet(false, true)) {
            Logger.d(TAG, "Starting Lantern service thread")
            thread = Thread(this, "LanternService")
            thread?.start()
        }

        return super.onStartCommand(intent, flags, startId)
    }

    @Nullable
    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun run() {
        // move the current thread of the service to the background
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND)
        val locale = LanternApp.session.language
        val settings = LanternApp.session.settings
        try {
            Logger.debug(TAG, "Successfully loaded config: $settings")
            val result: StartResult =
                Lantern.enable(this, locale, settings, LanternApp.getGoSession())
            LanternApp.session.setStartResult(result)
            afterStart()
        } catch (lnre: LanternNotRunningException) {
            Logger.e(TAG, "Unable to start LanternService", lnre)
            throw RuntimeException("Could not start Lantern", lnre)
        }
    }

    private fun afterStart() {
        if (LanternApp.session.userId().toInt() == 0) {
            // create a user if no user id is stored
            EventHandler.postAccountInitializationStatus(AccountInitializationStatus.Status.PROCESSING)
        }
        if (!BuildConfig.PLAY_VERSION && !BuildConfig.DEVELOPMENT_MODE) {
            // check if an update is available
            autoUpdater.checkForUpdates(null)
        }
        EventHandler.postStatusEvent(LanternStatus(Status.ON))
    }

    override fun onDestroy() {
        super.onDestroy()
        if (!started.get()) {
            Logger.debug(TAG, "Service never started, exit immediately")
            return
        }
        helper.onDestroy()
        thread?.interrupt()
        // We want to keep the service running as much as possible to allow receiving messages, so
        // we start it back up automatically as explained at https://stackoverflow.com/a/52258125.
        val broadcastIntent = Intent()
            .setAction("restartservice")
            .setClass(this, AutoStarter::class.java)
        sendBroadcast(broadcastIntent)
    }
}

