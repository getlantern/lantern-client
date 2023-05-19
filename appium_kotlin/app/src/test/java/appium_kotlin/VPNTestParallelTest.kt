package appium_kotlin

import appium_flutter_driver.FlutterFinder
import appium_kotlin.local.BaseAndroidTest
import io.appium.java_client.TouchAction
import io.appium.java_client.android.Activity
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.touch.WaitOptions
import io.appium.java_client.touch.offset.PointOption
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.By
import java.io.IOException
import java.time.Duration

class VPNTestParallelTest() : ParallelTest() {

    private var androidDriver: AndroidDriver? = null

    @ParameterizedTest
    @MethodSource("devices")
    @Throws(IOException::class, InterruptedException::class)
    fun shouldRunVPNSameTime(taskId: Int) {
        try {
            println("shouldRunVPNSameTime-->createConnection ")
            androidDriver = createConnection(taskId)
            println("shouldRunVPNSameTime-->flutterFinder Started ")
            val flutterFinder = FlutterFinder(driver = androidDriver!!)
            println("shouldRunVPNSameTime-->Sleep ")
            Thread.sleep(5000)
            switchToContext(BaseAndroidTest.ContextType.NATIVE_APP)
            // We need to lunch chrome only once
            // So it will stay in context we can perform http request
            // Make sure to set stop app to false
            startChromeBrowser()
            // Wait for ablest 10 seconds so Appium know chrome is open
            // And it will add context to it context list
            Thread.sleep(10000)

            // Make Ip request and get Ip before VPN starts
            val beforeIp = makeIpRequest()
            switchToContext(BaseAndroidTest.ContextType.NATIVE_APP)
            androidDriver?.activateApp(BaseAndroidTest.LANTERN_PACKAGE_ID)
            Thread.sleep(5000)

            // Find the VPN switch and turn it on
            switchToContext(BaseAndroidTest.ContextType.FLUTTER)
            val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
            vpnSwitchFinder.click()
            Thread.sleep(2000)

            // Allow system dialog permssion
            switchToContext(BaseAndroidTest.ContextType.NATIVE_APP)
            Thread.sleep(2000)
            androidDriver!!.findElement(By.id("android:id/button1")).click()
            try {
                System.out.println("!!!6 Going to Sleep")
                Thread.sleep(2000)
            } catch (e: InterruptedException) {
                BaseAndroidTest.tearDown()
            }

            // Get ip again after turing on VPN switch
            androidDriver!!.activateApp("com.android.chrome")
            Thread.sleep(2000)
            pullToRefresh()

            val afterIp = makeIpRequest()

            // Ip should not be same at any case
            // same it should be fail
            // We might need add some more verification logic soon
            if (beforeIp == afterIp) {
                testFail("Both Ip are same before $beforeIp after $afterIp")
            } else {
                testPassed()
            }
            print("IP Request before $beforeIp after $afterIp")
            Assertions.assertEquals(beforeIp != afterIp, true)

            // Turn of VPN
            switchToContext(BaseAndroidTest.ContextType.FLUTTER)
            vpnSwitchFinder.click()
            Thread.sleep(2000)

        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            // Cleanup after test
            switchToContext(BaseAndroidTest.ContextType.NATIVE_APP)
            androidDriver?.removeApp(BaseAndroidTest.LANTERN_PACKAGE_ID)
            androidDriver?.quit()
            drivers?.remove(taskId)
            executors?.remove(taskId)
        }

    }

    @AfterEach
    fun afterTest() {
        androidDriver?.context("NATIVE_APP")
        // Uninstall app is test run successfully
        androidDriver?.removeApp(BaseAndroidTest.LANTERN_PACKAGE_ID)
    }

    private fun startChromeBrowser() {
        val activity =
            Activity("com.android.chrome", "org.chromium.chrome.browser.ChromeTabbedActivity")
        activity.setStopApp(false)
        androidDriver?.startActivity(activity)
        print("Android", "Chrome browser launched")
    }

    private fun pullToRefresh() {
        val deviceWidth: Int = androidDriver!!.manage().window().getSize().getWidth()
        val deviceHeight: Int = androidDriver!!.manage().window().getSize().getHeight()
        val bottomEdge = (deviceHeight * 0.85f).toInt()
        val midX = deviceWidth / 2
        val midY = deviceHeight / 2
        TouchAction(androidDriver)
            .press(PointOption.point(midX, midY))
            .waitAction(WaitOptions.waitOptions(Duration.ofMillis(1000)))
            .moveTo(PointOption.point(midX, bottomEdge))
            .release().perform();
    }

    private fun makeIpRequest(): String {
        switchToContext(BaseAndroidTest.ContextType.WEBVIEW_CHROME)
        androidDriver?.get("https://api64.ipify.org")
        Thread.sleep(5000)
        val ipElement = androidDriver!!.findElement(By.tagName("pre"))
        // Retrieve the IP from the element
        val ip = ipElement.text
        print("IP Request", "Current IP $ip")
        return ip
    }


}