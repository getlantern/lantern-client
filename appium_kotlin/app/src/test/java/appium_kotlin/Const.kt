package appium_kotlin


// Enums representing the context types
enum class ContextType {
    NATIVE_APP,
    FLUTTER,
    WEBVIEW_CHROME
}

const val LANTERN_APK_PATH =
    "/Users/jigarfumakiya/Documents/getlantern/mobile_app/android-lantern/build/app/outputs/flutter-apk/app-prod-debug.apk"
const val LANTERN_PACKAGE_ID = "org.getlantern.lantern"
const val CHROME_PACKAGE_ID = "com.android.chrome"
const val CHROME_PACKAGE_ACTIVITY = "org.chromium.chrome.browser.ChromeTabbedActivity"
const val IP_REQUEST_URL = "https://api64.ipify.org"
const val LOGS_DIALED_MESSAGE = "DEBUG balancer: balancer.go:420 Successfully dialed via"

