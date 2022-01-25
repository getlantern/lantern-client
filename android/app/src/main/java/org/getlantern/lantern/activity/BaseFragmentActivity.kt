package org.getlantern.lantern.activity

import android.os.Bundle
import android.view.WindowManager
import androidx.fragment.app.FragmentActivity

abstract class BaseFragmentActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // prevent screenshots of this activity by other apps
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}