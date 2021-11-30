package org.getlantern.lantern

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.activity.DesktopActivity_
import org.getlantern.lantern.activity.InviteActivity_
import org.getlantern.lantern.activity.PlansActivity_
import org.getlantern.lantern.activity.RegisterProActivity_
import org.getlantern.lantern.activity.authorizeDevice.LinkDeviceActivity_
import org.getlantern.mobilesdk.activity.ReportIssueActivity

class Navigator(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : MethodChannel.MethodCallHandler {

    companion object {
        const val SCREEN_PLANS = "SCREEN_PLANS"
        const val SCREEN_INVITE_FRIEND = "SCREEN_INVITE_FRIEND"
        const val SCREEN_DESKTOP_VERSION = "SCREEN_DESKTOP_VERSION"
        const val SCREEN_LINK_PIN = "SCREEN_LINK_PIN"
        const val SCREEN_SCREEN_REPORT_ISSUE = "SCREEN_SCREEN_REPORT_ISSUE"
        const val SCREEN_UPGRADE_TO_LANTERN_PRO = "SCREEN_UPGRADE_TO_LANTERN_PRO"
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
            SCREEN_LINK_PIN -> LinkDeviceActivity_::class.java
            SCREEN_SCREEN_REPORT_ISSUE -> ReportIssueActivity::class.java
            SCREEN_UPGRADE_TO_LANTERN_PRO -> PlansActivity_::class.java
            else -> null
        }
    }
}

fun Activity.openHome() {
    startActivity(
        Intent(this, MainActivity::class.java)
            .apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
    )
    overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
}

fun Activity.restartApp() {
    val mStartActivity = Intent(this, MainActivity::class.java)
    val mainIntent = Intent.makeRestartActivityTask(mStartActivity.component)
    startActivity(mainIntent)
    Runtime.getRuntime().exit(0) // see https://stackoverflow.com/a/46848226
}

fun Activity.openCheckOutReseller() {
    startActivity(Intent(this, RegisterProActivity_::class.java))
}
