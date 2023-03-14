package org.getlantern.lantern.util

import android.content.Context

object SystemInfoHelper {

  fun model(): String {
    return android.os.Build.MODEL ?: ""
  }

  fun hardware(): String {
      return android.os.Build.HARDWARE ?: ""
  }

  fun sdkVersion(): Int {
    return android.os.Build.VERSION.SDK_INT
  }
}