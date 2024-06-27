package org.getlantern.lantern.util

import internalsdk.Internalsdk
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.ProUser
import org.getlantern.mobilesdk.Logger

object ProClient {
    private val proClient = Internalsdk.newProClient(LanternApp.getSession())
    private val session = LanternApp.getSession()
    private const val TAG = "ProClient"

    fun updateUserData() {
        val userData = proClient.userData()
        val proUser: ProUser? = JsonUtil.fromJson<ProUser>(userData)
        proUser?.let { session.storeUserData(it) }
    }
}