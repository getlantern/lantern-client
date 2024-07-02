package org.getlantern.lantern.util

import internalsdk.Internalsdk
import org.getlantern.lantern.LanternApp

object AuthClient {
    private val authClient = Internalsdk.newAuthClient(LanternApp.getSession())

    fun signIn(
        email: String,
        password: String,
        callback: ((resp: APIResponse) -> Unit)? = null,
    ) {
        val response: APIResponse? = JsonUtil.fromJson<APIResponse>(authClient.login(email, password))
        response?.let {
            callback?.invoke(it)
        }
    }

    fun signUp(
        email: String,
        password: String,
        callback: ((resp: APIResponse) -> Unit)? = null,
    ) {
        val response: APIResponse? = JsonUtil.fromJson<APIResponse>(authClient.signUp(email, password))
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
