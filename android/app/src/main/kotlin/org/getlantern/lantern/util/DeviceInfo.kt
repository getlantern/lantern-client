package org.getlantern.lantern.util

import org.getlantern.lantern.LanternApp

object DeviceInfo : internalsdk.DeviceInfo {

    override fun model(): String {
        return android.os.Build.MODEL ?: ""
    }

    override fun hardware(): String {
        return android.os.Build.HARDWARE ?: ""
    }

    override fun sdkVersion(): Long {
        return android.os.Build.VERSION.SDK_INT.toLong()
    }

    override fun deviceID(): String {
        return LanternApp.getSession().deviceID() ?: ""
    }

    override fun userID(): String {
        return LanternApp.getSession().userID().toString()
    }
}