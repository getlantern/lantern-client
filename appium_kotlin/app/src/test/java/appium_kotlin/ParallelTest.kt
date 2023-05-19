package appium_kotlin

import appium_kotlin.local.BaseAndroidTest
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.remote.MobileCapabilityType
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.TestInstance
import org.junit.jupiter.api.parallel.Execution
import org.junit.jupiter.api.parallel.ExecutionMode
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.JavascriptExecutor
import org.openqa.selenium.remote.DesiredCapabilities
import java.io.FileReader
import java.net.MalformedURLException
import java.net.URL
import java.util.stream.Stream

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@Execution(ExecutionMode.CONCURRENT)
open class ParallelTest {

    var drivers: HashMap<Int, AndroidDriver>? = HashMap()
    var executors: HashMap<Int, JavascriptExecutor>? = HashMap()
    var currentTaskId: Int = -1

    lateinit var username: String
    lateinit var accessKey: String
    lateinit var capabilities: DesiredCapabilities

    companion object {
        lateinit var config: JsonObject

        @JvmStatic
        @MethodSource("devices")
        fun devices(): Stream<Int> {
            val taskIDs = mutableListOf<Int>()
            val parser = JsonParser()
            config =
                parser.parse(FileReader("src/test/resources/multiple_device/multiple_config.json")) as JsonObject
            val envs = (config["environments"] as JsonArray).size()
            for (i in 0 until envs) {
                taskIDs.add(i)
            }
            return taskIDs.stream()
        }
    }

    @BeforeEach
    fun setup() {
        capabilities = DesiredCapabilities()
        val commonCapabilities = config["capabilities"] as JsonObject
        val it = commonCapabilities.entrySet().iterator()
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
        username = System.getenv("BROWSERSTACK_USERNAME") ?: config.get("username").asString
        accessKey = System.getenv("BROWSERSTACK_ACCESS_KEY") ?: config.get("access_key").asString

        val app = System.getenv("BROWSERSTACK_APP_ID")
        if (app != null && app.isNotEmpty()) {
            capabilities.setCapability("app", app)
        }
        capabilities.setCapability(MobileCapabilityType.AUTOMATION_NAME, "Flutter")
        println("setup $capabilities")
    }

    @Throws(MalformedURLException::class)
    fun createConnection(taskId: Int): AndroidDriver {
        print("shouldRunVPNSameTime-->InSide createConnection ")
        val envs = config["environments"] as JsonArray
        print("shouldRunVPNSameTime-->getting envs")
        val envCapabilities = envs[taskId] as JsonObject
        val it = envCapabilities.entrySet().iterator()
        while (it.hasNext()) {
            val pair = it.next() as Map.Entry<String, Any>
            capabilities.setCapability(pair.key, pair.value.toString().replace("\"", ""))
        }
        print("shouldRunVPNSameTime $capabilities")
        val driver = AndroidDriver(
            URL("https://${BaseAndroidTest.username}:${BaseAndroidTest.accessKey}@hub-cloud.browserstack.com/wd/hub"),
            capabilities
        )
        print("shouldRunVPNSameTime driver")
        drivers?.put(taskId, driver)
        executors?.put(taskId, driver as JavascriptExecutor)
        currentTaskId = taskId
        return driver
    }

    @AfterEach
    fun tearDown() {
        // Invoke driver.quit() to indicate that the test is completed.
        drivers?.get(currentTaskId)?.quit()
        executors?.remove(currentTaskId)
        drivers?.remove(currentTaskId)
    }

    fun testPassed() {
        val jse = executors?.get(currentTaskId)
        jse?.executeScript("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\": \"passed\", \"reason\": \"Results found!\"}}")
    }

    fun testFail(failureMessage: String) {
        val jse = executors?.get(currentTaskId)
        jse?.executeScript("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\":\"failed\", \"reason\": $failureMessage}}")
    }


    protected fun switchToContext(contextType: BaseAndroidTest.ContextType) {
        print("Android", "Available to context: ${drivers?.get(currentTaskId)!!.contextHandles}")
        val context = getContextString(contextType)
        drivers?.get(currentTaskId)!!.context(context)
        print("Android", "Switched to context: $context")

    }

    private fun getContextString(contextType: BaseAndroidTest.ContextType): String {
        return when (contextType) {
            BaseAndroidTest.ContextType.NATIVE_APP -> "NATIVE_APP"
            BaseAndroidTest.ContextType.FLUTTER -> "FLUTTER"
            BaseAndroidTest.ContextType.WEBVIEW_CHROME -> "WEBVIEW_chrome"
            else -> throw IllegalArgumentException("Invalid context type: $contextType")
        }
    }

    protected fun print(tag: String, message: String) {
        println("[$tag] $message")
    }
}