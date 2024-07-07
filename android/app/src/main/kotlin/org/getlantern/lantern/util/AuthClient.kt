package org.getlantern.lantern.util

import internalsdk.Internalsdk
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger

data class LoginResponse(
    val legacyID: Long = 0,
    val legacyToken: String = "",
    val id: String = "",
) : APIResponse()

object AuthClient {
    private val authClient = Internalsdk.newAuthClient(LanternApp.getSession())

    fun signIn(
        email: String,
        password: String,
        callback: ((resp: LoginResponse) -> Unit)? = null,
    ) {
        try {
            val response: LoginResponse? = JsonUtil.fromJson<LoginResponse>(authClient.login(email, password))
            response?.let {
                callback?.invoke(it)
            }
        } catch (e: Exception) {
            Logger.debug("AuthClient", "Error is ${e.message}")
            val resp = LoginResponse()
            resp.error = e.message
            callback?.invoke(resp)
        }
    }

    fun signUp(
        email: String,
        password: String,
        callback: ((resp: LoginResponse) -> Unit)? = null,
    ) {
        val response: LoginResponse? = JsonUtil.fromJson<LoginResponse>(authClient.signUp(email, password))
        response?.let {
            callback?.invoke(it)
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
