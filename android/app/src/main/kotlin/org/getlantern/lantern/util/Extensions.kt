package org.getlantern.lantern.util

import org.getlantern.lantern.BuildConfig

inline fun debugOnly(block: () -> Unit) {
    if (BuildConfig.DEBUG) {
        block()
    }
}
