package io.lantern.apps

import android.Manifest
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import java.io.ByteArrayOutputStream

class AppsDataProvider(
    private val packageManager: PackageManager,
    private val thisPackageName: String
) {
    private val applicationFilterPredicate: (ApplicationInfo) -> Boolean = { appInfo ->
        hasInternetPermission(appInfo.packageName) &&
                isLaunchable(appInfo.packageName) &&
                !isSelfApplication(appInfo.packageName)
    }

    // Return a list of all application packages that are installed for the current user,
    // filtering system apps, apps that do not have Internet access, and our own
    // application
    fun listOfApps(): List<AppData> {
        return packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            .asSequence()
            .filter(applicationFilterPredicate)
            .map { info -> AppData(packageManager, info) }
            .toList().sortedBy { it.name }
    }


    // check whether a particular package has been granted permission to open network sockets
    private fun hasInternetPermission(packageName: String): Boolean {
        return PackageManager.PERMISSION_GRANTED ==
                packageManager.checkPermission(Manifest.permission.INTERNET, packageName)
    }

    // check whether a particular package is launchable
    private fun isLaunchable(packageName: String): Boolean {
        return packageManager.getLaunchIntentForPackage(packageName) != null ||
                packageManager.getLeanbackLaunchIntentForPackage(packageName) != null
    }

    private fun isSelfApplication(packageName: String): Boolean {
        return packageName == thisPackageName
    }



    companion object {
        private val TAG = AppsDataProvider::class.java.name
    }
}
