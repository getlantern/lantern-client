package org.getlantern.lantern.util

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Process
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Utils
import org.getlantern.mobilesdk.Logger

fun Activity.showErrorDialog(
    error: String
) {
    showAlertDialog(
        title = getString(R.string.validation_errors),
        msg = error
    )
}

fun Activity.openHome() {
    startActivity(
        Intent(this, MainActivity::class.java)
            .apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
    )
    overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
}

fun Activity.restartApp() {
    val mStartActivity = Intent(this, MainActivity::class.java)
    val mPendingIntentId = 123456
    val mPendingIntent: PendingIntent = PendingIntent.getActivity(
        this,
        mPendingIntentId,
        mStartActivity,
        PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    val mgr: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
    mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 100, mPendingIntent)
    Process.killProcess(Process.myPid())
}


@JvmOverloads
fun Activity.showAlertDialog(
    title: CharSequence? = null,
    msg: CharSequence?,
    icon: Drawable? = null,
    onClick: Runnable? = null,
    okLabel: CharSequence? = getString(R.string.ok),
    finish: Boolean = false,
    negativeLabel: CharSequence? = null
) {
    if (isDestroyed) {
        return
    }
    Logger.debug(Utils::class.java.name, "Showing alert dialog...")
    runOnUiThread {
        val contentView = layoutInflater.inflate(R.layout.base_dialog, null)
        val titleTv = contentView.findViewById<TextView>(R.id.title)
        val messageTv = contentView.findViewById<TextView>(R.id.message)
        if (title == null) {
            titleTv.visibility = View.GONE
        } else {
            titleTv.visibility = View.VISIBLE
            titleTv.text = title
        }
        messageTv.text = msg
        val imageView = contentView.findViewById<ImageView>(R.id.icon)
        if (icon != null) {
            imageView.setImageDrawable(icon)
        } else {
            imageView.visibility = View.GONE
        }
        MaterialAlertDialogBuilder(this)
            .setView(contentView)
            .setPositiveButton(okLabel) { dialog: DialogInterface, which: Int ->
                dialog.dismiss()
                onClick?.run()
                if (finish) {
                    finish()
                }
            }.apply {
                negativeLabel?.let {
                    setNegativeButton(it, null)
                }
            }
            .show()
    }
}
