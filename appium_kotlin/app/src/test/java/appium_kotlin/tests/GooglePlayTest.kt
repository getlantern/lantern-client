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
import appium_kotlin.REPORT_DESCRIPTION
import appium_kotlin.REPORT_ISSUE_SUCCESS
import appium_kotlin.SEND_REPORT
import appium_kotlin.SUPPORT
import io.appium.java_client.MobileBy
import io.appium.java_client.MobileElement
import io.appium.java_client.TouchAction
import io.appium.java_client.android.Activity
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.nativekey.AndroidKey
import io.appium.java_client.android.nativekey.KeyEvent
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
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern

class GooglePlayTest() : BaseTest() {

	private var driver: AndroidDriver? = null
	private val testAppName = "ccleaner"

    @ParameterizedTest
    @MethodSource("devices")
	fun userJourneyTests(taskId: Int) {
		driver = setupAndCreateConnection(taskId)
		testEstablishPlaySession()
		testGooglePlayFeatures()
		testInstallAppPlayStore()
	}

	fun testEstablishPlaySession() {
		val activity = driver.activity
		val package = driver.package
		Assertions.assertEquals(package, "com.android.vending")
		Assertions.assertEquals(activity, "org.getlantern.lantern")
	}

	fun testGooglePlayFeatures() {
		driver.findElement(By.xpath("/android.widget.FrameLayout[@content-desc = 'Show navigation drawer']")).click()
		val elements = driver.findElements(By.xpath("//android.widget.TextView"))
		for (element in elements) {
			element.text.equals("Settings").let? {
				it.click()
				break
			}
		}
	}

	fun openSearchForm() {
		val elements = driver.findElements(By.xpath("//android.widget.TextView"))
		for (element in elements) {
			element.text.equals("Search for apps & games").let? {
				it.click()
				break
			}
		}
	}

	Throws(Exception::class)
	fun testInstallAppPlayStore() {
		openSearchForm()
		driver.findElement(MobileBy.className("android.widget.EditText")).sendKeys(testAppName)

        driver.findElement(By.xpath("//android.support.v7.widget.RecyclerView[1]/android.widget.LinearLayout[1]")).click()

        val button = driver.findElement(MobileBy.className("android.widget.Button"))
        if (button.text.equals("Install")) { 
        	println("Installing application")
        	button.click()
        } else {
        	println("Opening application")
        	button.click()
        }

        driver.manage().timeouts().implicitlyWait(1, TimeUnit.SECONDS)
        driver.pressKey(KeyEvent(AndroidKey.HOME))
        driver.closeApp()
	}
}