package org.getlantern.lantern.datadog

import android.app.Activity
import com.datadog.android.rum.tracking.AcceptAllActivities
import com.datadog.android.rum.tracking.ComponentPredicate
import io.flutter.embedding.android.FlutterActivity

class FlutterExcludingComponentPredicate: ComponentPredicate<Activity> {
    val innerPredicate = AcceptAllActivities()

    override fun accept(component: Activity): Boolean {
        if (component is FlutterActivity) {
            return false
        }

        return innerPredicate.accept(component)
    }

    override fun getViewName(component: Activity): String? {
        return innerPredicate.getViewName(component)
    }
}