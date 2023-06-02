package io.lantern.apps

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
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
            val bitmap: Bitmap = Bitmap.createBitmap(
                icon.intrinsicWidth,
                icon.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas: Canvas = Canvas(bitmap)
            icon.setBounds(0, 0, canvas.width, canvas.height)
            icon.draw(canvas)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}