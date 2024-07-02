package org.getlantern.lantern.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.annotation.Nullable
import org.androidannotations.annotations.EService
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.event.EventHandler
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.util.AutoUpdater
import org.getlantern.lantern.util.ProClient
import org.getlantern.mobilesdk.Lantern
import org.getlantern.mobilesdk.LanternNotRunningException
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.StartResult
import org.getlantern.mobilesdk.model.LoConf
import org.getlantern.mobilesdk.model.LoConfCallback
import java.util.Random
import java.util.concurrent.atomic.AtomicBoolean

@EService
open class LanternService :
    Service(),
    Runnable {
    companion object {
        private val TAG = LanternService::class.java.simpleName
        private const val MAX_CREATE_USER_TRIES = 11
        private const val baseWaitMs = 3000
        val AUTO_BOOTED = "autoBooted"
    }

    private var thread: Thread? = null

    private val random: Random = Random()
    private val serviceIcon: Int =
        if (LanternApp.getSession().chatEnabled()) {
            R.drawable.status_chat
        } else {
            R.drawable.status_plain
        }
    private val helper: ServiceHelper = ServiceHelper(this, serviceIcon, R.string.ready_to_connect)
    private val started: AtomicBoolean = AtomicBoolean()
    private lateinit var autoUpdater: AutoUpdater

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
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
    override fun onBind(intent: Intent): IBinder? = null

    override fun run() {
        // move the current thread of the service to the background
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND)

        val locale = LanternApp.getSession().language
        val settings = LanternApp.getSession().settings

        try {
            Logger.debug(TAG, "Successfully loaded config: $settings")
            val result: StartResult =
                Lantern.enable(this, locale, settings, LanternApp.getSession())
            LanternApp.getSession().setStartResult(result)
            afterStart()
        } catch (lnre: LanternNotRunningException) {
            Logger.e(TAG, "Unable to start LanternService", lnre)
            throw RuntimeException("Could not start Lantern", lnre)
        }
    }

    private fun afterStart() {
        if (LanternApp.getSession().userId().toInt() == 0) {
            // create a user if no user id is stored
            EventHandler.postAccountInitializationStatus(AccountInitializationStatus.Status.PROCESSING)
            ProClient.createUser()
        }

        if (!BuildConfig.PLAY_VERSION && !BuildConfig.DEVELOPMENT_MODE) {
            // check if an update is available
            autoUpdater.checkForUpdates()
        }
        EventHandler.postStatusEvent(LanternStatus.On)

        // fetch latest loconf
        LoConf.Companion.fetch(
            object : LoConfCallback {
                override fun onSuccess(loconf: LoConf) {
                    EventHandler.postLoConfEvent(loconf)
                }
            },
        )
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
        val broadcastIntent =
            Intent()
                .setAction("restartservice")
                .setClass(this, AutoStarter::class.java)
        sendBroadcast(broadcastIntent)
    }
}
