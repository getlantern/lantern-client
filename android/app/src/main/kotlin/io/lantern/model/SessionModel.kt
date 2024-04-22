package io.lantern.model

import android.app.Activity
import android.content.Intent
import com.google.gson.JsonObject
import com.google.protobuf.ByteString
import internalsdk.Internalsdk
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.apps.AppsDataProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import okhttp3.FormBody
import okhttp3.RequestBody
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.MainActivity
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.FreeKassaActivity_
import org.getlantern.lantern.activity.WebViewActivity_
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternHttpClient.ProCallback
import org.getlantern.lantern.model.LanternHttpClient.ProUserCallback
import org.getlantern.lantern.model.PaymentMethods
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.plausible.Plausible
import org.getlantern.lantern.util.AutoUpdater
import org.getlantern.lantern.util.PaymentsUtil
import org.getlantern.lantern.util.PermissionUtil
import org.getlantern.lantern.util.PlansUtil
import org.getlantern.lantern.util.castToBoolean
import org.getlantern.lantern.util.restartApp
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.IssueReporter
import org.getlantern.mobilesdk.model.SessionManager

/**
 * This is a model that uses the same db schema as the preferences in SessionManager so that those
 * settings can be observed.
 */
class SessionModel(
    private val activity: Activity,
    flutterEngine: FlutterEngine,
) : BaseModel("session", flutterEngine, LanternApp.getSession().db) {
    private val appsDataProvider: AppsDataProvider = AppsDataProvider(
        activity.packageManager, activity.packageName
    )
    private val lanternClient = LanternApp.getLanternHttpClient()
    private val autoUpdater = AutoUpdater(activity, activity)
    private val paymentsUtil = PaymentsUtil(activity)

    companion object {
        private const val TAG = "SessionModel"
        const val PATH_PRO_USER = "prouser"
        const val PATH_SELECTED_TAB = "/selectedTab"
        const val PATH_PLAY_VERSION = "playVersion"
        const val PATH_SERVER_INFO = "/server_info"

        const val PATH_SDK_VERSION = "sdkVersion"
        const val PATH_USER_LEVEL = "userLevel"

        const val PATH_SPLIT_TUNNELING = "/splitTunneling"
        const val SHOULD_SHOW_GOOGLE_ADS = "shouldShowGoogleAds"
        const val PATH_APPS_DATA = "/appsData/"


    }

    init {
        db.mutate { tx ->
            // initialize data for fresh install // TODO remove the need to do this for each data path
            tx.put(
                PATH_PRO_USER,
                castToBoolean(tx.get(PATH_PRO_USER), false),
            )
            tx.put(
                PATH_SELECTED_TAB,
                tx.get(PATH_SELECTED_TAB) ?: "vpn",
            )
            tx.put(
                PATH_USER_LEVEL,
                tx.get(PATH_USER_LEVEL) ?: "",
            )
            tx.put(
                PATH_SPLIT_TUNNELING, castToBoolean(tx.get(PATH_SPLIT_TUNNELING), false)
            )
            // hard disable chat
            tx.put(SessionManager.CHAT_ENABLED, false)
            tx.put(PATH_SDK_VERSION, Internalsdk.sdkVersion())

        }

        updateAppsData()
        checkAdsAvailability()
    }

    fun checkAdsAvailability() {
        //This check is just safe guard
        //So if something goes wrong in backend we should not show ads to pro users at any case
        if (LanternApp.getSession().isProUser) {
            db.mutate { tx ->
                tx.put(SHOULD_SHOW_GOOGLE_ADS, false)

            }
            return
        }
        Logger.debug(TAG, "checkAdsAvailability called")
        val googleAds = shouldShowAdsBasedRegion { LanternApp.getSession().shouldShowAdsEnabled() }
        Logger.debug(
            TAG, "checkAdsAvailability with googleAds values $googleAds enable ${
                LanternApp.getSession().shouldShowAdsEnabled()
            }"
        )
        db.mutate { tx ->
            tx.put(SHOULD_SHOW_GOOGLE_ADS, googleAds)

        }
    }


    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "authorizeViaEmail" -> requestRecoveryEmail(call.argument("emailAddress")!!, result)
            "checkEmailExists" -> checkEmailExists(call.argument("emailAddress")!!, result)
            "requestLinkCode" -> requestLinkCode(result)
            "redeemLinkCode" -> redeemLinkCode(result)
            "resendRecoveryCode" -> sendRecoveryCode(result)
            "validateRecoveryCode" -> validateRecoveryCode(call.argument("code")!!, result)
            "approveDevice" -> approveDevice(call.argument("code")!!, result)
            "removeDevice" -> removeDevice(call.argument("deviceId")!!, result)
            "reportIssue" -> reportIssue(
                call.argument("email")!!,
                call.argument("issue")!!,
                call.argument("description")!!,
                result
            )

            "applyRefCode" -> paymentsUtil.applyRefCode(call.argument("refCode")!!, result)
            "redeemResellerCode" -> paymentsUtil.redeemResellerCode(
                call.argument("email")!!, call.argument("resellerCode")!!, result
            )

            "refreshAppsList" -> {
                updateAppsData()
                result.success(null)
            }


            "submitGooglePlayPayment" -> paymentsUtil.submitGooglePlayPayment(
                call.argument("email")!!,
                call.argument("planID")!!,
                result,
            )

            "submitStripePayment" -> paymentsUtil.submitStripePayment(
                call.argument("planID")!!,
                call.argument("email")!!,
                call.argument("cardNumber")!!,
                call.argument("expDate")!!,
                call.argument("cvc")!!,
                result,
            )

            "generatePaymentRedirectUrl" -> paymentsUtil.generatePaymentRedirectUrl(
                call.argument("planID")!!,
                call.argument("email")!!,
                call.argument("provider")!!,
                result,
            )

            "userStatus" -> userStatus(result)
            "updatePaymentPlans" -> updatePaymentMethods(result)
            "setLanguage" -> {
                LanternApp.getSession().setLanguage(call.argument("lang"))
                fetchPaymentMethods(result)
            }
            else -> super.doOnMethodCall(call, result)
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "openWebview" -> {
                val url = call.argument("url") ?: ""
                if (url.isNotEmpty()) {
                    val intent = Intent(activity, WebViewActivity_::class.java)
                    intent.putExtra("url", url.trim())
                    activity.startActivity(intent)
                } else {
                    throw IllegalArgumentException("No URL provided for webview")
                }

            }

            "trackUserAction" -> {
                val props: Map<String, String> = mapOf("title" to call.argument("title")!!)
                Plausible.event(
                    call.argument("name")!!, url = call.argument("url")!!, props = props
                )
            }

            "acceptTerms" -> {
                LanternApp.getSession().acceptTerms()
            }

            "setPaymentTestMode" -> {
                LanternApp.getSession().setPaymentTestMode(call.argument("on") ?: false)
                activity.restartApp()
            }

            "setPlayVersion" -> {
                LanternApp.getSession().isStoreVersion = call.argument("on") ?: false
                activity.restartApp()
            }

            "setForceCountry" -> {
                LanternApp.getSession().setForceCountry(call.argument("countryCode") ?: "")
                activity.restartApp()
            }

            "setSelectedTab" -> {
                db.mutate { tx ->
                    tx.put(PATH_SELECTED_TAB, call.argument<String>("tab")!!)
                }
            }

            "submitFreekassa" -> {
                val userEmail = call.argument("email") ?: ""
                val planID = call.argument("planID") ?: ""
                val currencyPrice = call.argument("currencyPrice") ?: ""
                activity.startActivity(
                    Intent(activity, FreeKassaActivity_::class.java).apply {
                        putExtra("userEmail", userEmail)
                        putExtra("planID", planID)
                        putExtra("currencyPrice", currencyPrice)
                    },
                )
            }

            "checkForUpdates" -> {
                autoUpdater.checkForUpdates()
            }

            "setSplitTunneling" -> {
                val on = call.argument("on") ?: false
                saveSplitTunneling(on)
            }

            "allowAppAccess" -> {
                updateAppData(call.argument("packageName")!!, true)
            }

            "denyAppAccess" -> {
                updateAppData(call.argument("packageName")!!, false)
            }

            else -> super.doMethodCall(call, notImplemented)
        }
    }

    private fun shouldShowAdsBasedRegion(shouldShow: () -> Boolean): Boolean {
        //We just need to check VPN permissions
        // if user tried to remove then we need to check
        // all other configurations are coming from backend
        val session = LanternApp.getSession()
        val hasAllNetworkPermissions = PermissionUtil.missingPermissions(activity).isEmpty()
        return shouldShow() && hasAllNetworkPermissions && session.hasFirstSessionCompleted()
    }

    fun splitTunnelingEnabled(): Boolean {
        return db.get(PATH_SPLIT_TUNNELING) ?: false
    }

    private fun saveSplitTunneling(value: Boolean) {
        db.mutate { tx ->
            tx.put(PATH_SPLIT_TUNNELING, value)
        }
    }

    fun updatePaymentMethods(result: MethodChannel.Result?) {
        val userId = LanternApp.getSession().userId()
        //Check if not found then call createUserAndFetchPaymentMethods
        if (userId == 0L) {
            createUserAndFetchPaymentMethods(result)
        } else {
            fetchPaymentMethods(result)
        }
    }

    private fun createUserAndFetchPaymentMethods(result: MethodChannel.Result?) {
        lanternClient.createUser(object : ProUserCallback {
            override fun onFailure(t: Throwable?, error: ProError?) {
                handleFailure(result, "payment_method_fail", error?.id, t)
            }

            override fun onSuccess(response: Response, userData: ProUser) {
                LanternApp.getSession().setUserIdAndToken(userData.userId, userData.token)
                fetchPaymentMethods(result)
            }
        })
    }

    private fun fetchPaymentMethods(result: MethodChannel.Result?) {
        lanternClient.plansV4(object : LanternHttpClient.PlansV3Callback {
            override fun onSuccess(
                proPlans: Map<String, ProPlan>, paymentMethods: List<PaymentMethods>
            ) {
                Logger.debug(
                    TAG,
                    "Successfully payment proplan $proPlans and methods $paymentMethods"
                )
                processPaymentMethods(proPlans, paymentMethods)
                result?.success("Payment method successfully updated")
            }

            override fun onFailure(throwable: Throwable?, error: ProError?) {
                handleFailure(result, "payment_method_fail", error?.id, throwable)
            }
        })
    }

    private fun handleFailure(
        result: MethodChannel.Result?,
        errorId: String,
        errorCode: String?,
        throwable: Throwable?
    ) {
        result?.let {
            activity.runOnUiThread {
                it.error(errorId, errorCode, null)
            }
        }
        Logger.error(
            TAG, "Unable to update payment methods: $errorId (code: $errorCode)", throwable
        )
    }


    fun processPaymentMethods(
        proPlans: Map<String, ProPlan>,
        paymentMethods: List<PaymentMethods>,

        ) {
        for (planId in proPlans.keys) {
            proPlans[planId]?.let { PlansUtil.updatePrice(activity, it) }
        }
        LanternApp.getSession().setUserPlans(proPlans)
        LanternApp.getSession().setPaymentMethods(paymentMethods)
    }

    // updateAppData looks up the app data for the given package name and updates whether or
    // not the app is allowed access to the VPN connection in the database
    private fun updateAppData(packageName: String, allowedAccess: Boolean) {
        db.mutate { tx ->
            var appData = tx.get<Vpn.AppData>(PATH_APPS_DATA + packageName)
            appData?.let {
                tx.put(
                    PATH_APPS_DATA + packageName,
                    Vpn.AppData.newBuilder().setPackageName(it.packageName).setIcon(it.icon)
                        .setName(it.name).setAllowedAccess(allowedAccess).build()
                )
            }
        }
    }

    // updateAppsData stores app data for the list of applications installed for the current
    // user in the database
    private fun updateAppsData() {
        // This can be quite slow, run it on its own coroutine
        CoroutineScope(Dispatchers.IO).launch {
            val appsList = appsDataProvider.listOfApps()
            // First add just the app names to get a list quickly
            db.mutate { tx ->
                appsList.forEach {
                    val path = PATH_APPS_DATA + it.packageName
                    if (!tx.contains(path)) {
                        // App not already in list, add it
                        tx.put(
                            path,
                            Vpn.AppData.newBuilder().setPackageName(it.packageName).setName(it.name)
                                .setIcon(ByteString.copyFrom(it.icon)).build()
                        )
                    }
                }
            }

        }
    }

    private fun confirmEmailError(error: ProError) {
        val errorId = error.id
        val resources = activity.resources
        if (errorId.equals("existing-email")) {
            activity.showErrorDialog(resources.getString(R.string.email_in_use))
        } else if (error.message != null) {
            activity.showErrorDialog(error.message)
        }
    }

    private fun requestLinkCode(methodCallResult: MethodChannel.Result) {
        val formBody =
            FormBody.Builder().add("deviceName", LanternApp.getSession().deviceName()).build()
        lanternClient.post(
            LanternHttpClient.createProUrl("/link-code-request"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error == null) {
                        activity.runOnUiThread {
                            methodCallResult.error("unknownError", null, null)
                        }
                        return
                    }
                    val errorId = error.id
                    activity.runOnUiThread {
                        methodCallResult.error("linkCodeError", errorId, null)
                    }
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    result?.let {
                        if (result["code"] == null || result["expireAt"] == null) return
                        val code = result["code"].asString
                        val expireAt = result["expireAt"].asLong
                        LanternApp.getSession().setDeviceCode(code, expireAt)
                        methodCallResult.success(code)
                    }
                }
            },
        )
    }

    private fun redeemLinkCode(methodCallResult: MethodChannel.Result) {
        val formBody = FormBody.Builder().add("code", LanternApp.getSession().deviceCode()!!)
            .add("deviceName", LanternApp.getSession().deviceName()).build()
        Logger.info(TAG, "Redeeming link code")
        lanternClient.post(
            LanternHttpClient.createProUrl("/link-code-redeem"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Error making link redeem request..", t)
                    if (error == null) {
                        activity.runOnUiThread {
                            methodCallResult.error("unknownError", null, null)
                        }
                        return
                    }
                    activity.runOnUiThread {
                        methodCallResult.error("linkCodeError", error.id, null)
                    }
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    Logger.debug(TAG, "redeem link code response: $result")
                    if (result == null || result["token"] == null || result["userID"] == null) return
                    Logger.debug(TAG, "Successfully redeemed link code")
                    val userID = result["userID"].asLong
                    val token = result["token"].asString
                    //Set the new user id
                    LanternApp.getSession().setUserIdAndToken(userID, token)
                    //Refresh all the user data
                    lanternClient.userData(object : ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.debug(TAG, "Successfully updated userData")
                            activity.runOnUiThread {
                                //todo find better solution restart the app is the good option
                                //Restart the app
                                val intent = Intent(activity, MainActivity::class.java).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                                }
                                activity.startActivity(intent)
//                                methodCallResult.success("redeemedLinkCode")

                            }
                        }

                        override fun onFailure(t: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $t.message")
                            methodCallResult.error(
                                "errorUpdatingUserData", t?.message, error?.message
                            )
                        }
                    })

                    // methodCallResult.success(null)
                }
            },
        )
    }

    private fun checkEmailExists(emailAddress: String, methodCallResult: MethodChannel.Result) {
        val params = mapOf("email" to emailAddress)
        val isPlayVersion = LanternApp.getSession().isStoreVersion()
        val useStripe = !isPlayVersion
        lanternClient.get(
            LanternHttpClient.createProUrl("/email-exists", params),
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error != null) confirmEmailError(error)
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    Logger.debug(TAG, "Email successfully validated " + emailAddress)
                    LanternApp.getSession().setEmail(emailAddress)
                }
            },
        )
    }

    private fun requestRecoveryEmail(emailAddress: String, methodCallResult: MethodChannel.Result) {
        val session = LanternApp.getSession()
        session.setEmail(emailAddress)
        val formBody =
            FormBody.Builder().add("email", emailAddress).add("deviceName", session.deviceName())
                .add("locale", session.locale()).build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/user-link-request"),
            formBody,
            object : ProCallback {
                override fun onSuccess(response: Response?, result: JsonObject?) {
                    activity.runOnUiThread {
                        methodCallResult.success("Recovery code sent")
                    }
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Failure on  requestRecoveryEmail", error)
                    activity.runOnUiThread {
                        methodCallResult.error("unknownError", t?.message, null)
                    }
                }
            },
        )
    }

    private fun sendRecoveryCode(methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Sending link request...")
        lanternClient.sendLinkRequest(object : ProCallback {
            override fun onSuccess(response: Response?, result: JsonObject?) {
                activity.runOnUiThread {
                    methodCallResult.success("needPin")
                }
            }

            override fun onFailure(t: Throwable?, error: ProError?) {
                activity.runOnUiThread {
                    methodCallResult.error("unableToRequestRecoveryCode", t?.message, null)
                }
                activity.showErrorDialog(activity.resources.getString(R.string.unknown_error))
            }
        })
    }

    private fun validateRecoveryCode(code: String, methodCallResult: MethodChannel.Result) {
        val formBody: RequestBody = FormBody.Builder().add("code", code).build()
        Logger.debug(TAG, "Validating link request; code:$code")
        lanternClient.post(
            LanternHttpClient.createProUrl("/user-link-validate"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Unable to validate link code", t)
                    activity.runOnUiThread {
                        methodCallResult.error(
                            "unableToVerifyRecoveryCode", t?.message, error?.message
                        )
                    }
                    if (error == null) {
                        Logger.error(TAG, "Unable to validate recovery code and no error to show")
                        return
                    }
                    val errorId = error.id
                    if (errorId == "too-many-devices") {
                        activity.showErrorDialog(activity.resources.getString(R.string.too_many_devices))
                    } else if (error.message != null) {
                        activity.showErrorDialog(error.message)
                    }
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    if (result != null && result["token"] != null && result["userID"] != null) {
                        Logger.debug(TAG, "Successfully validated recovery code")
                        // update token and user ID with those returned by the pro server
                        // update token and user ID with those returned by the pro server
                        LanternApp.getSession()
                            .setUserIdAndToken(result["userID"].asLong, result["token"].asString)
                        LanternApp.getSession().linkDevice()
                        LanternApp.getSession().setIsProUser(true)
                        activity.runOnUiThread {
                            methodCallResult.success(
                                activity.getString(R.string.device_added),
                            )
                        }
                    }
                }
            },
        )
    }

    private fun approveDevice(code: String, methodCallResult: MethodChannel.Result) {
        val formBody: RequestBody = FormBody.Builder().add("code", code).build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/link-code-approve"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Error approving device link code: $error")
                    activity.runOnUiThread {
                        val errorMessage =
                            activity.resources.getString(R.string.invalid_verification_code)
                        methodCallResult.error("errorApprovingDevice", errorMessage, errorMessage)
                    }
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    //Add one second dealy to api
                    Thread.sleep(1000)
                    lanternClient.userData(object : ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.debug(TAG, "Successfully updated userData")
                            activity.runOnUiThread {
                                methodCallResult.success("approvedDevice")
                            }
                        }

                        override fun onFailure(t: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $t.message")
                            methodCallResult.error(
                                "errorUpdatingUserData", t?.message, error?.message
                            )
                        }
                    })
                }
            },
        )
    }

    private fun reportIssue(
        email: String, issue: String, description: String, methodCallResult: MethodChannel.Result
    ) {
        if (!Utils.isNetworkAvailable(activity)) {
            methodCallResult.error(
                "errorReportingIssue", activity.getString(R.string.no_internet_connection), null
            )
            return
        }
        Logger.debug(TAG, "Reporting $issue issue on behalf of $email")
        LanternApp.getSession().setEmail(email)
        val issueReporter = IssueReporter(
            activity,
            issue,
            description,
            methodCallResult,
        )
        issueReporter.reportIssue()
    }

    private fun removeDevice(deviceId: String, methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Removing device $deviceId")
        val formBody: RequestBody = FormBody.Builder().add("deviceID", deviceId).build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/user-link-remove"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error != null) {
                        Logger.error(TAG, "Error removing device: $error")
                    }
                    activity.runOnUiThread {
                        methodCallResult.error("errorApprovingDevice", t?.message, error?.message)
                    }
                    // encountered some issue removing the device; display an error
                    activity.showErrorDialog(activity.resources.getString(R.string.unable_remove_device))
                }

                override fun onSuccess(response: Response?, result: JsonObject?) {
                    Logger.debug(TAG, "Successfully removed device")

                    val isLogout = deviceId == LanternApp.getSession().deviceID
                    if (isLogout) {
                        // if one of the devices we removed is the current device
                        // make sure to logout
                        Logger.debug(TAG, "Logging out")
                        LanternApp.getSession().logout()
                        activity.restartApp()
                        return
                    }

                    lanternClient.userData(object : ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.debug(TAG, "Successfully updated userData")
                            activity.runOnUiThread {
                                methodCallResult.success("removedDevice")
                            }
                        }

                        override fun onFailure(t: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $t.message")
                            methodCallResult.error(
                                "errorUpdatingUserData", t?.message, error?.message
                            )
                        }
                    })
                }
            },
        )
    }

    // Hits the /user-data endpoint and saves { userLevel: null | "pro" | "platinum" } to PATH_USER_LEVEL
    private fun userStatus(result: MethodChannel.Result) {
        try {
            lanternClient.userData(object : ProUserCallback {
                override fun onSuccess(response: Response, userData: ProUser) {
                    Logger.debug(TAG, "Successfully updated userData")
                    result.success("cachingUserDataSuccess")
                    LanternApp.getSession().setUserLevel(userData.userLevel)
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Unable to fetch user data: $t.message")
                    result.error(
                        "cachingUserDataError", "Unable to cache user status", error?.message
                    ) // This will be localized Flutter-side
                    return
                }
            })
        } catch (t: Throwable) {
            Logger.error(TAG, "Error caching user status", t)
            result.error(
                "unknownError", "Unable to cache user status", null
            ) // This will be localized Flutter-side
        }
    }

    fun saveServerInfo(serverInfo: Vpn.ServerInfo) {
        db.mutate { tx ->
            tx.put(PATH_SERVER_INFO, serverInfo)
        }
    }
}
