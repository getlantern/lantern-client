package appium_kotlin


// Enums representing the context types
enum class ContextType {
    NATIVE_APP,
    FLUTTER,
    WEBVIEW_CHROME
}

const val LANTERN_PACKAGE_ID = "org.getlantern.lantern"
const val CHROME_PACKAGE_ID = "com.android.chrome"
const val CHROME_PACKAGE_ACTIVITY = "org.chromium.chrome.browser.ChromeTabbedActivity"
const val IP_REQUEST_URL = "https://api64.ipify.org"
const val LOGS_DIALED_MESSAGE = "Successfully dialed via"
const val ERROR_PAYMENT_PURCHASE = "Error with purchase request:"
const val PAYMENT_PURCHASE_COMPLETED = "Purchase Completed:"

//Finder Keys
const val DEVELOPER_TAP = "bottomBar_developer_tap"
const val ACCOUNT_TAP = "bottomBar_account_tap"
const val PAYMENT_SWITCH = "payment_mode_switch"
const val UPGRADE_LANTERN_PRO = "upgrade_lantern_pro"
const val ACCOUNT_MANAGEMENT = "account_management"
const val ACCOUNT_RENEW = "account_renew"
const val MOST_POPULAR = "most_popular"
const val MORE_OPTION = "more_option"
const val EMAIL_KEY = "emailKey"
const val CONTIUNE_CHECKOUT = "checkout"
const val CARD_NUMBER = "card_number"
const val MMYY = "mm_yy"
const val CVC = "cvc"
const val CHECK_OUT = "check_out"
const val RENEWAL_SUCCESS_OK = "renew_success_ok"
const val SUPPORT = "support"
const val REPORT_AN_ISSUE = "report_issue"


