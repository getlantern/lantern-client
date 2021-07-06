package org.getlantern.lantern.client

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.mobilesdk.Logger
import org.getlantern.lantern.*

import internalsdk.Internalsdk
import internalsdk.AuthClient
import internalsdk.AuthResponse

class AuthClient(
    private val activity: Activity
) {
    
    companion object {
      private const val AUTH_STAGING_API_ADDR = "https://auth-staging.lantern.network"
      private const val AUTH_API_ADDR = "https://auth4.lantern.network"

      private const val PATH_USERNAME = "/username"

      private const val TAG = "AuthClient"

    }

    private val authClient:AuthClient = Internalsdk.newAuthClient(AUTH_STAGING_API_ADDR)


    fun createAccount(password: String):AuthResponse {
        val lanternID = LanternApp.getSession().userID
        val username = LanternApp.getSession().username()
        Logger.debug(TAG, "Received new create account request from $username")
        return authClient.register(lanternID, username, password)
    }

    fun signIn(username:String, password: String):AuthResponse {
        val username = LanternApp.getSession().username()
        Logger.debug(TAG, "Received new sign in request from $username")
        return authClient.signIn(username, password)
    }

}