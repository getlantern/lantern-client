package appium_kotlin.tests

import appium_kotlin.ContextType
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import io.appium.java_client.AppiumDriver
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.service.local.AppiumDriverLocalService
import io.appium.java_client.service.local.AppiumServerHasNotBeenStartedLocallyException
import io.appium.java_client.service.local.AppiumServiceBuilder
import io.appium.java_client.service.local.flags.GeneralServerFlag
import org.junit.jupiter.api.TestInstance
import org.junit.jupiter.api.parallel.Execution
import org.junit.jupiter.api.parallel.ExecutionMode
import org.junit.jupiter.params.provider.MethodSource
import org.openqa.selenium.JavascriptExecutor
import org.openqa.selenium.remote.DesiredCapabilities
import pro.truongsinh.appium_flutter.FlutterFinder
import java.io.FileReader
import java.net.URL
import java.util.concurrent.TimeUnit
import java.util.stream.Stream

/** Here is the device list-:https://www.browserstack.com/list-of-browsers-and-platforms/app_automate */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@Execution(ExecutionMode.CONCURRENT)
open class BaseTest {

    companion object {
        lateinit var config: JsonObject
        lateinit var service: AppiumDriverLocalService


        @JvmStatic
        @MethodSource("devices")
        fun devices(): Stream<Int> {
            val taskIDs = mutableListOf<Int>()
            val parser = JsonParser()
            // Use an environment variable or system property to determine the config file path
            val runEnv = System.getenv("RUN_ENV") ?: "local"
            val configFilePath = when (runEnv) {
                "local" -> "src/test/resources/local/local_config.json"
                else -> "src/test/resources/live/live_config.json"
            }

            config = parser.parse(FileReader(configFilePath)) as JsonObject
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
        // Initialize DesiredCapabilities
        val capabilities = DesiredCapabilities()
        // Get common capabilities from config
        val commonCapabilities = config["capabilities"] as JsonObject
        // Get environment variables if available or get from config
        val username = System.getenv("BROWSERSTACK_USERNAME") ?: config.get("username").asString
        val accessKey =
            System.getenv("BROWSERSTACK_ACCESS_KEY") ?: config.get("access_key").asString
        val app = System.getenv("BROWSERSTACK_APP_ID") ?: config.get("app").asString
        val server = System.getenv("SERVER") ?: config.get("server").asString
        // Check if it is a local run
        val isLocalRun = (System.getenv("RUN_ENV") ?: "local") == "local"
        val envs = config["environments"] as JsonArray
        // If local run, start Appium Server
        if (isLocalRun) {
            // Start Appium Server for local run
            service = AppiumServiceBuilder()
                .withArgument(GeneralServerFlag.ALLOW_INSECURE, "chromedriver_autodownload")
                .build()
            service.start()

            if (!service.isRunning) {
                throw AppiumServerHasNotBeenStartedLocallyException("An appium server node is not started!")
            }
        }

        // Iterate over common capabilities
        val it = commonCapabilities.entrySet().iterator()
        while (it.hasNext()) {
            val pair = it.next() as Map.Entry<*, *>
            // If bstack:options capability, handle it separately
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
                // For other capabilities, directly set them
                if (capabilities.getCapability(pair.key.toString()) == null) {
                    capabilities.setCapability(
                        pair.key.toString(),
                        pair.value.toString().replace("\"", "")
                    )
                }
            }
        }
        capabilities.setCapability("app", app)
//        capabilities.setCapability(MobileCapabilityType.AUTOMATION_NAME, "Flutter")
        println("Setup for TaskId $taskId: $capabilities")


        val envCapabilities = envs[taskId] as JsonObject
        println("TaskId: $taskId | Current Evn $envCapabilities")

        // Set capabilities for the specific environment
        envCapabilities.entrySet().iterator().forEach { pair ->
            capabilities.setCapability(pair.key, pair.value.toString().replace("\"", ""))
        }
        val url = if (isLocalRun) {
            service.url.toString()
        } else {
            "https://${username}:${accessKey}@$server"
        }

        val driver = AndroidDriver(
            URL(url),
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
        val context = getContextString(contextType)
        driver.context(context)
        print("Android", "Switched to context: $context")

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

}