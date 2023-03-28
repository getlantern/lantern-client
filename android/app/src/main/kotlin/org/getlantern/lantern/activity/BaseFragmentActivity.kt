package org.getlantern.lantern.activity

import android.os.Bundle
import android.view.WindowManager
import androidx.fragment.app.FragmentActivity
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.util.Analytics

abstract class BaseFragmentActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // if not in dev mode, prevent screenshots of this activity by other apps
        if (!BuildConfig.DEVELOPMENT_MODE) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun onResume() {
        super.onResume()
        // track the screen view
        Analytics.screen(this, this)
    }
}
