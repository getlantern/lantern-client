package io.lantern.apps

import android.Manifest
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import com.google.gson.annotations.SerializedName
import java.io.ByteArrayOutputStream
import java.util.Base64
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpClient

class AppsDataProvider(
    private val packageManager: PackageManager,
    private val thisPackageName: String
) {
    private val applicationFilterPredicate: (ApplicationInfo) -> Boolean = { appInfo ->
        hasInternetPermission(appInfo.packageName) &&
        isLaunchable(appInfo.packageName) &&
        !isSelfApplication(appInfo.packageName)
    }

    fun ByteArray.toBase64(): String = String(Base64.getEncoder().encode(this))

    // appIconDrawableToBase64 retrieves the icon associated with an application, converts it to
    // a Bitmap, and then to a Base64-encoded byte array prior to being sent to Flutter
    fun appIconDrawableToBase64(packageName:String): String {
      try {
        val icon:Drawable = packageManager.getApplicationIcon(packageName)
        val bitmap:Bitmap = Bitmap.createBitmap(icon.getIntrinsicWidth(), icon.getIntrinsicHeight(), Bitmap.Config.ARGB_8888)
        val canvas:Canvas = Canvas(bitmap)
        icon.setBounds(0, 0, canvas.getWidth(), canvas.getHeight())
        icon.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray().toBase64()
      } catch (e:Exception) {
        e.printStackTrace()
      }
      return ""
    }

    // Return a list of all application packages that are installed for the current user,
    // filtering system apps, apps that do not have Internet access, and our own
    // application
    fun listOfApps(): List<AppData> {
        return packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            .asSequence()
            .filter(applicationFilterPredicate)
            .map { info ->
                AppData(
                    info.packageName,
                    appIconDrawableToBase64(info.packageName),
                    info.loadLabel(packageManager).toString(),
                    false
                )
            }
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
