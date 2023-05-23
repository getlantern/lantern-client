package appium_kotlin.live

import appium_kotlin.ContextType
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.remote.MobileCapabilityType
import org.junit.jupiter.api.TestInstance
import org.junit.jupiter.api.parallel.Execution
import org.junit.jupiter.api.parallel.ExecutionMode
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.By
import org.openqa.selenium.JavascriptExecutor
import org.openqa.selenium.remote.DesiredCapabilities
import java.io.FileReader
import java.net.URL
import java.util.stream.Stream

/** Here is the device list-:https://www.browserstack.com/list-of-browsers-and-platforms/app_automate */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@Execution(ExecutionMode.CONCURRENT)
open class ParallelTest {

    companion object {
        lateinit var config: JsonObject

        @JvmStatic
        @MethodSource("devices")
        fun devices(): Stream<Int> {
            val taskIDs = mutableListOf<Int>()
            val parser = JsonParser()
            config =
                parser.parse(FileReader("src/test/resources/live/live_bstack_config.json")) as JsonObject
            val envs = (config["environments"] as JsonArray).size()
            for (i in 0 until envs) {
                taskIDs.add(i)
            }
            println("Devices Ids: $taskIDs")
            return taskIDs.stream()
        }
    }

    fun setupAndCreateConnection(taskId: Int): AndroidDriver {
        println("Setup and creating connection for TaskId: $taskId")
        val capabilities = DesiredCapabilities()
        // Setup part
        val commonCapabilities = config["capabilities"] as JsonObject
        var it = commonCapabilities.entrySet().iterator()
        while (it.hasNext()) {
            val pair = it.next() as Map.Entry<*, *>
            if (pair.key.toString() == "bstack:options") {
                val bstackOptions = pair.value as JsonObject
                val bstackOptionsIterator = bstackOptions.entrySet().iterator()
                val bstackMap = HashMap<String, Any>()
                while (bstackOptionsIterator.hasNext()) {
                    val bstackPair = bstackOptionsIterator.next() as Map.Entry<*, *>
                    val bstackKey = bstackPair.key.toString()
                    val bstackValue = bstackPair.value.toString().replace("\"", "")
                    bstackMap[bstackKey] = bstackValue
                }
                capabilities.setCapability("bstack:options", bstackMap)
            } else {
                if (capabilities.getCapability(pair.key.toString()) == null) {
                    capabilities.setCapability(
                        pair.key.toString(),
                        pair.value.toString().replace("\"", "")
                    )
                }
            }
        }
        val username = System.getenv("BROWSERSTACK_USERNAME") ?: config.get("username").asString
        val accessKey =
            System.getenv("BROWSERSTACK_ACCESS_KEY") ?: config.get("access_key").asString

        val app = System.getenv("BROWSERSTACK_APP_ID")
        if (app != null && app.isNotEmpty()) {
            capabilities.setCapability("app", app)
        }
        capabilities.setCapability(MobileCapabilityType.AUTOMATION_NAME, "Flutter")
        println("Setup for TaskId $taskId: $capabilities")

        // Creating connection part
        println("TaskId: $taskId | Creating Connection")
        val envs = config["environments"] as JsonArray
        println("TaskId: $taskId | envs $envs")
        val envCapabilities = envs[taskId] as JsonObject
        println("TaskId: $taskId | Current Evn $envCapabilities")
        it = envCapabilities.entrySet().iterator()
        while (it.hasNext()) {
            val pair = it.next() as Map.Entry<String, Any>
            capabilities.setCapability(pair.key, pair.value.toString().replace("\"", ""))
        }

        val driver = AndroidDriver(
            URL("https://${username}:${accessKey}@hub-cloud.browserstack.com/wd/hub"),
            capabilities
        )
        println("TaskId: $taskId | Driver created")
        println("TaskId: $taskId | Car $capabilities")
        return driver
    }


    fun testPassed(driver: AndroidDriver) {
        val jse = (driver as JavascriptExecutor)
        jse.executeScript("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\": \"passed\", \"reason\": \"All test passed!\"}}")
    }

    fun testFail(failureMessage: String, driver: AndroidDriver) {
        val jse = (driver as JavascriptExecutor)
        jse.executeScript("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\":\"failed\", \"reason\": \"$failureMessage\"}}");
    }


    protected fun switchToContext(contextType: ContextType, driver: AndroidDriver) {
        synchronized(this) {
            val context = getContextString(contextType)
            driver.context(context)
            print("Android", "Switched to context: $context")
        }
    }

    private fun getContextString(contextType: ContextType): String {
        return when (contextType) {
            ContextType.NATIVE_APP -> "NATIVE_APP"
            ContextType.FLUTTER -> "FLUTTER"
            ContextType.WEBVIEW_CHROME -> "WEBVIEW_chrome"
        }
    }

    protected fun print(tag: String, message: String) {
        println("[$tag] $message")
    }

    fun waitForElement(driver: AndroidDriver, locator: By, timeoutInSeconds: Long = 10) {
        for (i in 0 until timeoutInSeconds) {
            try {
                driver.findElement(locator)
                return
            } catch (e: NoSuchElementException) {
                Thread.sleep(1000)  // wait for 1 second before trying again
            }
        }
        throw NoSuchElementException("Element with locator '$locator' was not found in $timeoutInSeconds seconds")
    }
}