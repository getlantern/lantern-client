package org.getlantern.lantern.activity

import android.content.Intent
import androidx.test.InstrumentationRegistry
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.ext.junit.rules.activityScenarioRule
import androidx.test.internal.runner.junit4.AndroidJUnit4ClassRunner
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject
import androidx.test.uiautomator.UiSelector
import org.getlantern.lantern.R
import org.getlantern.lantern.test.TestUtils
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4ClassRunner::class)
class UpdateActivityTest {

    companion object {
        private const val updateURL =
            "https://github.com/getlantern/lantern/releases/download/7.4.9/update_android_arm.bz2"
    }

    @get:Rule
    var activityRule = activityScenarioRule<UpdateActivity_>()

    lateinit var device: UiDevice

    @Before
    fun setUp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        TestUtils.clickButtonIfPresent(device, "OK")
    }

    @Test
    fun testUpdate() {
        val intent = Intent()
            .putExtra("updateUrl", updateURL)
        activityRule.launchActivity(intent)
        onView(withId(R.id.installUpdate)).perform(click())
        waitForDownloadingAPK()
    }

    private fun waitForDownloadingAPK() {
        val text = activityRule.activity.resources
            .getString(R.string.updating_lantern)
        var dialog: UiObject? = null
        do {
            try {
                // sleep for one second
                TimeUnit.SECONDS.sleep(1)
                dialog = device.findObject(UiSelector().text(text))
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
        } while (dialog?.exists() == true)
    }
}
