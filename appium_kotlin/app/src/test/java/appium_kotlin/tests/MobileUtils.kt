package appium_kotlin.tests

import appium_kotlin.LANTERN_PACKAGE_ID
import io.appium.java_client.MobileBy
import org.openqa.selenium.By

class MobileUtils {
    companion object {
        fun id(id: String): By {
            // MobileBy is optimised for for Android and IOS UIs instead of the generic By mainly for web locators.
            return MobileBy.id(addPackageId(id))
        }

        fun androidTextByBuilder(
            text: String,
            scroll: Boolean = true,
            searchType: SearchTextOperator = SearchTextOperator.EXACT,
        ): By {
            val elementByText = "UiSelector().${searchType.androidUiSelectorTextMethodName}(\"$text\")"
            val scrollableElement = "UiScrollable(UiSelector().scrollable(true).instance(0)).scrollIntoView($elementByText)"
            val by = if (scroll) scrollableElement else elementByText

            return androidUIAutomator(by)
        }

        fun androidUIAutomator(selector: String): By {
            return MobileBy.AndroidUIAutomator(selector)
        }

        enum class SearchTextOperator(val androidUiSelectorTextMethodName: String, val iOSOperator: String) {
            MATCHES("textMatches", "MATCHES"),
            EXACT("text", "=="),
            CONTAINS("textContains", "CONTAINS"),
            STARTS_WITH("textStartsWith", "BEGINSWITH"),
        }

        private fun addPackageId(id: String): String {
            return if (id.contains(":")) id else "${LANTERN_PACKAGE_ID}$id"
        }
    }
}
