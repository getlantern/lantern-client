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
import appium_kotlin.IP_REQUEST_URL
import appium_kotlin.LANTERN_PACKAGE_ID
import appium_kotlin.LOGS_DIALED_MESSAGE
import appium_kotlin.MMYY
import appium_kotlin.MOST_POPULAR
import appium_kotlin.PAYMENT_PURCHASE_COMPLETED
import appium_kotlin.RENEWAL_SUCCESS_OK
import appium_kotlin.REPORT_AN_ISSUE
import appium_kotlin.REPORT_DESCRIPTION
import appium_kotlin.REPORT_ISSUE_SUCCESS
import appium_kotlin.SEND_REPORT
import appium_kotlin.SUPPORT
import io.appium.java_client.MobileBy
import io.appium.java_client.TouchAction
import io.appium.java_client.android.Activity
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.nativekey.AndroidKey
import io.appium.java_client.android.nativekey.KeyEvent
import io.appium.java_client.ios.IOSDriver
import io.appium.java_client.touch.WaitOptions
import io.appium.java_client.touch.offset.PointOption
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.By
import org.openqa.selenium.logging.LogEntries
import org.openqa.selenium.remote.RemoteWebDriver
import pro.truongsinh.appium_flutter.FlutterFinder
import java.io.IOException
import java.time.Duration
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern


enum class MobileOS {
    Android,
    IOS
}

class AppTest() : BaseTest() {
    private val isLocalRun = (System.getenv("RUN_ENV") ?: "local") == "local"
    private val testAppName = "chromecast"
    private val testAppPackage = "com.google.android.apps.chromecast.app"
    private val testAppActivity = ".DiscoveryActivity"

    @ParameterizedTest
    @MethodSource("devices")
    @Throws(IOException::class, InterruptedException::class)
    fun userJourneyTests(taskId: Int) {
        var androidDriver: AndroidDriver? = null
        var iosDriver: IOSDriver? = null
        try {
            println("TaskId: $taskId | shouldRunVPNSameTime-->createConnection ")
            val remoteDriver = setupAndCreateConnection(taskId)
            val osVersion = getMobileOs(remoteDriver)
//            remoteDriver.manage().timeouts().implicitlyWait(Duration.ofSeconds(5))
            val flutterFinder = FlutterFinder(driver = remoteDriver)

            if (osVersion == MobileOS.Android) {
                androidDriver = remoteDriver as AndroidDriver
                println("TaskId: $taskId | shouldRunVPNSameTime-->flutterFinder Started ")

                // Test the VPN Flow
                VPNFlow(androidDriver, taskId, flutterFinder)

                // If the VPN flow is successful then test Payment flow
                paymentFlow(androidDriver, taskId, flutterFinder)

                // Report and issue flow
                reportAnIssueFlow(androidDriver, taskId, flutterFinder)

//                googlePlayFlow(androidDriver, taskId, flutterFinder)

            } else {
                iosDriver = remoteDriver as IOSDriver
//                IOSVPNFlow(iosDriver, taskId, flutterFinder)

                reportAnIssueFlow(iosDriver, taskId, flutterFinder, MobileOS.IOS)
            }

            if (!isLocalRun) {
                testPassed(remoteDriver)

            }
        } catch (e: Exception) {
            e.printStackTrace()
            if (!isLocalRun) {
                iosDriver?.let {
                    testFail(e.message ?: "Unknown error", it)
                }
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
            iosDriver?.let {
                afterTest(it)
            }
        }
    }


    @Throws(IOException::class, InterruptedException::class)
    private fun IOSVPNFlow(
        iosDriver: IOSDriver,
        taskId: Int,
        flutterFinder: FlutterFinder
    ) {
        // App Started wait for few seconds
        Thread.sleep(5000)
//        iosDriver.activateApp(LANTERN_PACKAGE_ID)

        Thread.sleep(5000)
        startChromeBrowserIOS(iosDriver)

        Thread.sleep(2000)
        makeIpRequest(iosDriver)


//
//        val beforeIp = makeIpRequest(androidDriver)
//        println("TaskId: $taskId | IP before VPN start: $beforeIp")
//
//        switchToContext(ContextType.NATIVE_APP, androidDriver)
//        androidDriver.activateApp(LANTERN_PACKAGE_ID)
//        Thread.sleep(5000)
//
//
//        switchToContext(ContextType.FLUTTER, androidDriver)
//        val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
//        vpnSwitchFinder.click()
//        Thread.sleep(2000)
//
//        //Approve VPN Permissions dialog
//        switchToContext(ContextType.NATIVE_APP, androidDriver)
//        Thread.sleep(1000)
//        androidDriver.findElement(By.id("android:id/button1")).click()
//
//        //Wait for VPN to connect
//        println("TaskId: $taskId | Going to Sleep")
//        Thread.sleep(2000)
//
//        //Open Chrome Again
//        androidDriver.activateApp(CHROME_PACKAGE_ID)
//        Thread.sleep(2000)
//        pullToRefresh(androidDriver)
//
//        //Make the request again
//        makeIpRequest(androidDriver)
//        Thread.sleep(4000)
//
//        val afterIp: String = captureIPLogcat(androidDriver)
//
//        if (!isLocalRun) {
//            if (beforeIp == afterIp || afterIp.isBlank()) {
//                val testMessage = if (afterIp.isBlank()) {
//                    "TaskId: $taskId | Both Ip are same or IP is blank before: $beforeIp after: afterIp coming as blank"
//                } else {
//                    "TaskId: $taskId | Both Ip are same or IP is blank before: $beforeIp after: $afterIp"
//                }
//                testFail(
//                    testMessage,
//                    androidDriver
//                )
//            }
//        }
//        println("TaskId: $taskId | IP Request before $beforeIp after $afterIp")
//
//        Assertions.assertEquals(
//            (afterIp.isNotBlank() && beforeIp.isNotBlank() && beforeIp != afterIp),
//            true
//        )
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
        //lets wait till out api timeout
        Thread.sleep(17000)

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
        androidDriver: RemoteWebDriver,
        taskId: Int,
        flutterFinder: FlutterFinder,
        os: MobileOS = MobileOS.Android
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
        Thread.sleep(3000)

        print(
            "TaskId: $taskId",
            "reportAnIssueFlow-->Locating and clicking on the REPORT_AN_ISSUE."
        )
        val reportIssue = flutterFinder.byValueKey(REPORT_AN_ISSUE)
        reportIssue.click()
        Thread.sleep(1000)


        print("TaskId: $taskId", "reportAnIssueFlow-->Entering description.")
        val description = flutterFinder.byTooltip(REPORT_DESCRIPTION)
        description.click()
        description.sendKeys("This is sample report and issue running via Appium Test CI")
        Thread.sleep(3000)

        print(
            "TaskId: $taskId",
            "reportAnIssueFlow-->Locating and clicking on the send report button."
        )
        val sendReportButton = flutterFinder.byTooltip(SEND_REPORT)
        sendReportButton.click()

        //Since in IOS we are not able to read logs we will make sure form Success
        val isSuccessDialogVisble =
            isElementPresent(androidDriver, flutterFinder, RENEWAL_SUCCESS_OK)

        if (isSuccessDialogVisble) {
            val okButton = flutterFinder.byTooltip(RENEWAL_SUCCESS_OK)
            okButton.click()
            print("TaskId: $taskId", "reportAnIssueFlow-->Test fail, assertion false.")
            Assertions.assertEquals(isSuccessDialogVisble, true)

        } else {
            if (!isLocalRun) {
                testFail("Fail to submit Report/issue", androidDriver)
            }
            print("TaskId: $taskId", "reportAnIssueFlow-->Test passed, assertion true.")
            Assertions.assertEquals(isSuccessDialogVisble, true)
        }
    }

    private fun afterTest(driver: RemoteWebDriver) {
        switchToContext(ContextType.NATIVE_APP, driver)
        if (driver is AndroidDriver) {
            driver.removeApp(LANTERN_PACKAGE_ID)
            driver.quit()
        } else if (driver is IOSDriver) {
            driver.removeApp(LANTERN_PACKAGE_ID)
            driver.quit()
        }
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

    private fun startChromeBrowserIOS(driver: IOSDriver) {
        driver.activateApp("com.apple.mobilesafari")
        print("iOS", "Chrome browser launched")
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

    private fun makeIpRequest(driver: RemoteWebDriver): String {
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
    private fun captureReportIssueSuccessLogcat(
        androidDriver: RemoteWebDriver,
        mobileOs: MobileOS = MobileOS.Android
    ): String {
        switchToContext(ContextType.NATIVE_APP, androidDriver)
        val logtypes: Set<*> = androidDriver.manage().logs().availableLogTypes
        println("supported log types: $logtypes")

        val logs: LogEntries = if (mobileOs == MobileOS.IOS) {
            androidDriver.manage().logs().get("syslog")
        } else {
            androidDriver.manage().logs().get("logcat")
        }
        for (logEntry in logs) {
            println("contain log: ${logEntry.message}")
            if (logEntry.message.contains(REPORT_ISSUE_SUCCESS)) {
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
                println("payment log: ${logEntry.message}")
                return logEntry.message

            }
        }
        return ""
    }

    @Throws(IOException::class, InterruptedException::class)
    private fun googlePlayFlow(
        driver: AndroidDriver,
        taskId: Int,
        flutterFinder: FlutterFinder
    ) {
        turnVPNon(driver, taskId, flutterFinder)
        driver.startActivity(Activity("com.android.vending", ".AssetBrowserActivity"))
        testEstablishPlaySession(driver)
        testGooglePlayFeatures(driver)
        installAppFromPlayStore(taskId, driver)
    }

    fun turnVPNon(
        driver: AndroidDriver,
        taskId: Int,
        flutterFinder: FlutterFinder,
    ) {
        Thread.sleep(5000)

        switchToContext(ContextType.NATIVE_APP, driver)
        Thread.sleep(5000)
        driver.activateApp(LANTERN_PACKAGE_ID)
        Thread.sleep(5000)


        switchToContext(ContextType.FLUTTER, driver)
        val vpnSwitchFinder = flutterFinder.byType("FlutterSwitch")
        vpnSwitchFinder.click()
        Thread.sleep(2000)
        // Approve VPN Permissions dialog
        switchToContext(ContextType.NATIVE_APP, driver)
        Thread.sleep(1000)
    }

    fun testEstablishPlaySession(driver: AndroidDriver) {
        Assertions.assertEquals(driver.currentPackage, "com.android.vending")
        Assertions.assertEquals(driver.currentActivity(), ".AssetBrowserActivity")
    }

    fun testGooglePlayFeatures(driver: AndroidDriver) {
        driver.findElement(By.xpath("//android.widget.FrameLayout[@content-desc = 'Show navigation drawer']"))
            ?.click()
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

        driver.findElement(By.xpath("//android.support.v7.widget.RecyclerView[1]/android.widget.LinearLayout[1]"))
            ?.click()

        val button = driver.findElement(MobileBy.className("android.widget.Button"))
        if (button?.text.equals("Install")) {
            println("Installing application")
            button?.click()
        }

        driver.manage().timeouts().implicitlyWait(1, TimeUnit.SECONDS)
        driver.pressKey(KeyEvent(AndroidKey.HOME))
    }

}