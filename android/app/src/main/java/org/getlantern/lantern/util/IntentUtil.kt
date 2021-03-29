package org.getlantern.lantern.util

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.core.app.ShareCompat
import org.getlantern.lantern.R

object IntentUtil {
    fun Activity.sharePlainText(text: String, title: String) {
        val shareIntent = ShareCompat.IntentBuilder.from(this)
            .setType("text/plain")
            .setText(text)
            .intent
        if (shareIntent.resolveActivity(packageManager) != null) {
            startActivity(Intent.createChooser(shareIntent, title))
        }
    }
}