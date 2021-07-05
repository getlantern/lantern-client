package org.getlantern.lantern.client

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine

import internalsdk.AuthClient

class AuthClient(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : MethodChannel.MethodCallHandler {
    
  companion object {
    const val AUTH_STAGING_API_ADDR = "https://auth-staging.lantern.network"
    const val AUTH_API_ADDR = "https://auth4.lantern.network"
  }

  private val authClient = AuthClient(AUTH_STAGING_API_ADDR)

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
              val lanternID = call.argument<Int>("lanternUserID")!!
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