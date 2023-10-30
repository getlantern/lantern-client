package appium_kotlin.tests

import org.openqa.selenium.*

class MobileElement private constructor(lazyElement: Lazy<() -> WebElement?>, lazyLocator: Lazy<() -> By?>) {
    private val element by lazyElement
    private val locatorBy by lazyLocator

    constructor(element: () -> WebElement?) : this(lazyOf(element), lazyOf { null })
    constructor(element: () -> WebElement?, locatorBy: () -> By?) : this(lazyOf(element), lazyOf(locatorBy))

    private fun getElement(): WebElement {
        val el: WebElement?
        try {
            el = element()!!
        } catch (e: NullPointerException) {
            throw NullPointerException("Failed locating element with locator: ${locatorBy()}")
        }
        return el
    }
}