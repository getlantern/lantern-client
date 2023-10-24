package org.getlantern.lantern.plausible

import android.content.Context
import androidx.startup.Initializer

// Automatically initializes the Plausible SDK for sending events.
class PlausibleInitializer : Initializer<Plausible> {
    override fun create(context: Context): Plausible {
        Plausible.init(context.applicationContext)
        return Plausible
    }

    override fun dependencies(): List<Class<out Initializer<*>>> {
        return emptyList()
    }
}