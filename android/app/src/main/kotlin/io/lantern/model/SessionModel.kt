package io.lantern.model

import android.app.Activity
import android.content.Intent
import android.view.WindowManager
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
import org.getlantern.lantern.model.PaymentMethods
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.plausible.Plausible
import org.getlantern.lantern.util.AuthClient 
import org.getlantern.lantern.util.AutoUpdater
import org.getlantern.lantern.util.PaymentsUtil
import org.getlantern.lantern.util.PermissionUtil
import org.getlantern.lantern.util.ProClient
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
    private val autoUpdater = AutoUpdater(activity, activity)
    private val paymentsUtil = PaymentsUtil(activity)

    companion object {
        private const val TAG = "SessionModel"
        const val PATH_PRO_USER = "prouser"
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
                PATH_USER_LEVEL,
                tx.get(PATH_USER_LEVEL) ?: "",
            )
            tx.put(
                PATH_SPLIT_TUNNELING, castToBoolean(tx.get(PATH_SPLIT_TUNNELING), false)
            )
            // hard disable chat
            tx.put(SessionManager.CHAT_ENABLED, false)
            tx.put(
                SessionManager.USER_LOGGED_IN, castToBoolean(tx.get(SessionManager.USER_LOGGED_IN), false)
            )
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
            "enableScreenshot" -> {
                activity.runOnUiThread {
                    activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                Logger.debug("Screenshot enabled", "Screenshot enabled")
            }

            "disableScreenshot" -> {
                activity.runOnUiThread {
                    activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                Logger.debug("Screenshot disable", "Screenshot disabled")
            }

            "authorizeViaEmail" -> requestRecoveryEmail(call.argument("emailAddress")!!, result)
            "requestLinkCode" -> ProClient.requestLinkCode({ code -> result.success(code) })
            "redeemLinkCode" -> redeemLinkCode(result)
            //"resendRecoveryCode" -> sendRecoveryCode(result)
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

            "login" -> {
                AuthClient.signIn(call.argument("email")!!, call.argument("password")!!, { resp ->
                    LanternApp.getSession().setUserLoggedIn(true)
                })
            }

            "signout" -> {
                AuthClient.signOut()
            }

            "signup" -> {
                AuthClient.signUp(call.argument("email")!!, call.argument("password")!!, { resp ->
                    LanternApp.getSession().setUserLoggedIn(true)
                })
            }

            "startRecoveryByEmail" -> {
                AuthClient.startRecoveryByEmail(call.argument("email")!!)
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

    private fun fetchPaymentMethods(result: MethodChannel.Result?) {
        ProClient.updatePaymentMethods(activity, { proPlans, paymentMethods ->
            result?.success("Payment method successfully updated")
        })
    }

    private fun updatePaymentMethods(result: MethodChannel.Result?) {
        val userId = LanternApp.getSession().userId()
        // Check if not found then call createUser
        if (userId == 0L) {
            ProClient.createUser({ _ -> fetchPaymentMethods(result) })
        } else {
            fetchPaymentMethods(result)
        }
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
        LanternApp.getSession().setUserPlans(activity, proPlans)
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

    private fun redeemLinkCode(methodCallResult: MethodChannel.Result) {
        val code = LanternApp.getSession().deviceCode()!!
        ProClient.redeemLinkCode(code, { result ->
            Logger.debug(TAG, "Successfully redeemed link code")
            activity.runOnUiThread {
                val intent = Intent(activity, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                }
                activity.startActivity(intent)
            }
        })
    }

    private fun requestRecoveryEmail(emailAddress: String, methodCallResult: MethodChannel.Result) {
        val session = LanternApp.getSession()
        session.setEmail(emailAddress)
        ProClient.requestRecoveryEmail(session.deviceName(), { _ -> 
            activity.runOnUiThread {
                methodCallResult.success("Recovery code sent")
            }
        })
    }

    private fun validateRecoveryCode(code: String, methodCallResult: MethodChannel.Result) {
        val formBody: RequestBody = FormBody.Builder().add("code", code).build()
        Logger.debug(TAG, "Validating link request; code:$code")
        ProClient.userLinkValidate(code, { it -> 
            // update token and user ID with those returned by the pro server
            LanternApp.getSession().setUserIdAndToken(it.userID, it.token)
            LanternApp.getSession().linkDevice()
            LanternApp.getSession().setIsProUser(true)
            activity.runOnUiThread {
                methodCallResult.success(activity.getString(R.string.device_added))
            }
        })
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
        ProClient.removeDevice(deviceId, { response -> 
            methodCallResult.success("approvedDevice")
            val isLogout = deviceId == LanternApp.getSession().deviceID
            if (isLogout) {
                LanternApp.getSession().logout()
                activity.restartApp()
            } else {
                ProClient.updateUserData()
            }
        })
    }

    private fun approveDevice(code: String, methodCallResult: MethodChannel.Result) {
        ProClient.approveDevice(code, { code -> methodCallResult.success("approvedDevice") })
    }

    // Hits the /user-data endpoint and saves { userLevel: null | "pro" | "platinum" } to PATH_USER_LEVEL
    private fun userStatus(result: MethodChannel.Result) {
        ProClient.updateUserData({ user -> 
            result.success("cachingUserDataSuccess")
            LanternApp.getSession().setUserLevel(user.userLevel)
        })
    }

    fun saveServerInfo(serverInfo: Vpn.ServerInfo) {
        db.mutate { tx ->
            tx.put(PATH_SERVER_INFO, serverInfo)
        }
    }
}
