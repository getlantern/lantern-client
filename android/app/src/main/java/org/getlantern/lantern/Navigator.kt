package org.getlantern.lantern

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import io.lantern.isimud.model.ProtobufMessageCodec

class Navigator(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : MethodChannel.MethodCallHandler {

    companion object {
        const val ACTIVITY_PLANS = "ACTIVITY_PLANS"
    }

    init {
        flutterEngine?.let {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "navigator_method_channel",
                StandardMethodCodec(ProtobufMessageCodec())
            ).setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startActivity" -> {
                val activityName = call.argument<String>("activityName")!!
                val activityClass = toActivityClass(activityName)
                activityClass?.let {
                    activity.startActivity(Intent(activity, activityClass))
                    result.success(true)
                } ?: result.success(false)
            }
        }
    }

    private fun toActivityClass(activityName: String): Class<*>? {
        return when (activityName) {
            ACTIVITY_PLANS -> LanternApp.getSession().plansActivity()
            else -> null
        }
    }
}