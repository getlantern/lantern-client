package org.getlantern.lantern.apps

import android.Manifest
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager

class AppsProvider(
    private val packageManager: PackageManager,
    private val thisPackageName: String
) {
    private val applicationFilterPredicate: (ApplicationInfo) -> Boolean = { appInfo ->
        hasInternetPermission(appInfo.packageName) &&
            !isSelfApplication(appInfo.packageName)
    }

    fun getAppsList(): List<AppData> {
        return packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            .asSequence()
            .filter(applicationFilterPredicate)
            .map { info ->
                AppData(
                    info.packageName,
                    info.icon,
                    info.loadLabel(packageManager).toString(),
                    !isLaunchable(info.packageName)
                )
            }
            .toList()
    }


    fun printAppsList() {
      val appsList = getAppsList()
      println("== APPS LIST ==")
      appsList.forEach(::println)
    }

    private fun hasInternetPermission(packageName: String): Boolean {
        return PackageManager.PERMISSION_GRANTED ==
            packageManager.checkPermission(Manifest.permission.INTERNET, packageName)
    }

    private fun isLaunchable(packageName: String): Boolean {
        return packageManager.getLaunchIntentForPackage(packageName) != null ||
            packageManager.getLeanbackLaunchIntentForPackage(packageName) != null
    }

    private fun isSelfApplication(packageName: String): Boolean {
        return packageName == thisPackageName
    }
}
