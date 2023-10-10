package org.getlantern.lantern.service

import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.annotation.Nullable
import com.google.gson.JsonObject
import okhttp3.HttpUrl
import okhttp3.Response
import org.androidannotations.annotations.EService
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.LanternStatus.Status
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.util.AutoUpdater
import org.getlantern.lantern.util.Json
import org.getlantern.mobilesdk.Lantern
import org.getlantern.mobilesdk.LanternNotRunningException
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.StartResult
import org.getlantern.mobilesdk.model.LoConf
import org.getlantern.mobilesdk.model.LoConfCallback
import org.greenrobot.eventbus.EventBus
import java.util.Random
import java.util.concurrent.atomic.AtomicBoolean

@EService
open class LanternService : Service(), Runnable {

    companion object {
        private val TAG = LanternService::class.java.simpleName
        private const val MAX_CREATE_USER_TRIES = 11
        private const val baseWaitMs = 3000
        private val lanternClient: LanternHttpClient = LanternApp.getLanternHttpClient()
        public val AUTO_BOOTED = "autoBooted"
    }

    private var thread: Thread? = null
    private val createUserHandler: Handler = Handler(Looper.getMainLooper())
    private val createUserRunnable: CreateUser = CreateUser(this)
    private val random: Random = Random()
    private val serviceIcon: Int = if (LanternApp.getSession().chatEnabled()) {
        R.drawable.status_chat
    } else {
        R.drawable.status_plain
    }
    private val helper: ServiceHelper = ServiceHelper(this, serviceIcon, R.string.ready_to_connect)
    private val started: AtomicBoolean = AtomicBoolean()
    private lateinit var autoUpdater: AutoUpdater

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
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
            EventBus.getDefault().post(
                AccountInitializationStatus(AccountInitializationStatus.Status.PROCESSING),
            )
            createUser(0)
        }

        if (!BuildConfig.PLAY_VERSION && !BuildConfig.DEVELOPMENT_MODE) {
            // check if an update is available
            autoUpdater.checkForUpdates()
        }

        EventBus.getDefault().postSticky(LanternStatus(Status.ON))

        // fetch latest loconf
        LoConf.Companion.fetch(object : LoConfCallback {
            override fun onSuccess(loconf: LoConf) {
                EventBus.getDefault().post(loconf)
            }
        })
    }

    private fun createUser(attempt: Int) {
        val maxBackOffTime = 60000L // maximum backoff time in milliseconds (e.g., 1 minute)
        val timeOut =
            (baseWaitMs * Math.pow(2.0, attempt.toDouble())).toLong().coerceAtMost(maxBackOffTime)
        createUserHandler.postDelayed(createUserRunnable, timeOut)
    }

    private class CreateUser(val service: LanternService) : Runnable,
        LanternHttpClient.ProCallback {

        private var attempts: Int = 0

        override fun run() {
            val url: HttpUrl = LanternHttpClient.createProUrl("/user-create")
            val json: JsonObject = JsonObject()
            json.addProperty("locale", LanternApp.getSession().language)
            lanternClient.post(url, LanternHttpClient.createJsonBody(json), this)
        }

        override fun onFailure(@Nullable throwable: Throwable?, @Nullable error: ProError?) {
            if (attempts >= MAX_CREATE_USER_TRIES) {
                Logger.error(TAG, "Max. number of tries made to create Pro user")
                EventBus.getDefault().postSticky(
                    AccountInitializationStatus(AccountInitializationStatus.Status.FAILURE),
                )
                return
            }
            attempts++
            service.createUser(attempts)
        }

        override fun onSuccess(response: Response, result: JsonObject) {
            val user: ProUser? = Json.gson.fromJson(result, ProUser::class.java)
            if (user == null) {
                Logger.error(TAG, "Unable to parse user from JSON")
                return
            }
            service.createUserHandler.removeCallbacks(service.createUserRunnable)
            Logger.debug(TAG, "Created new Lantern user: ${user.newUserDetails()}")
            LanternApp.getSession().setUserIdAndToken(user.getUserId(), user.getToken())
            val referral = user.getReferral()
            if (!referral.isEmpty()) {
                LanternApp.getSession().setCode(referral)
            }
            EventBus.getDefault().postSticky(LanternStatus(Status.ON))
            EventBus.getDefault().postSticky(
                AccountInitializationStatus(AccountInitializationStatus.Status.SUCCESS),
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (!started.get()) {
            Logger.debug(TAG, "Service never started, exit immediately")
            return
        }
        helper.onDestroy()
        thread?.interrupt()
        try {
            Logger.debug(TAG, "Unregistering screen state receiver")
            createUserHandler.removeCallbacks(createUserRunnable)
        } catch (e: Exception) {
            Logger.error(TAG, "Exception", e)
        }
        // We want to keep the service running as much as possible to allow receiving messages, so
        // we start it back up automatically as explained at https://stackoverflow.com/a/52258125.
        val broadcastIntent = Intent()
            .setAction("restartservice")
            .setClass(this, AutoStarter::class.java)
        sendBroadcast(broadcastIntent)
    }
}
