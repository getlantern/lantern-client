package io.lantern.model

import android.app.Activity
import android.content.Intent
import androidx.core.content.ContextCompat
import com.google.gson.JsonObject
import internalsdk.Internalsdk
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import okhttp3.FormBody
import okhttp3.RequestBody
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.FreeKassaActivity_
import org.getlantern.lantern.activity.WebViewActivity_
import org.getlantern.lantern.model.CheckUpdate
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternHttpClient.ProCallback
import org.getlantern.lantern.model.LanternHttpClient.ProUserCallback
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.openHome
import org.getlantern.lantern.restartApp
import org.getlantern.lantern.util.PaymentsUtil
import org.getlantern.lantern.util.castToBoolean
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.SessionManager
import org.greenrobot.eventbus.EventBus
import java.util.concurrent.*

/**
 * This is a model that uses the same db schema as the preferences in SessionManager so that those
 * settings can be observed.
 */
class SessionModel(
    private val activity: Activity,
    flutterEngine: FlutterEngine,
) : BaseModel("session", flutterEngine, LanternApp.getSession().db) {
    private val lanternClient = LanternApp.getLanternHttpClient()
    private val paymentsUtil = PaymentsUtil(activity)

    companion object {
        private const val TAG = "SessionModel"
        const val PATH_PRO_USER = "prouser"
        const val PATH_PLAY_VERSION = "playVersion"

        const val PATH_SDK_VERSION = "sdkVersion"
        const val PATH_USER_LEVEL = "userLevel"
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
            // hard disable chat
            tx.put(SessionManager.CHAT_ENABLED, false)
            tx.put(PATH_SDK_VERSION, Internalsdk.sdkVersion())
        }
    }

    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "authorizeViaEmail" -> authorizeViaEmail(call.argument("emailAddress")!!, result)
            "checkEmailExists" -> checkEmailExists(call.argument("emailAddress")!!, result)
            "resendRecoveryCode" -> sendRecoveryCode(result)
            "validateRecoveryCode" -> validateRecoveryCode(call.argument("code")!!, result)
            "approveDevice" -> approveDevice(call.argument("code")!!, result)
            "removeDevice" -> removeDevice(call.argument("deviceId")!!, result)
            "applyRefCode" -> paymentsUtil.applyRefCode(call.argument("refCode")!!, result)
            "redeemResellerCode" -> paymentsUtil.redeemResellerCode(call.argument("email")!!, call.argument("resellerCode")!!, result)
            "submitBitcoinPayment" -> paymentsUtil.submitBitcoinPayment(
                call.argument("planID")!!,
                call.argument("email")!!,
                call.argument("refCode")!!,
                result,
            )
            "submitGooglePlayPayment" -> paymentsUtil.submitGooglePlayPayment(
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
            "userStatus" -> userStatus(result)
            else -> super.doOnMethodCall(call, result)
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "openWebview" -> {
                val url = call.argument("url") ?: ""
                url.isNotEmpty().let {
                    val intent = Intent(activity, WebViewActivity_::class.java)
                    intent.putExtra("url", url)
                    activity.startActivity(intent)
                }
            }
            "setLanguage" -> {
                LanternApp.getSession().setLanguage(call.argument("lang"))
            }
            "setPaymentTestMode" -> {
                LanternApp.getSession().setPaymentTestMode(call.argument("on") ?: false)
                activity.restartApp()
            }
            "setPlayVersion" -> {
                LanternApp.getSession().isPlayVersion = call.argument("on") ?: false
                activity.restartApp()
            }
            "setForceCountry" -> {
                LanternApp.getSession().setForceCountry(call.argument("countryCode") ?: "")
                activity.restartApp()
            }
            "setSelectedTab" -> {
                db.mutate { tx ->
                    tx.put("/selectedTab", call.argument<String>("tab")!!)
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
                EventBus.getDefault().post(CheckUpdate(true))
            }
            else -> super.doMethodCall(call, notImplemented)
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

    private fun checkEmailExists(emailAddress: String, methodCallResult: MethodChannel.Result) {
        val params = mapOf("email" to emailAddress)
        val isPlayVersion = LanternApp.getSession().isPlayVersion()
        val useStripe = !isPlayVersion && !LanternApp.getSession().defaultToAlipay()
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

    private fun authorizeViaEmail(emailAddress: String, methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Start Account recovery with email $emailAddress")

        LanternApp.getSession().setEmail(emailAddress)
        val formBody = FormBody.Builder()
            .add("email", emailAddress)
            .build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/user-recover"),
            formBody,
            object : ProCallback {
                override fun onSuccess(response: Response?, result: JsonObject?) {
                    Logger.debug(TAG, "Account recovery response: $result")
                    if (result!!["token"] != null && result["userID"] != null) {
                        Logger.debug(TAG, "Successfully recovered account")
                        // update token and user ID with those returned by the pro server
                        LanternApp.getSession().setUserIdAndToken(result["userID"].asLong, result["token"].asString)
                        LanternApp.getSession().linkDevice()
                        LanternApp.getSession().setIsProUser(true)
                        activity.showAlertDialog(
                            activity.getString(R.string.device_added),
                            activity.getString(R.string.device_authorized_pro),
                            ContextCompat.getDrawable(activity, R.drawable.ic_filled_check),
                            {
                                activity.openHome()
                            },
                        )
                    } else {
                        Logger.error(TAG, "Got empty recovery result, can't continue")
                        activity.runOnUiThread {
                            methodCallResult.error("unknownError", null, null)
                        }
                        return
                    }
                }

                override fun onFailure(t: Throwable?, error: ProError?) {
                    if (error == null) {
                        Logger.error(TAG, "Unable to recover account and no error to show")
                        activity.runOnUiThread {
                            methodCallResult.error("unknownError", t?.message, null)
                        }
                        return
                    }

                    val errorId = error.id
                    if (errorId == "wrong-device") {
                        sendRecoveryCode(methodCallResult)
                    } else if (errorId == "wrong-email" || errorId == "cannot-recover-user") {
                        activity.runOnUiThread {
                            methodCallResult.error("unableToRecover", errorId, null)
                        }
                        activity.showErrorDialog(activity.resources.getString(R.string.cannot_find_email))
                    } else {
                        Logger.error(TAG, "Unknown error recovering account:$error")
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
        val formBody: RequestBody = FormBody.Builder()
            .add("code", code)
            .build()
        Logger.debug(TAG, "Validating link request; code:$code")
        lanternClient.post(
            LanternHttpClient.createProUrl("/user-link-validate"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Unable to validate link code", t)
                    activity.runOnUiThread {
                        methodCallResult.error("unableToVerifyRecoveryCode", t?.message, error?.message)
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

                override fun onSuccess(response: Response, result: JsonObject) {
                    Logger.debug(TAG, "Response: $result")
                    if (result["token"] != null && result["userID"] != null) {
                        Logger.debug(TAG, "Successfully validated recovery code")
                        // update token and user ID with those returned by the pro server
                        // update token and user ID with those returned by the pro server
                        LanternApp.getSession().setUserIdAndToken(result["userID"].asLong, result["token"].asString)
                        LanternApp.getSession().linkDevice()
                        LanternApp.getSession().setIsProUser(true)
                        activity.showAlertDialog(activity.getString(R.string.device_added), activity.getString(R.string.device_authorized_pro), ContextCompat.getDrawable(activity, R.drawable.ic_filled_check), { activity.openHome() })
                    }
                }
            },
        )
    }

    private fun approveDevice(code: String, methodCallResult: MethodChannel.Result) {
        val formBody: RequestBody = FormBody.Builder()
            .add("code", code)
            .build()

        lanternClient.post(
            LanternHttpClient.createProUrl("/link-code-approve"),
            formBody,
            object : ProCallback {
                override fun onFailure(t: Throwable?, error: ProError?) {
                    Logger.error(TAG, "Error approving device link code: $error")
                    activity.runOnUiThread {
                        methodCallResult.error("errorApprovingDevice", t?.message, error?.message)
                    }
                    activity.showErrorDialog(activity.resources.getString(R.string.invalid_verification_code))
                }

                override fun onSuccess(response: Response, result: JsonObject) {
                    lanternClient.userData(object : ProUserCallback {
                        override fun onSuccess(response: Response, userData: ProUser) {
                            Logger.debug(TAG, "Successfully updated userData")
                            activity.runOnUiThread {
                                methodCallResult.success("approvedDevice")
                            }
                            activity.showAlertDialog(activity.resources.getString(R.string.device_added), activity.resources.getString(R.string.device_authorized_pro), ContextCompat.getDrawable(activity, R.drawable.ic_filled_check))
                        }

                        override fun onFailure(t: Throwable?, error: ProError?) {
                            Logger.error(TAG, "Unable to fetch user data: $t.message")
                            methodCallResult.error("errorUpdatingUserData", t?.message, error?.message)
                        }
                    })
                }
            },
        )
    }

    private fun removeDevice(deviceId: String, methodCallResult: MethodChannel.Result) {
        Logger.debug(TAG, "Removing device $deviceId")
        val formBody: RequestBody = FormBody.Builder()
            .add("deviceID", deviceId)
            .build()

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

                override fun onSuccess(response: Response, result: JsonObject) {
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
                            methodCallResult.error("errorUpdatingUserData", t?.message, error?.message)
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
                    result.error("cachingUserDataError", "Unable to cache user status", error?.message) // This will be localized Flutter-side
                    return
                }
            })
        } catch (t: Throwable) {
            Logger.error(TAG, "Error caching user status", t)
            result.error("unknownError", "Unable to cache user status", null) // This will be localized Flutter-side
        }
    }
}
