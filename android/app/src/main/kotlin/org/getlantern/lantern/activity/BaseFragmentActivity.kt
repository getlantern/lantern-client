package org.getlantern.lantern.activity

import android.os.Bundle
import android.view.WindowManager
import androidx.fragment.app.FragmentActivity
import org.getlantern.lantern.BuildConfig

abstract class BaseFragmentActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // if not in dev mode, prevent screenshots of this activity by other apps
        if (!BuildConfig.DEVELOPMENT_MODE) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
