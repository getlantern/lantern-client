//package org.getlantern.lantern.test
//
//import android.Manifest
//import android.graphics.Point
//import android.os.AsyncTask
//import android.os.SystemClock
//import android.util.Log
//import android.view.View
//import androidx.test.InstrumentationRegistry
//import androidx.test.espresso.Espresso
//import androidx.test.espresso.ViewInteraction
//import androidx.test.espresso.action.ViewActions
//import androidx.test.espresso.assertion.ViewAssertions
//import androidx.test.espresso.matcher.ViewMatchers
//import androidx.test.filters.LargeTest
//import androidx.test.filters.SdkSuppress
//import androidx.test.rule.GrantPermissionRule
//import androidx.test.runner.AndroidJUnit4
//import androidx.test.uiautomator.UiDevice
//import com.kyleduo.switchbutton.SwitchButton
//import org.getlantern.lantern.MainActivity
//import org.getlantern.lantern.R
//import org.hamcrest.Description
//import org.hamcrest.Matcher
//import org.hamcrest.TypeSafeMatcher
//import org.json.JSONException
//import org.json.JSONObject
//import org.junit.Assert
//import org.junit.Before
//import org.junit.Rule
//import org.junit.Test
//import org.junit.runner.RunWith
//import java.net.HttpURLConnection
//import java.net.NetworkInterface
//import java.net.SocketException
//import java.net.URL
//import java.util.concurrent.ExecutionException
//
//@RunWith(AndroidJUnit4::class)
//@SdkSuppress(minSdkVersion = 18)
//@LargeTest
//class ApplicationTest {
//    @Rule
//    @JvmField
//    var grantPermissionRule = GrantPermissionRule.grant(Manifest.permission.WRITE_EXTERNAL_STORAGE)
//
//    @Rule
//    @JvmField
//    var mActivityRule = MyActivityTestRule(MainActivity::class.java)
//
//    lateinit var mDevice: UiDevice
//    var mWatchers = UiWatchers()
//
//    fun resetTestUser() {
//        var url = URL("https://api.getiantem.org/reset-test-user")
//        val conn = url.openConnection() as HttpURLConnection
//        conn.connectTimeout = 10000
//        conn.readTimeout = 10000
//        conn.requestMethod = "POST"
//        conn.connect()
//        conn.outputStream.close()
//        if (conn.responseCode != 200) {
//            throw Exception("Unexpected response code resetting test user: " + conn.responseCode)
//        }
//    }
//
//    @Before
//    @Throws(Exception::class)
//    fun setUp() {
//        resetTestUser()
//
//        mDevice = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
//        SystemClock.sleep(5000)
//        TestUtils.clickButtonIfPresent(mDevice, "OK")
//        mWatchers.registerAnrAndCrashWatchers()
//        val coordinates = arrayOfNulls<Point>(4)
//        coordinates[0] = Point(248, 1520)
//        coordinates[1] = Point(248, 929)
//        coordinates[2] = Point(796, 1520)
//        coordinates[3] = Point(796, 929)
//        if (!mDevice.isScreenOn) {
//            mDevice.wakeUp()
//            mDevice.swipe(coordinates, 10)
//        }
//    }
//
//    @Test
//    fun turnOnAndOffVPN() {
//        Log.d(TAG, "Testing turning VPN on and off")
//        clickButton(R.id.powerLantern)
//        SystemClock.sleep(1000)
//        TestUtils.clickButtonIfPresent(mDevice, "OK")
//        verifyVPNOn()
//        try {
//            val json = JSONParse().execute().get()
//            Assert.assertNotNull("should get JSON result", json)
//            val ip = json.getString("ip")
//            Log.d(TAG, "Got IP Address! $ip")
//        } catch (e: ExecutionException) {
//            e.printStackTrace()
//            Assert.fail("JSON fetching task failed")
//        } catch (e: InterruptedException) {
//            e.printStackTrace()
//            Assert.fail("JSON fetching task interrupted")
//        } catch (e: JSONException) {
//            e.printStackTrace()
//            Assert.fail("got incorrect JSON result")
//        }
//        Log.d(TAG, "Waiting for view powerLantern to turn off VPN")
//        clickButton(R.id.powerLantern)
//        verifyVPNOff()
//
//        // TODO: swipeLeft/swipeRight has no effect. Figure out how to test.
//        // onView(withId(R.id.powerLantern)).perform(swipeRight());
//        // verifyVPNOn();
//
//        // onView(withId(R.id.powerLantern)).perform(swipeLeft());
//        // verifyVPNOff();
//    }
//
//    @Test
//    fun upgradeWithStripe() {
//        Log.d(TAG, "Testing upgrading to Pro with a Stripe purchase")
////        clickButton(R.id.upgradeBtn)
//        clickButton(R.id.oneYearBtn)
//        fillField(R.id.emailInput, "ox+testuser@gmail.com")
//        fillField(R.id.cardInput, "4242424242424242")
//        fillField(R.id.expirationInput, "03/24")
//        fillField(R.id.cvcInput, "123")
//        Espresso.onView(ViewMatchers.withId(R.id.cvcInput)).perform(ViewActions.closeSoftKeyboard())
//        clickButton(R.id.continueBtn)
//        clickButton(R.id.continueToProBtn, attempts = 30, sleep = 1000)
//    }
//
//    private fun verifyVPNOn() {
//        SystemClock.sleep(1000)
//        Espresso.onView(ViewMatchers.withId(R.id.powerLantern)).check(
//            ViewAssertions.matches(withChecked(true))
//        )
//        Assert.assertTrue("System VPN should be on", isSystemVPNConnected)
//    }
//
//    private fun verifyVPNOff() {
//        SystemClock.sleep(1000)
//        Espresso.onView(ViewMatchers.withId(R.id.powerLantern)).check(
//            ViewAssertions.matches(withChecked(false))
//        )
//        Assert.assertFalse("System VPN should be off", isSystemVPNConnected)
//    }
//
//    private val isSystemVPNConnected: Boolean
//        private get() = try {
//            val intf = NetworkInterface.getByName("tun0")
//            intf != null
//        } catch (e: SocketException) {
//            false
//        }
//
//    private inner class JSONParse : AsyncTask<String?, String?, JSONObject>() {
//        override fun doInBackground(vararg params: String?): JSONObject {
//            Log.d(TAG, "Fetching json from $url")
//            return JsonParser.getJSONFromUrl(url)
//        }
//    }
//
//    private fun clickButton(id: Int, attempts: Int = 10, sleep: Long = 500) {
//        doUntilSuccessful(
//            attempts, sleep,
//            {
//                onView(id).perform(ViewActions.click())
//            }
//        )
//    }
//
//    private fun fillField(id: Int, text: String, attempts: Int = 10, sleep: Long = 500) {
//        doUntilSuccessful(
//            attempts, sleep,
//            {
//                onView(id).perform(
//                    ViewActions.clearText(),
//                    ViewActions.typeText(text)
//                )
//            }
//        )
//    }
//
//    private fun onView(id: Int): ViewInteraction {
//        return Espresso.onView(ViewMatchers.withId(id))
//    }
//
//    private fun doUntilSuccessful(attempts: Int = 10, sleep: Long = 500, fn: () -> Unit) {
//        lateinit var lastException: Throwable
//        for (x in 0..attempts) {
//            try {
//                return fn()
//            } catch (e: Throwable) {
//                lastException = e
//                SystemClock.sleep(sleep)
//                // continue
//            }
//        }
//        throw lastException
//    }
//
//    companion object {
//        private const val TAG = "ApplicationTest"
//        private const val url = "https://ifconfig.co/json"
//        private fun withChecked(checked: Boolean): Matcher<View> {
//            return object : TypeSafeMatcher<View>() {
//                public override fun matchesSafely(v: View): Boolean {
//                    val button = v as SwitchButton
//                    return button.isChecked == checked
//                }
//
//                override fun describeTo(description: Description) {
//                    description.appendText("with correct background color")
//                }
//            }
//        }
//    }
//}
