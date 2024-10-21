package io.lantern.apps

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import org.getlantern.mobilesdk.Logger
import java.io.ByteArrayOutputStream

data class AppData(
    val packageManager: PackageManager,
    val info: ApplicationInfo,
) {
    val packageName: String = info.packageName
    val name = info.loadLabel(packageManager).toString()

    val icon: ByteArray? by lazy {
        try {
            val icon: Drawable = packageManager.getApplicationIcon(packageName)
            val bitmap = drawableToBitmap(icon)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            Logger.e("AppData", "Error converting icon to byte array", e)
            e.printStackTrace()
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }


}