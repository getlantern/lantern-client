package appium_kotlin.local

import appium_flutter_driver.FlutterFinder
import appium_kotlin.ContextType
import appium_kotlin.LANTERN_PACKAGE_ID
import appium_kotlin.local.BaseAndroidTest
import io.appium.java_client.TouchAction
import io.appium.java_client.android.Activity
import io.appium.java_client.touch.WaitOptions.waitOptions
import io.appium.java_client.touch.offset.PointOption.point
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.openqa.selenium.By
import java.time.Duration.ofMillis


// there some issue with getting webview_chrome context some time it work
// and some time it does not work
// if not work install app and try again
// trying find way reproducible steps
class VPNTests : BaseAndroidTest() {
    lateinit var flutterFinder: FlutterFinder

    @BeforeEach
    fun setup() {
        flutterFinder = FlutterFinder(appiumDriver)
    }

    @Test
    fun vpnShouldProxyTraffic() {
        Thread.sleep(5000)
        switchToContext(ContextType.NATIVE_APP)
        // We need to lunch chrome only once
        // So it will stay in context we can perform http request
        // Make sure to set stop app to false
        startChromeBrowser()
        // Wait for ablest 10 seconds so Appium know chrome is open
        // And it will add context to it context list
        Thread.sleep(10000)

        // Make Ip request and get Ip before VPN starts
        val beforeIp = makeIpRequest()
        switchToContext(ContextType.NATIVE_APP)
        appiumDriver.activateApp(LANTERN_PACKAGE_ID)
        Thread.sleep(5000)

        // Find the VPN switch and turn it on
        switchToContext(ContextType.FLUTTER)
        val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
        vpnSwitchFinder.click()
        Thread.sleep(2000)

        // Allow system dialog permssion
        switchToContext(ContextType.NATIVE_APP)
        Thread.sleep(2000)
        appiumDriver.findElement(By.id("android:id/button1")).click()
        try {
            System.out.println("!!!6 Going to Sleep")
            Thread.sleep(2000)
        } catch (e: InterruptedException) {
            Companion.tearDown()
        }

        // Get ip again after turing on VPN switch
        appiumDriver.activateApp("com.android.chrome")
        Thread.sleep(2000)
        pullToRefresh()

        val afterIp = makeIpRequest()

        // Ip should not be same at any case
        // same it should be fail
        // We might need add some more verification logic soon
        if (beforeIp == afterIp) {
            testFail()
        } else {
            testPassed()
        }
        print("IP Request before $beforeIp after $afterIp")
        Assertions.assertEquals(beforeIp != afterIp, true)

        // Turn of VPN
        switchToContext(ContextType.FLUTTER)
        vpnSwitchFinder.click()
        Thread.sleep(2000)
    }

    @AfterEach
    fun afterTest() {
        appiumDriver.context("NATIVE_APP")
        // Uninstall app is test run successfully
        appiumDriver.removeApp(LANTERN_PACKAGE_ID)

    }

    private fun startChromeBrowser() {
        // Activity activity = new Activity("com.android.chrome",
        // "com.google.android.apps.chrome.Main");
        val activity =
            Activity("com.android.chrome", "org.chromium.chrome.browser.ChromeTabbedActivity")
        activity.setStopApp(false)
        appiumDriver.startActivity(activity)
        print("Android", "Chrome browser launched")
    }

    private fun pullToRefresh() {
        val deviceWidth: Int = appiumDriver.manage().window().getSize().getWidth()
        val deviceHeight: Int = appiumDriver.manage().window().getSize().getHeight()
        val bottomEdge = (deviceHeight * 0.85f).toInt()
        val midX = deviceWidth / 2
        val midY = deviceHeight / 2
        TouchAction(appiumDriver)
            .press(point(midX, midY))
            .waitAction(waitOptions(ofMillis(1000)))
            .moveTo(point(midX, bottomEdge))
            .release().perform();
    }

    private fun makeIpRequest(): String {
        switchToContext(ContextType.WEBVIEW_CHROME)
        // appiumDriver.context("WEBVIEW_chrome");
        appiumDriver.get("https://api64.ipify.org")

        Thread.sleep(5000)
        val ipElement = appiumDriver.findElement(By.tagName("pre"))
        // Retrieve the IP from the element
        val ip = ipElement.text
        print("IP Request", "Current IP $ip")
        return ip
    }

}
