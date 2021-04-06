package org.getlantern.lantern.util

import android.app.Activity
import android.content.DialogInterface
import android.graphics.drawable.Drawable
import android.widget.ImageView
import android.widget.TextView
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Utils
import org.getlantern.mobilesdk.Logger

@JvmOverloads
fun Activity.showAlertDialog(
    title: CharSequence?,
    msg: CharSequence?,
    icon: Drawable? = null,
    onClick: Runnable? = null,
    okLabel: CharSequence? = "OK",
    finish: Boolean = false,
) {
    if (isDestroyed) {
        return
    }
    Logger.debug(Utils::class.java.name, "Showing alert dialog...")
    runOnUiThread {
        val contentView = layoutInflater.inflate(R.layout.base_dialog, null)
        val titleTv = contentView.findViewById<TextView>(R.id.title)
        val messageTv = contentView.findViewById<TextView>(R.id.message)
        titleTv.text = title
        messageTv.text = msg
        icon?.let {
            val imageView = contentView.findViewById<ImageView>(R.id.icon)
            imageView.setImageDrawable(it)
        }
        MaterialAlertDialogBuilder(this)
            .setView(contentView)
            .setPositiveButton(okLabel) { dialog: DialogInterface, which: Int ->
                dialog.dismiss()
                onClick?.run()
                if (finish) {
                    finish()
                }
            }
            .show()
    }
}