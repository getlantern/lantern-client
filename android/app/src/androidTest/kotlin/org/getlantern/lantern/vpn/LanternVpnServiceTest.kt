package org.getlantern.lantern.vpn

import android.app.Application
import android.os.Environment
import androidx.test.core.app.ApplicationProvider

class LanternVpnServiceTest {

	companion object {
        private val TAG = LanternVpnServiceTest::class.java.simpleName		
	}

    private val allRequiredPermissions = arrayOf(
        Manifest.permission.INTERNET,
        Manifest.permission.ACCESS_WIFI_STATE,
        Manifest.permission.ACCESS_NETWORK_STATE,
    )

	@get:Rule
    val grant = grantPermissions(allRequiredPermissions)

    private val application by lazy { ApplicationProvider.getApplicationContext<Application>() }
}