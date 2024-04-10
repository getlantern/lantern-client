package org.getlantern.lantern.test

import android.app.NotificationManager
import android.content.Context.NOTIFICATION_SERVICE
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.Until
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Bandwidth
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class DataUsageTests {

    @get:Rule
    var mainActivityRule = ActivityScenarioRule(MainActivity::class.java)

    private val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())

    private val notificationManager =
        LanternApp.getAppContext().getSystemService(NOTIFICATION_SERVICE) as NotificationManager

    @Before
    fun setUp() {
        LanternApp.getSession().setPaymentTestMode(true)
        notificationManager.cancelAll()
    }

    @Test
    fun WhenDataCapIsHit_AppShouldShowNotification() {
        val bandwidth = Bandwidth(100, 0, 1000, 3600)
        val title = LanternApp.getAppContext().resources.getString(R.string.lantern_notification)
        val content = LanternApp.getAppContext().resources.getString(
            R.string.data_cap,
            bandwidth.expiresAtString
        )
        testDataUsageNotification(bandwidth, title, content)
    }

    @Test
    fun WhenDataUsageIs50_AppShouldShowNotification() {
        val bandwidth = Bandwidth(50, 500, 1000, 3600)
        val title = LanternApp.getAppContext().resources.getString(R.string.lantern_notification)
        val content = LanternApp.getAppContext().resources.getString(
            R.string.data_cap_percent,
            bandwidth.remaining,
            bandwidth.expiresAtString
        )
        testDataUsageNotification(bandwidth, title, content)
    }

    @Test
    fun WhenDataUsageIs80_AppShouldShowNotification() {
        val bandwidth = Bandwidth(80, 200, 1000, 3600)
        val title = LanternApp.getAppContext().resources.getString(R.string.lantern_notification)
        val content = LanternApp.getAppContext().resources.getString(
            R.string.data_cap_percent,
            bandwidth.remaining,
            bandwidth.expiresAtString
        )
        testDataUsageNotification(bandwidth, title, content)
    }

    @Test
    fun WhenDataUsageIsReset_AppShouldShowNotification() {
        val bandwidth = Bandwidth(0, 1000, 1000, 3600)
        val title = LanternApp.getAppContext().resources.getString(R.string.lantern_notification)
        val content = LanternApp.getAppContext().resources.getString(R.string.data_cap_reset)
        testDataUsageNotification(bandwidth, title, content)
    }

    @Test
    fun WhenDataUsageIsOther_AppShouldNOTShowNotification() {
        // given the app is running
        val notExpectedTitle =
            LanternApp.getAppContext().resources.getString(R.string.lantern_notification)

        // open the notification bar
        device.openNotification()

        // send data usage update
        val bandwidth = Bandwidth(25, 750, 1000, 3600)
        LanternApp.getSession().bandwidthUpdate(
            bandwidth.percent,
            bandwidth.remaining,
            bandwidth.allowed,
            bandwidth.ttlSeconds
        )

        // then the user should NOT see a push notification
        device.wait(Until.hasObject(By.text(notExpectedTitle)), TIMEOUT)

        // with a correct title
        val titleObj: UiObject2? = device.findObject(By.text(notExpectedTitle))
        assertNull(titleObj)
    }

    private fun testDataUsageNotification(
        bandwidth: Bandwidth,
        expectedTitle: String,
        expectedContent: String
    ) {
        // given the app is running

        // open the notification bar
        device.openNotification()

        // send data usage update
        LanternApp.getSession().bandwidthUpdate(
            bandwidth.percent,
            bandwidth.remaining,
            bandwidth.allowed,
            bandwidth.ttlSeconds
        )

        // then the user should see a push notification
        device.wait(Until.hasObject(By.text(expectedTitle)), TIMEOUT)

        // with a correct title
        val titleObj: UiObject2? = device.findObject(By.text(expectedTitle))
        assertNotNull(titleObj)

        // and a correct content
        val contentObj: UiObject2? = device.findObject(By.text(expectedContent))
        assertNotNull(contentObj)
    }

    companion object {
        private const val TIMEOUT = 3000L // 3 seconds
    }
}
