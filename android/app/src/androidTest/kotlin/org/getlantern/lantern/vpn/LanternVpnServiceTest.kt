package org.getlantern.lantern.vpn

import android.Manifest
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Environment
import androidx.test.core.app.ApplicationProvider
import androidx.test.internal.runner.junit4.AndroidJUnit4ClassRunner
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.rule.GrantPermissionRule
import androidx.test.rule.ServiceTestRule
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4ClassRunner::class)
class LanternVpnServiceTest {

    @get:Rule
    val serviceRule = ServiceTestRule()

    val appContext = InstrumentationRegistry.getInstrumentation().targetContext

    @get:Rule
    val grantPermissionRule: GrantPermissionRule = GrantPermissionRule.grant(
        Manifest.permission.INTERNET,
        Manifest.permission.ACCESS_WIFI_STATE,
        Manifest.permission.ACCESS_NETWORK_STATE,
        Manifest.permission.WRITE_EXTERNAL_STORAGE,
    )

    @Test
    fun testWithBoundService() {
        val serviceIntent = Intent(appContext, LanternVpnService::class.java)
        // P
    }

    @Test
    fun testWithExcludedApps() {
        val excludedApps = listOf("com.facebook.katana", "com.snapchat.android")
        val serviceIntent = Intent(appContext, LanternVpnService::class.java)
    }

    @Test
    fun testVPNService() {
        serviceRule.startService(
            Intent(appContext, LanternVpnService::class.java)
        )
    }

    companion object {
        private val TAG = LanternVpnServiceTest::class.java.simpleName      
    }

}