package org.getlantern.mobilesdk.util

import android.content.Context
import org.getlantern.lantern.R

/**
 * Gets the string identified by a given id and replaces the first substitution parameter %1$s with
 * the value or R.string.app_name.
 */
fun Context.getStringWithAppName(id: Int): String? {
    val res = resources
    val str = res.getString(id)
    val appName = res.getString(R.string.app_name)
    return String.format(str, appName)
}