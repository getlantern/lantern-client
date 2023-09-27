package org.getlantern.lantern.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import com.google.gson.JsonObject
import okhttp3.HttpUrl
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.datadog.Datadog
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternHttpClient.ProCallback
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.LanternStatus.Status
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.notification.Notifications
import org.getlantern.lantern.util.Json
import org.getlantern.mobilesdk.Lantern
import org.getlantern.mobilesdk.LanternNotRunningException
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.StartResult
import org.getlantern.mobilesdk.model.LoConf
import org.getlantern.mobilesdk.model.LoConfCallback
import org.greenrobot.eventbus.EventBus

class LanternService : Service(), ServiceManager.Runner {

    companion object {
        private val TAG = LanternService::class.java.simpleName
        private val lanternClient: LanternHttpClient = LanternApp.getLanternHttpClient()
    }

    inner class LocalBinder : Binder() {
        val service
            get() = this@LanternService
    }

    override val data = ServiceManager.Data(this)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int =
        super<ServiceManager.Runner>.onStartCommand(intent, flags, startId)

    override suspend fun startProcesses() {
        val locale = LanternApp.getSession().language
        val settings = LanternApp.getSession().settings

        try {
            if (Build.VERSION.SDK_INT >= 26) serviceNotification()
            Logger.debug(TAG, "Successfully loaded config: $settings")
            val result: StartResult =
                Lantern.enable(this, locale, settings, LanternApp.getSession())
            LanternApp.getSession().setStartResult(result)
            // create a user if no user id is stored
            if (LanternApp.getSession().userId().toInt() == 0) createUser()
            EventBus.getDefault().postSticky(LanternStatus(Status.ON))
            // fetch latest loconf
            LoConf.Companion.fetch(object : LoConfCallback {
                override fun onSuccess(loconf: LoConf) {
                    EventBus.getDefault().post(loconf)
                }
            })

            Datadog.initialize()

            if (!BuildConfig.PLAY_VERSION && !BuildConfig.DEVELOPMENT_MODE) {
                // check if an update is available
                autoUpdater.checkForUpdates()
            }
        } catch (lnre: LanternNotRunningException) {
            Logger.e(TAG, "Unable to start LanternService", lnre)
        }
    }

    suspend fun createUser() {
        EventBus.getDefault().post(
            AccountInitializationStatus(AccountInitializationStatus.Status.PROCESSING),
        )
        val url: HttpUrl = LanternHttpClient.createProUrl("/user-create")
        val json: JsonObject = JsonObject()
        json.addProperty("locale", LanternApp.getSession().language)
        lanternClient.post(
            url,
            LanternHttpClient.createJsonBody(json),
            object : ProCallback {
                override fun onFailure(throwable: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Unable to fetch user data: $error", throwable)
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    val user: ProUser? = Json.gson.fromJson(result, ProUser::class.java)
                    if (user == null) {
                        Logger.error(TAG, "Unable to parse user from JSON")
                        return
                    }
                    Logger.debug(TAG, "Created new Lantern user: ${user.newUserDetails()}")
                    LanternApp.getSession().setUserIdAndToken(
                        user.getUserId(),
                        user.getToken(),
                    )
                    val referral = user.getReferral()
                    if (!referral.isEmpty()) {
                        LanternApp.getSession().setCode(referral)
                    }
                    EventBus.getDefault().postSticky(LanternStatus(Status.ON))
                    EventBus.getDefault().postSticky(
                        AccountInitializationStatus(
                            AccountInitializationStatus.Status.SUCCESS,
                        ),
                    )
                }
            },
        )
    }

    override fun onBind(intent: Intent): IBinder? = null

    override fun killProcesses() {
        Logger.d(TAG, "stop")
        stopForeground(true)
    }

    private fun serviceNotification() = startForeground(
        1,
        Notifications.serviceBuilder(this).build(),
    )
}
