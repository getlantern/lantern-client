package org.getlantern.lantern.util

import android.app.Activity
import android.content.Intent
import androidx.core.app.ShareCompat

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
