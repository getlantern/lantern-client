package appium_kotlin.tests

import appium_flutter_driver.FlutterFinder
import appium_kotlin.CHROME_PACKAGE_ACTIVITY
import appium_kotlin.CHROME_PACKAGE_ID
import appium_kotlin.ContextType
import appium_kotlin.IP_REQUEST_URL
import appium_kotlin.LANTERN_PACKAGE_ID
import appium_kotlin.LOGS_DIALED_MESSAGE
import io.appium.java_client.TouchAction
import io.appium.java_client.android.Activity
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.touch.WaitOptions
import io.appium.java_client.touch.offset.PointOption
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.By
import org.openqa.selenium.logging.LogEntries
import java.io.IOException
import java.time.Duration
import java.util.regex.Pattern

class AppTest() : BaseTest() {
    private val isLocalRun = (System.getenv("RUN_ENV") ?: "local") == "local"

    @ParameterizedTest
    @MethodSource("devices")
    @Throws(IOException::class, InterruptedException::class)
    fun userJourneyTests(taskId: Int) {
        // variable has to local for thread safety
        // Logic can be improved
        var androidDriver: AndroidDriver? = null

        try {
            println("TaskId: $taskId | shouldRunVPNSameTime-->createConnection ")
            androidDriver = setupAndCreateConnection(taskId)
            println("TaskId: $taskId | shouldRunVPNSameTime-->flutterFinder Started ")

            // App Started wait for few seconds
            Thread.sleep(5000)

            switchToContext(ContextType.NATIVE_APP, androidDriver)
            startChromeBrowser(androidDriver)
            Thread.sleep(10000)

            val beforeIp = makeIpRequest(androidDriver)
            println("TaskId: $taskId | IP before VPN start: $beforeIp")

            switchToContext(ContextType.NATIVE_APP, androidDriver)
            androidDriver.activateApp(LANTERN_PACKAGE_ID)
            Thread.sleep(5000)

            val flutterFinder = FlutterFinder(driver = androidDriver)
            switchToContext(ContextType.FLUTTER, androidDriver)
            val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
            vpnSwitchFinder.click()
            Thread.sleep(2000)

            //Approve VPN Permissions dialog
            switchToContext(ContextType.NATIVE_APP, androidDriver)
            Thread.sleep(2000)
            androidDriver.findElement(By.id("android:id/button1")).click()

            //Wait for VPN to connect
            println("TaskId: $taskId | Going to Sleep")
            Thread.sleep(2000)

            //Open Chrome Again
            androidDriver.activateApp(CHROME_PACKAGE_ID)
            Thread.sleep(2000)
            pullToRefresh(androidDriver)

            //Make the request again
            makeIpRequest(androidDriver)
            Thread.sleep(4000)

            val afterIp: String = captureLogcat(androidDriver)

            if (!isLocalRun) {
                if (beforeIp == afterIp || afterIp.isBlank()) {
                    testFail(
                        "TaskId: $taskId | Both Ip are same or IP is blank before: $beforeIp after: $afterIp",
                        androidDriver
                    )
                } else {
                    testPassed(driver = androidDriver)
                }
            }
            println("TaskId: $taskId | IP Request before $beforeIp after $afterIp")

            Assertions.assertEquals(
                (afterIp.isNotBlank() && beforeIp.isNotBlank() && beforeIp != afterIp),
                true
            )

        } catch (e: Exception) {
            e.printStackTrace()
            if (!isLocalRun) {
                testFail(e.message!!, androidDriver!!)
            } else {
                throw Exception(e)
            }
        } finally {
            afterTest(androidDriver!!)
        }
    }


    private fun afterTest(driver: AndroidDriver) {
        switchToContext(ContextType.NATIVE_APP, driver)
        driver.removeApp(LANTERN_PACKAGE_ID)
        driver.quit()
        if (isLocalRun && service.isRunning) {
            service.stop()
        }
    }

    private fun startChromeBrowser(driver: AndroidDriver) {
        val activity =
            Activity(CHROME_PACKAGE_ID, CHROME_PACKAGE_ACTIVITY)
        activity.isStopApp = false
        driver.startActivity(activity)
        print("Android", "Chrome browser launched")
    }

    private fun pullToRefresh(driver: AndroidDriver) {
        val deviceWidth: Int = driver.manage().window().size.getWidth()
        val deviceHeight: Int = driver.manage().window().size.getHeight()
        val bottomEdge = (deviceHeight * 0.85f).toInt()
        val midX = deviceWidth / 2
        val midY = deviceHeight / 2
        TouchAction(driver)
            .press(PointOption.point(midX, midY))
            .waitAction(WaitOptions.waitOptions(Duration.ofMillis(1000)))
            .moveTo(PointOption.point(midX, bottomEdge))
            .release().perform()
    }

    private fun makeIpRequest(driver: AndroidDriver): String {
        switchToContext(ContextType.WEBVIEW_CHROME, driver)
        driver.get(IP_REQUEST_URL)
        Thread.sleep(5000)
        val ipElement = driver.findElement(By.tagName("pre"))
        val ip = ipElement.text
        print("IP Request", "Current IP $ip")
        return ip
    }


    /**Read logs from device
    Make sure tha we are actually bypassing traffic
    One way to know ths read logs from **Successfully dialed via**/
    private fun captureLogcat(androidDriver: AndroidDriver): String {
        switchToContext(ContextType.NATIVE_APP, androidDriver)
        val pattern = Pattern.compile("\\((.*):\\d+\\)") // regex pattern to match (IP:Port)
        val logtypes: Set<*> = androidDriver.manage().logs().availableLogTypes
        println("supported log types: $logtypes") // [logcat, bugreport, server, client]

        val logs: LogEntries = androidDriver.manage().logs().get("logcat")
        for (logEntry in logs) {
            //here are checking the logcat for LOGS_DIALED_MESSAGE that verifies internal that VPN is working
            // also when we connect vpn then ip is predefined so
            // we get that and match with old ip
            if (logEntry.message.contains(LOGS_DIALED_MESSAGE)) {
                val matcher = pattern.matcher(logEntry.message)
                if (matcher.find()) {
                    return matcher.group(1) // return the IP address immediately after match found
                }
            }
        }
        return ""
    }


}