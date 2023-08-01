package org.getlantern.lantern.loconf

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.model.VpnModel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.activity.WebViewActivity_
import org.getlantern.lantern.event.EventManager
import org.getlantern.mobilesdk.model.Event
import org.getlantern.mobilesdk.model.LoConf
import org.getlantern.mobilesdk.model.LoConf.Companion.fetch
import org.getlantern.mobilesdk.model.Survey
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.mobilesdk.Logger

class SurveyHelper(
    private val context: Context,
    private val flutterEngine: FlutterEngine,
    private val eventManager: EventManager,
) : MethodChannel.MethodCallHandler {

    private var lastSurvey: Survey? = null

    init {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lantern_method_channel",
        ).setMethodCallHandler(this)
    }

    private fun showSurvey(survey: Survey?) {
        survey ?: return
        val intent = Intent(context, WebViewActivity_::class.java)
        intent.putExtra("url", survey.url!!)
        context.startActivity(intent)
        LanternApp.getSession().setSurveyLinkOpened(survey.url)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "showLastSurvey" -> {
                showSurvey(lastSurvey)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

  fun processLoconf(loconf: LoConf) {
        val locale = LanternApp.getSession().language
        val countryCode = LanternApp.getSession().countryCode
        Logger.debug(
            TAG,
            "Processing loconf; country code is $countryCode",
        )
        if (loconf.surveys == null) {
            Logger.debug(TAG, "No survey config")
            return
        }
        for (key in loconf.surveys!!.keys) {
            Logger.debug(TAG, "Survey: " + loconf.surveys!![key])
        }
        var key = countryCode
        var survey = loconf.surveys!![key]
        if (survey == null) {
            key = countryCode.toLowerCase()
            survey = loconf.surveys!![key]
        }
        if (survey == null || !survey.enabled) {
            key = locale
            survey = loconf.surveys!![key]
        }
        if (survey == null) {
            Logger.debug(TAG, "No survey found")
        } else if (!survey.enabled) {
            Logger.debug(TAG, "Survey disabled")
        } else if (Math.random() > survey.probability) {
            Logger.debug(TAG, "Not showing survey this time")
        } else {
            Logger.debug(
                TAG,
                "Deciding whether to show survey for '%s' at %s",
                key,
                survey.url,
            )
            val userType = survey.userType
            if (userType != null) {
                if (userType == "free" && LanternApp.getSession().isProUser) {
                    Logger.debug(
                        TAG,
                        "Not showing messages targetted to free users to Pro users",
                    )
                    return
                } else if (userType == "pro" && !LanternApp.getSession().isProUser) {
                    Logger.debug(
                        TAG,
                        "Not showing messages targetted to free users to Pro users",
                    )
                    return
                }
            }
            showSurveySnackbar(survey)
        }
    }


    fun showSurveySnackbar(survey: Survey) {
        val url = survey.url
        if (url != null && url != "") {
            if (LanternApp.getSession().surveyLinkOpened(url)) {
                Logger.debug(
                    TAG,
                    "User already opened link to survey; not displaying snackbar",
                )
                return
            }
        }
        lastSurvey = survey
        Logger.debug(TAG, "Showing user survey snackbar")
        eventManager.onNewEvent(
            Event.SurveyAvailable,
            hashMapOf("message" to survey.message, "buttonText" to survey.button),
        )
    }

    companion object {
        private val TAG = SurveyHelper::class.java.simpleName        
    }

}