package appium_kotlin.tests

import appium_kotlin.ContextType
import appium_kotlin.LANTERN_PACKAGE_ID
import io.appium.java_client.MobileBy
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.nativekey.AndroidKey
import io.appium.java_client.android.nativekey.KeyEvent
import io.appium.java_client.remote.AndroidMobileCapabilityType
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.By
import org.openqa.selenium.remote.DesiredCapabilities
import pro.truongsinh.appium_flutter.FlutterFinder
import java.net.URL
import java.util.concurrent.TimeUnit

class GooglePlayTest() : BaseTest() {

    private val testAppName = "chromecast"
    private val testAppPackage = "com.google.android.apps.chromecast.app"
    private val testAppActivity = ".DiscoveryActivity"

    @ParameterizedTest
    @MethodSource("devices")
    fun userJourneyTests(taskId: Int) {
        var driver = setupAndCreateConnection(taskId)
        val flutterFinder = FlutterFinder(driver)
        turnVPNon(driver, taskId, flutterFinder)

        var capabilities = initialCapabilities(taskId)
        capabilities.setCapability(AndroidMobileCapabilityType.APP_PACKAGE, "com.android.vending")
        capabilities.setCapability(AndroidMobileCapabilityType.APP_ACTIVITY, ".AssetBrowserActivity")
        capabilities.setCapability(AndroidMobileCapabilityType.APP_WAIT_ACTIVITY, ".AssetBrowserActivity")
        capabilities.setCapability(AndroidMobileCapabilityType.DEVICE_READY_TIMEOUT, 40)
        driver = initDriver(capabilities)
        testEstablishPlaySession(driver)
        testGooglePlayFeatures(driver)
        installAppFromPlayStore(taskId, driver)
        println("Opening application")
        driver.quit()
        capabilities = installedAppCapabilities(taskId)
        driver = initDriver(capabilities)
        driver.launchApp()
    }

    fun turnVPNon(
        driver: AndroidDriver,
        taskId: Int,
        flutterFinder: FlutterFinder,
    ) {
        switchToContext(ContextType.NATIVE_APP, driver)
        driver.activateApp(LANTERN_PACKAGE_ID)
        Thread.sleep(5000)


        switchToContext(ContextType.FLUTTER, driver)
        val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
        vpnSwitchFinder.click()
        Thread.sleep(2000)
        // Approve VPN Permissions dialog
        switchToContext(ContextType.NATIVE_APP, driver)
        Thread.sleep(1000)
        driver.findElement(By.id("android:id/button1")).click()
        //Wait for VPN to connect
        println("TaskId: $taskId | Going to Sleep")
        Thread.sleep(2000)
    }

    fun initDriver(capabilities: DesiredCapabilities): AndroidDriver {
        val isLocalRun = checkLocalRun()
        val url = serviceURL(isLocalRun)
        return AndroidDriver(
            URL(url),
            capabilities,
        )
    }

    fun testEstablishPlaySession(driver: AndroidDriver) {
        Assertions.assertEquals(driver.currentPackage, "com.android.vending")
        Assertions.assertEquals(driver.currentActivity(), "org.getlantern.lantern")
    }

    fun testGooglePlayFeatures(driver: AndroidDriver) {
        driver.findElement(By.xpath("/android.widget.FrameLayout[@content-desc = 'Show navigation drawer']"))?.click()
        val elements = driver.findElements(By.xpath("//android.widget.TextView"))
        if (elements == null) return
        for (element in elements) {
            if (element.text.equals("Settings")) {
                element.click()
                break
            }
        }
    }

    fun openSearchForm(driver: AndroidDriver) {
        val elements = driver?.findElements(By.xpath("//android.widget.TextView"))
        if (elements == null) return
        for (element in elements) {
            if (element.text.equals("Search for apps & games")) {
                element.click()
                break
            }
        }
    }

    @Throws(Exception::class)
    fun installAppFromPlayStore(taskId: Int, driver: AndroidDriver) {
        openSearchForm(driver)
        driver.findElement(MobileBy.className("android.widget.EditText"))?.sendKeys(testAppName)

        driver.findElement(By.xpath("//android.support.v7.widget.RecyclerView[1]/android.widget.LinearLayout[1]"))?.click()

        val button = driver.findElement(MobileBy.className("android.widget.Button"))
        if (button?.text.equals("Install")) {
            println("Installing application")
            button?.click()
        }

        driver.manage().timeouts().implicitlyWait(1, TimeUnit.SECONDS)
        driver.pressKey(KeyEvent(AndroidKey.HOME))
    }

    @Throws(Exception::class)
    fun installedAppCapabilities(taskId: Int): DesiredCapabilities {
        val capabilities = initialCapabilities(taskId)
        capabilities.setCapability(AndroidMobileCapabilityType.APP_PACKAGE, testAppPackage)
        capabilities.setCapability(AndroidMobileCapabilityType.APP_ACTIVITY, testAppActivity)
        capabilities.setCapability(AndroidMobileCapabilityType.APP_WAIT_ACTIVITY, testAppActivity)
        capabilities.setCapability(AndroidMobileCapabilityType.DEVICE_READY_TIMEOUT, 40)
        capabilities.setCapability("deviceOrientation", "portrait")
        capabilities.setCapability("autoLaunch", "false")
        return capabilities
    }
}
