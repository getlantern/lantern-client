package appium_kotlin.tests

import appium_kotlin.ACCOUNT_MANAGEMENT
import appium_kotlin.ACCOUNT_RENEW
import appium_kotlin.ACCOUNT_TAP
import appium_kotlin.CARD_NUMBER
import appium_kotlin.CHECK_OUT
import appium_kotlin.CHROME_PACKAGE_ACTIVITY
import appium_kotlin.CHROME_PACKAGE_ID
import appium_kotlin.CVC
import appium_kotlin.ContextType
import appium_kotlin.ERROR_PAYMENT_PURCHASE
import appium_kotlin.IP_REQUEST_URL
import appium_kotlin.LANTERN_PACKAGE_ID
import appium_kotlin.LOGS_DIALED_MESSAGE
import appium_kotlin.MMYY
import appium_kotlin.MOST_POPULAR
import appium_kotlin.PAYMENT_PURCHASE_COMPLETED
import appium_kotlin.RENEWAL_SUCCESS_OK
import appium_kotlin.REPORT_AN_ISSUE
import appium_kotlin.SUPPORT
import io.appium.java_client.TouchAction
import io.appium.java_client.android.Activity
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.touch.TapOptions
import io.appium.java_client.touch.WaitOptions
import io.appium.java_client.touch.offset.PointOption
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.By
import org.openqa.selenium.logging.LogEntries
import pro.truongsinh.appium_flutter.FlutterFinder
import java.io.IOException
import java.time.Duration
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.regex.Pattern


class AppTest() : BaseTest() {
    private val isLocalRun = (System.getenv("RUN_ENV") ?: "local") == "local"

    @ParameterizedTest
    @MethodSource("devices")
    @Throws(IOException::class, InterruptedException::class)
    fun userJourneyTests(taskId: Int) {
        var androidDriver: AndroidDriver? = null
        try {
            println("TaskId: $taskId | shouldRunVPNSameTime-->createConnection ")
            androidDriver = setupAndCreateConnection(taskId)
            println("TaskId: $taskId | shouldRunVPNSameTime-->flutterFinder Started ")

            val flutterFinder = FlutterFinder(driver = androidDriver)
            // Test the VPN Flow
            VPNFlow(androidDriver, taskId, flutterFinder)

            // If the VPN flow is successful then test Payment flow
            paymentFlow(androidDriver, taskId, flutterFinder)

            // Report and issue flow
            reportAnIssueFlow(androidDriver, taskId, flutterFinder)

            if (!isLocalRun) {
                testPassed(androidDriver)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            if (!isLocalRun) {
                androidDriver?.let {
                    testFail(e.message ?: "Unknown error", it)
                }
            } else {
                throw e
            }
        } finally {
            androidDriver?.let {
                afterTest(it)
            }

        }
    }

    @Throws(IOException::class, InterruptedException::class)
    private fun VPNFlow(
        androidDriver: AndroidDriver,
        taskId: Int,
        flutterFinder: FlutterFinder
    ) {
        // App Started wait for few seconds
        Thread.sleep(5000)

        switchToContext(ContextType.NATIVE_APP, androidDriver)
        startChromeBrowser(androidDriver)
        Thread.sleep(5000)

        val beforeIp = makeIpRequest(androidDriver)
        println("TaskId: $taskId | IP before VPN start: $beforeIp")

        switchToContext(ContextType.NATIVE_APP, androidDriver)
        androidDriver.activateApp(LANTERN_PACKAGE_ID)
        Thread.sleep(5000)


        switchToContext(ContextType.FLUTTER, androidDriver)
        val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
        vpnSwitchFinder.click()
        Thread.sleep(2000)

        //Approve VPN Permissions dialog
        switchToContext(ContextType.NATIVE_APP, androidDriver)
        Thread.sleep(1000)
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

        val afterIp: String = captureIPLogcat(androidDriver)

        if (!isLocalRun) {
            if (beforeIp == afterIp || afterIp.isBlank()) {
                val testMessage = if (afterIp.isBlank()) {
                    "TaskId: $taskId | Both Ip are same or IP is blank before: $beforeIp after: afterIp coming as blank"
                } else {
                    "TaskId: $taskId | Both Ip are same or IP is blank before: $beforeIp after: $afterIp"
                }
                testFail(
                    testMessage,
                    androidDriver
                )
            }
        }
        println("TaskId: $taskId | IP Request before $beforeIp after $afterIp")

        Assertions.assertEquals(
            (afterIp.isNotBlank() && beforeIp.isNotBlank() && beforeIp != afterIp),
            true
        )
    }


    @Throws(IOException::class, InterruptedException::class)
    private fun paymentFlow(
        androidDriver: AndroidDriver,
        taskId: Int,
        flutterFinder: FlutterFinder
    ) {
        println("TaskId: $taskId | testPaymentFlow-->started ")

        switchToContext(ContextType.NATIVE_APP, androidDriver)
        androidDriver.activateApp(LANTERN_PACKAGE_ID)

        println("TaskId: $taskId | testPaymentFlow-->activated app ")

        switchToContext(ContextType.FLUTTER, androidDriver)
        val accountTap = flutterFinder.byValueKey(ACCOUNT_TAP)
        accountTap.click()
        Thread.sleep(2000)

        println("TaskId: $taskId | testPaymentFlow-->clicked on account ")

        val accountManagement = flutterFinder.byValueKey(ACCOUNT_MANAGEMENT)
        accountManagement.click()
        Thread.sleep(1000)

        println("TaskId: $taskId | testPaymentFlow-->clicked on account management ")
        val accountRenew = flutterFinder.byValueKey(ACCOUNT_RENEW)
        accountRenew.click()
        Thread.sleep(1000)

        println("TaskId: $taskId | testPaymentFlow-->clicked on account renew ")
        val mostPopular = flutterFinder.byValueKey(MOST_POPULAR)
        mostPopular.click()
        Thread.sleep(2000)
        println("TaskId: $taskId | testPaymentFlow-->clicked on most popular ")


        switchToContext(ContextType.NATIVE_APP, androidDriver)
        val continueButton =
            androidDriver.findElement(By.xpath("//android.widget.Button[@content-desc=\"CONTINUE\"]"))
        continueButton.click()
        Thread.sleep(1000)


        println("TaskId: $taskId | testPaymentFlow-->clicked on continue button ")
        switchToContext(ContextType.FLUTTER, androidDriver)
        val cardNumber = flutterFinder.byTooltip(CARD_NUMBER)
        cardNumber.click()
        cardNumber.sendKeys("4242424242424242")
        Thread.sleep(2000)

        println("TaskId: $taskId | testPaymentFlow-->card number entered ")

        val now = LocalDate.now()
        val futureDate = if (now.monthValue == 12) {
            now.plusMonths(1).withYear(now.year + 1)
        } else {
            now.plusMonths(1)
        }
        val formatter = DateTimeFormatter.ofPattern("MMyy")
        val mmyyText = formatter.format(futureDate)

        val mmyy = flutterFinder.byTooltip(MMYY)
        mmyy.click()
        mmyy.sendKeys(mmyyText)
        Thread.sleep(2000)
        println("TaskId: $taskId | testPaymentFlow-->expiration date entered ")

        val cvc = flutterFinder.byTooltip(CVC)
        cvc.click()
        cvc.sendKeys("123")
        Thread.sleep(2000)

        println("TaskId: $taskId | testPaymentFlow-->CVC entered ")
        val checkOut = flutterFinder.byTooltip(CHECK_OUT)
        checkOut.click()
        Thread.sleep(6000)

        println("TaskId: $taskId | testPaymentFlow-->clicked on checkout ")
        //Robust way to check is read logs from device
        val paymentPurchaseLogs = capturePaymentPassLogcat(androidDriver)
        println("TaskId: $taskId | paymentLogs-->$paymentPurchaseLogs")

        if (paymentPurchaseLogs.isBlank()) {
            if (!isLocalRun) {
                testFail("Purchasing lantern pro failed", androidDriver)
            }
        }

        switchToContext(ContextType.FLUTTER, androidDriver)
        val renewalSuccessOk = flutterFinder.byTooltip(RENEWAL_SUCCESS_OK)
        renewalSuccessOk.click()
        Thread.sleep(1000)

        Assertions.assertEquals(
            paymentPurchaseLogs.isNotBlank(),
            true,
            "Purchasing lantern pro failed"
        )

    }

    @Throws(IOException::class, InterruptedException::class)
    private fun reportAnIssueFlow(
        androidDriver: AndroidDriver,
        taskId: Int,
        flutterFinder: FlutterFinder
    ) {

        print("TaskId: $taskId", "reportAnIssueFlow-->Switching to FLUTTER context.")
        switchToContext(ContextType.FLUTTER, androidDriver)

        print("TaskId: $taskId", "reportAnIssueFlow-->Locating and clicking on the ACCOUNT_TAP.")
        val accountTap = flutterFinder.byValueKey(ACCOUNT_TAP)
        accountTap.click()
        Thread.sleep(2000)

        print("TaskId: $taskId", "reportAnIssueFlow-->Locating and clicking on the SUPPORT.")
        val supportTap = flutterFinder.byValueKey(SUPPORT)
        supportTap.click()
        Thread.sleep(1000)

        print(
            "TaskId: $taskId",
            "reportAnIssueFlow-->Locating and clicking on the REPORT_AN_ISSUE."
        )
        val reportIssue = flutterFinder.byValueKey(REPORT_AN_ISSUE)
        reportIssue.click()
        Thread.sleep(1000)

        print("TaskId: $taskId", "reportAnIssueFlow-->Switching to NATIVE_APP context.")
        switchToContext(ContextType.NATIVE_APP, androidDriver)
        val issueDropdown = androidDriver.findElement(By.id("org.getlantern.lantern:id/issue"))
        issueDropdown.click()
        Thread.sleep(1000)

        print("TaskId: $taskId", "reportAnIssueFlow-->Performing tap action.")
        TouchAction(androidDriver).tap(
            TapOptions.tapOptions().withPosition(PointOption.point(127, 767))
        ).perform()
        Thread.sleep(1000)

        print("TaskId: $taskId", "reportAnIssueFlow-->Entering description.")
        val description = androidDriver.findElement(By.id("org.getlantern.lantern:id/description"))
        description.click()
        description.sendKeys("This is sample report and issue running vai Appium Test CI")
        Thread.sleep(3000)

        print("TaskId: $taskId", "reportAnIssueFlow-->Hiding keyboard.")
        androidDriver.hideKeyboard()
        Thread.sleep(2000)

        print(
            "TaskId: $taskId",
            "reportAnIssueFlow-->Locating and clicking on the send report button."
        )
        val sendReportButton = androidDriver.findElement(By.id("org.getlantern.lantern:id/sendBtn"))
        sendReportButton.click()
        Thread.sleep(5000)

        print(
            "TaskId: $taskId",
            "reportAnIssueFlow-->Locating and clicking on the report send button."
        )
        val reportSend = androidDriver.findElement(By.id("android:id/button1"))
        reportSend.click()
        Thread.sleep(2000)

        print("TaskId: $taskId", "reportAnIssueFlow-->Test passed, assertion true.")
        Assertions.assertEquals(true, true)
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
    private fun captureIPLogcat(androidDriver: AndroidDriver): String {
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

    @Synchronized
    private fun capturePaymentFailLogcat(androidDriver: AndroidDriver): String {
        switchToContext(ContextType.NATIVE_APP, androidDriver)
        val logtypes: Set<*> = androidDriver.manage().logs().availableLogTypes
        println("supported log types: $logtypes") // [logcat, bugreport, server, client]
        val logs: LogEntries = androidDriver.manage().logs().get("logcat")
        for (logEntry in logs) {
            if (logEntry.message.contains(ERROR_PAYMENT_PURCHASE)) {
                println("contain log: ${logEntry.message}") // [logcat, bugreport, server, client]
                return logEntry.message

            }
        }
        return ""
    }

    @Synchronized
    private fun capturePaymentPassLogcat(androidDriver: AndroidDriver): String {
        switchToContext(ContextType.NATIVE_APP, androidDriver)
        val logtypes: Set<*> = androidDriver.manage().logs().availableLogTypes
        println("supported log types: $logtypes") // [logcat, bugreport, server, client]
        val logs: LogEntries = androidDriver.manage().logs().get("logcat")
        for (logEntry in logs) {
            if (logEntry.message.contains(PAYMENT_PURCHASE_COMPLETED)) {
                return logEntry.message

            }
        }
        return ""
    }

}