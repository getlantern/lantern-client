package io.lantern.android.model

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.*

import internalsdk.AuthClient

class AuthModel(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : BaseModel("auth", flutterEngine, LanternApp.getSession().db) {
    
  companion object {
    private const val AUTH_STAGING_API_ADDR = "https://auth-staging.lantern.network"
    private const val AUTH_API_ADDR = "https://auth4.lantern.network"
    private const val TAG = "AuthModel"
  }

  private val authClient = NewAuthClient(AUTH_STAGING_API_ADDR)

  init {
      flutterEngine?.let {
          MethodChannel(
              flutterEngine.dartExecutor.binaryMessenger,
              "auth_method_channel"
          ).setMethodCallHandler(this)
      }
  }

   override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
      when (call.method) {
         "register" -> {
              val lanternID = call.argument<Int>("lanternUserID") ?: 0
              val username = call.argument<String>("username")!!
              val password = call.argument<String>("password")!!
              val resp = authClient.Register(lanternID, username, password)
              resp?.let {
                result.success(true)
                } ?: result.success(false)
          }
          "signIn" -> {
              val username = call.argument<String>("username")!!
              val password = call.argument<String>("password")!!
              val resp = authClient.SignIn(username, password)
              resp?.let {
                result.success(true)
                } ?: result.success(false)
          }
      }
  }

}