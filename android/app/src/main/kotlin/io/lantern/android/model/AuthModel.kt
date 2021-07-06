package io.lantern.android.model

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.mobilesdk.Logger
import org.getlantern.lantern.client.AuthClient
import org.getlantern.lantern.*

class AuthModel(
    private val activity: Activity,
    flutterEngine: FlutterEngine? = null
) : BaseModel("auth", flutterEngine, LanternApp.getSession().db) {
    
    companion object {

      private const val PATH_USERNAME = "/username"

      private const val TAG = "AuthModel"
    }

    private val authClient = AuthClient(activity)

    init {
        flutterEngine?.let {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "auth_method_channel"
            ).setMethodCallHandler(this)
        }
        db.mutate { tx ->
            // initialize username for fresh install
            tx.put(PATH_USERNAME, tx.get<String>(PATH_USERNAME) ?: "")
        }
        Logger.debug(TAG, "Created auth model")

    }

    private fun username(): String {
        return db.get(PATH_USERNAME) ?: ""
    }

    private fun setUsername(username: String) {
        db.mutate { tx ->
            tx.put(PATH_USERNAME, username)
        }
        LanternApp.getSession().setUsername(username)
    }

    private fun createAccount(password: String, result: MethodChannel.Result) {
        val lanternID = LanternApp.getSession().userID
        val username = LanternApp.getSession().username()
        Logger.debug(TAG, "Received new create account request from $username")
        val resp = authClient.createAccount(password)
        resp?.let {
          result.success(true)
        } ?: result.success(false)
    }

    private fun signIn(username:String, password: String, result: MethodChannel.Result) {
        Logger.debug(TAG, "Received new sign in request from $username")
        val resp = authClient.signIn(username, password)
        resp?.let {
          result.success(true)
          } ?: result.success(false)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        return when (call.method) {
            "createAccount" -> createAccount(call.argument("password")!!, result)
            "setUsername" -> setUsername(call.argument("username")!!)
            "signIn" -> signIn(call.argument<String>("username")!!, call.argument<String>("password")!!, result)
            else -> super.onMethodCall(call, result)
        }
  }

}