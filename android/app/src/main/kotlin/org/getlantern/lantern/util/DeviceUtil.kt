package org.getlantern.lantern.util

import android.app.Activity
import android.content.Context
import android.os.Build
import android.provider.Settings
import io.lantern.model.SessionModel
import org.getlantern.lantern.BuildConfig
import org.getlantern.mobilesdk.Logger

object DeviceUtil {

    fun devicePlatform(): String {
        return "Android"
    }
    fun deviceId(context:Context): String? {
       return  Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
    }

    fun deviceOs():String{
       return String.format("Android-%s", Build.VERSION.RELEASE)
    }
    fun model(): String {
        return android.os.Build.MODEL ?: ""
    }

    fun hardware(): String {
        return android.os.Build.HARDWARE ?: ""
    }

    fun sdkVersion(): Long {
        return android.os.Build.VERSION.SDK_INT.toLong()
    }


    fun isStoreVersion(activity: Activity): Boolean {
        try {
            val validInstallers: List<String> = ArrayList(
                listOf(
                    "com.android.vending",
                    "com.google.android.feedback"
                )
            )
            val installer = activity.packageManager
                .getInstallerPackageName(activity.packageName)
            return installer != null && validInstallers.contains(installer)
        } catch (e: java.lang.Exception) {
            Logger.error(SessionModel.TAG, "Error fetching package information: " + e.message)
        }
        return false
    }


}