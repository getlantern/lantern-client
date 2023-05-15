import io.appium.java_client.AppiumDriver
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.remote.AndroidMobileCapabilityType
import io.appium.java_client.remote.MobileCapabilityType
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.BeforeAll
import org.openqa.selenium.remote.DesiredCapabilities
import java.net.URL

open class AppiumSetup {

    @AfterEach
    fun waitForFirstFrame() {
        driver.executeScript("flutter:waitForFirstFrame")
    }

    companion object {

        private const val activityName = "org.getlantern.lantern.MainActivity"
        private const val appPackage = "org.getlantern.lantern"
        // private const val automationName = "UiAutomator2"
        private const val automationName = "Flutter"
        private const val platformName = "Android"
        private const val serverUrl = "http://localhost:4723/wd/hub"

        lateinit var driver: AppiumDriver
        private val caps = DesiredCapabilities()

        @JvmStatic
        @BeforeAll
        fun setUp() {
            caps.setCapability(MobileCapabilityType.PLATFORM_NAME, platformName)
            caps.setCapability(MobileCapabilityType.AUTOMATION_NAME, automationName)
            caps.setCapability(AndroidMobileCapabilityType.APP_PACKAGE, appPackage)
            caps.setCapability(AndroidMobileCapabilityType.APP_ACTIVITY, activityName)
            caps.setCapability(AndroidMobileCapabilityType.AUTO_GRANT_PERMISSIONS, true)
            driver = AndroidDriver(URL(serverUrl), caps)
        }

        @JvmStatic
        @AfterAll
        fun tearDown() {
            driver.quit()
        }
    }
}
