package org.getlantern.lantern.util

import kotlinx.serialization.Serializable
import internalsdk.Internalsdk
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger

@Serializable
data class LoginResponse(
    val legacyID: Long = 0,
    val legacyToken: String = "",
    val id: String = "",
) : APIResponse()

typealias AuthCallback = (resp: LoginResponse) -> Unit

object AuthClient {
    private val authClient = Internalsdk.newAuthClient(LanternApp.getSession())
    private const val TAG = "AuthClient"

    private fun onAuthError(callback:AuthCallback?, e: Exception) {
        val resp = LoginResponse()
        resp.error = e.message
        callback?.invoke(resp)
        Logger.debug(TAG, "Auth error: ${e.message}")
    }

    fun signIn(
        email: String,
        password: String,
        callback: AuthCallback? = null,
    ) {
        try {
            val response: LoginResponse? = JsonUtil.fromJson<LoginResponse>(authClient.login(email, password))
            response?.let {
                callback?.invoke(it)
            }
        } catch (e: Exception) {
            onAuthError(callback, e)
        }
    }

    fun signUp(
        email: String,
        password: String,
        callback: AuthCallback? = null,
    ) {
        try {
            val response: LoginResponse? = JsonUtil.fromJson<LoginResponse>(authClient.signUp(email, password))
            response?.let {
                callback?.invoke(it)
            }
        } catch (e: Exception) {
            onAuthError(callback, e)
        }
    }

    fun signOut() {
        authClient.signOut()
    }

    fun startRecoveryByEmail(
        email: String,
        callback: ((resp: APIResponse) -> Unit)? = null,
    ) {
        val response: APIResponse? = JsonUtil.fromJson<APIResponse>(authClient.startRecoveryByEmail(email))
        response?.let {
            callback?.invoke(it)
        }
    }
}
