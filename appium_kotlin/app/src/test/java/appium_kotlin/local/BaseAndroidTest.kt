package appium_kotlin.local

import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.options.UiAutomator2Options
import io.appium.java_client.remote.MobileCapabilityType
import io.appium.java_client.remote.MobilePlatform
import io.appium.java_client.service.local.AppiumDriverLocalService
import io.appium.java_client.service.local.AppiumServerHasNotBeenStartedLocallyException
import io.appium.java_client.service.local.AppiumServiceBuilder
import io.appium.java_client.service.local.flags.GeneralServerFlag
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.BeforeAll
import org.openqa.selenium.JavascriptExecutor
import java.net.URL


open class BaseAndroidTest {

    // Enums representing the context types
    enum class ContextType {
        NATIVE_APP,
        FLUTTER,
        WEBVIEW_CHROME
    }


    companion object {
        private lateinit var service: AppiumDriverLocalService
        lateinit var appiumDriver: AndroidDriver
        lateinit var jse: JavascriptExecutor

        // this should be dynamic
        private const val LANTERN_APK_PATH =
            "/Users/jigarfumakiya/Documents/getlantern/mobile_app/android-lantern/build/app/outputs/flutter-apk/app-prod-debug.apk"
        const val LANTERN_PACKAGE_ID = "org.getlantern.lantern"
        const val APP_URL = "bs://5ecc53f8ececf1d878de9b86cdbf2b4cc12152e7"
        var username = "jigarj_SNsRyw"
        var accessKey = "dA4yyG26fHbfJxRUYMwr"

//        @JvmStatic
//        @BeforeAll
//        fun setupAppium() {
//            val capabilities = UiAutomator2Options()
//            // Re-install app each time
//            capabilities.setCapability("appium:noReset", false)
//            capabilities.setCapability(MobileCapabilityType.AUTOMATION_NAME, "Flutter")
//
//            // Logging:
//            capabilities.setCapability(MobileCapabilityType.ENABLE_PERFORMANCE_LOGGING, false)
//            capabilities.setCapability("appium:logLevel", "debug")
//
//            // Timeouts:
//            capabilities.setCapability("webkitResponseTimeout", 5000)
//            capabilities.setCapability(MobileCapabilityType.NEW_COMMAND_TIMEOUT, 5000)
//
//            capabilities.setCapability("appium:deviceName", "Google Pixel 5")
//
//            capabilities.setCapability(MobileCapabilityType.PLATFORM_NAME, MobilePlatform.ANDROID)
//            capabilities.setCapability("setWebContentsDebuggingEnabled", "true")
//
//            capabilities.setCapability("app", APP_URL)
//            val browserstackOptions = HashMap<String, Any>()
//            browserstackOptions["appiumVersion"] = "2.0.0"
//            browserstackOptions["networkLogs"] = "true"
//            browserstackOptions["projectName"] = "Lantern"
//            browserstackOptions["buildName"] = "lantern-app-debug"
//            browserstackOptions["appiumLogs"] = "true";
//            capabilities.setCapability("bstack:options", browserstackOptions)
//            browserstackOptions["networkLogsExcludeHosts"] = arrayOf("api64.ipify.org")
//
//            appiumDriver = AndroidDriver(
//                URL("https://$username:$accessKey@hub-cloud.browserstack.com/wd/hub"),
//                capabilities
//            )
//            jse = appiumDriver
//
//            // Wait for first frame to render
//            waitForFirstFrame()
//        }

        @JvmStatic
        @BeforeAll
        fun setupAppium() {
            service = AppiumServiceBuilder()
                .withArgument(GeneralServerFlag.ALLOW_INSECURE, "chromedriver_autodownload")
                .build()
            service.start()

            if (!service.isRunning) {
                throw AppiumServerHasNotBeenStartedLocallyException("An appium server node is not started!")
            }

            val capabilities = UiAutomator2Options()

            // Re-install app each time
            capabilities.setCapability("appium:noReset", false)
            capabilities.setCapability(MobileCapabilityType.AUTOMATION_NAME, "Flutter")

            // Logging:
            capabilities.setCapability(MobileCapabilityType.ENABLE_PERFORMANCE_LOGGING, false)
            capabilities.setCapability("appium:logLevel", "debug")

            // Timeouts:
            capabilities.setCapability("webkitResponseTimeout", 5000)
            capabilities.setCapability(MobileCapabilityType.NEW_COMMAND_TIMEOUT, 5000)

            // Change to Flutter once done testing
            capabilities.setCapability("appium:udid", "PNXID19010901034")
            capabilities.setCapability("appium:deviceName", "Nokia 8.1")

            capabilities.setCapability(MobileCapabilityType.PLATFORM_VERSION, "11")
            capabilities.setCapability(MobileCapabilityType.PLATFORM_NAME, MobilePlatform.ANDROID)
            capabilities.setCapability("setWebContentsDebuggingEnabled", "true")
            capabilities.setCapability("app", LANTERN_APK_PATH)

              appiumDriver = AndroidDriver(service.url, capabilities)

            // Wait for first frame to render
            waitForFirstFrame()
        }

        @JvmStatic
        @AfterAll
        fun tearDown() {
            appiumDriver.quit()
            service.stop()
        }

        fun testPassed() {
            jse.executeScript("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\": \"passed\", \"reason\": \"Results found!\"}}")
        }

        fun testFail() {
            jse.executeScript("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\":\"failed\", \"reason\": \"Results not found\"}}")
        }

        private fun waitForFirstFrame() {
            appiumDriver.executeScript("flutter:waitForFirstFrame")
        }
    }

    protected fun switchToContext(contextType: ContextType) {
        print("Android", "Available to context: ${appiumDriver.contextHandles}")
        val context = getContextString(contextType)
        appiumDriver.context(context)
        print("Android", "Switched to context: $context")

    }

    private fun getContextString(contextType: ContextType): String {
        return when (contextType) {
            ContextType.NATIVE_APP -> "NATIVE_APP"
            ContextType.FLUTTER -> "FLUTTER"
            ContextType.WEBVIEW_CHROME -> "WEBVIEW_chrome"
            else -> throw IllegalArgumentException("Invalid context type: $contextType")
        }
    }

    protected fun print(tag: String, message: String) {
        println("[$tag] $message")
    }
}
