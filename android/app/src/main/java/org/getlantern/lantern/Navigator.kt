package org.getlantern.lantern

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Process
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.activity.DesktopActivity_
import org.getlantern.lantern.activity.InviteActivity_
import org.getlantern.lantern.activity.RegisterProActivity_
import org.getlantern.lantern.activity.authorizeDevice.LinkDeviceActivity_
import org.getlantern.mobilesdk.activity.ReportIssueActivity

class Navigator(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : MethodChannel.MethodCallHandler {

    companion object {
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
            SCREEN_INVITE_FRIEND -> InviteActivity_::class.java
            SCREEN_DESKTOP_VERSION -> DesktopActivity_::class.java
            SCREEN_LINK_PIN -> LinkDeviceActivity_::class.java
            SCREEN_SCREEN_REPORT_ISSUE -> ReportIssueActivity::class.java
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
    val mPendingIntentId = 123456
    val mPendingIntent: PendingIntent = PendingIntent.getActivity(
        this,
        mPendingIntentId,
        mStartActivity,
        PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    val mgr: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
    mgr.set(AlarmManager.RTC, java.lang.System.currentTimeMillis() + 100, mPendingIntent)
    Process.killProcess(Process.myPid())
}

fun Activity.openCheckOutReseller() {
    startActivity(Intent(this, RegisterProActivity_::class.java))
}
