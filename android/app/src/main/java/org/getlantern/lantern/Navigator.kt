package org.getlantern.lantern

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.activity.DesktopActivity_
import org.getlantern.lantern.activity.InviteActivity_
import org.getlantern.lantern.activity.authorizeDevice.AccountRecoveryActivity
import org.getlantern.lantern.activity.yinbi.YinbiLauncher
import org.getlantern.mobilesdk.activity.LanguageActivity
import org.getlantern.mobilesdk.activity.ReportIssueActivity

class Navigator(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : MethodChannel.MethodCallHandler {

    companion object {
        const val SCREEN_PLANS = "SCREEN_PLANS"
        const val SCREEN_INVITE_FRIEND = "SCREEN_INVITE_FRIEND"
        const val SCREEN_DESKTOP_VERSION = "SCREEN_DESKTOP_VERSION"
        const val SCREEN_FREE_YINBI = "SCREEN_FREE_YINBI"
        const val SCREEN_YINBI_REDEMPTION = "SCREEN_YINBI_REDEMPTION"
        const val SCREEN_AUTHORIZE_DEVICE_FOR_PRO = "SCREEN_AUTHORIZE_DEVICE_FOR_PRO"
        const val SCREEN_CHANGE_LANGUAGE = "SCREEN_CHANGE_LANGUAGE"
        const val SCREEN_SCREEN_REPORT_ISSUE = "SCREEN_SCREEN_REPORT_ISSUE"
    }

    init {
        flutterEngine?.let {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "navigator_method_channel"
            ).setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startScreen" -> {
                val screenName = call.argument<String>("screenName")!!
                val activityClass = toActivityClass(screenName)
                activityClass?.let {
                    activity.startActivity(Intent(activity, activityClass))
                    result.success(true)
                } ?: result.success(false)
            }
        }
    }

    private fun toActivityClass(screenName: String): Class<*>? {
        return when (screenName) {
            SCREEN_PLANS -> LanternApp.getSession().plansActivity()
            SCREEN_INVITE_FRIEND -> InviteActivity_::class.java
            SCREEN_DESKTOP_VERSION -> DesktopActivity_::class.java
            SCREEN_FREE_YINBI -> YinbiLauncher::class.java
            SCREEN_YINBI_REDEMPTION -> YinbiLauncher::class.java
            SCREEN_AUTHORIZE_DEVICE_FOR_PRO -> AccountRecoveryActivity::class.java
            SCREEN_CHANGE_LANGUAGE -> LanguageActivity::class.java
            SCREEN_SCREEN_REPORT_ISSUE -> ReportIssueActivity::class.java
            else -> null
        }
    }
}

fun Activity.openHome() {
    startActivity(Intent(this, MainActivity::class.java)
        .apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        })
}