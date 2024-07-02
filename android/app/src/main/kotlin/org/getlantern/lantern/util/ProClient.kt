package org.getlantern.lantern.util

import internalsdk.Internalsdk
import com.google.gson.JsonObject
import android.content.Context
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.event.EventHandler
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.PaymentMethods
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.model.ProUser
import org.getlantern.mobilesdk.Logger
import org.getlantern.lantern.R

abstract class APIResponse(
    var error: String? = null,
    var errorId: String = "",
    var status: String = "",
)

data class PaymentMethodsResponse(
    val icons: Map<String, List<String>>? = null,
    val providers: Map<String, List<PaymentMethods>>? = null,
    val plans: Map<String, ProPlan>,
) : APIResponse()

data class PaymentRedirectResponse(
    val redirectURL: String,
) : APIResponse()

data class LinkCodeResponse(
    val code: String,
    val expireAt: Long,
) : APIResponse()

data class LinkCodeRedeemResponse(
    val token: String,
    val userID: Long,
) : APIResponse()

typealias Callback = (APIResponse) -> Unit

object ProClient {
    private val proClient = Internalsdk.newProClient(LanternApp.getSession())
    private val session = LanternApp.getSession()
    private const val TAG = "ProClient"

    fun updateUserData(callback: ((user: ProUser) -> Unit)? = null) {
        val response = proClient.userData()
        val proUser: ProUser? = JsonUtil.fromJson<ProUser>(response)
        proUser?.let { 
            session.storeUserData(it)
            callback?.invoke(it) 
        }
    }

    fun createUser(callback: ((user: ProUser) -> Unit)? = null) {
        try {
            val response = proClient.userCreate()
            val user: ProUser? = JsonUtil.fromJson<ProUser>(response)
            user?.let {
                Logger.debug(TAG, "Created new Lantern user: ${it.newUserDetails()}")
                session.setUserIdAndToken(it.userId, it.token)
                callback?.invoke(it)
                EventHandler.postStatusEvent(LanternStatus.On)
                EventHandler.postAccountInitializationStatus(AccountInitializationStatus.Status.SUCCESS)
            }
        } catch (e: Exception) {
            Logger.error(TAG, "Error creating new user: $e", e)
        }
    }

    fun requestLinkCode(callback: ((code: String) -> Unit)? = null) {
        val response: LinkCodeResponse? =
            JsonUtil.fromJson<LinkCodeResponse>(
                proClient.linkCodeRequest(LanternApp.getSession().deviceName()),
            )
        response?.let {
            LanternApp.getSession().setDeviceCode(it.code, it.expireAt)
            callback?.invoke(it.code)
        }
    }

    fun redeemLinkCode(code: String, callback: ((resp: LinkCodeRedeemResponse) -> Unit)? = null) {
        val response: LinkCodeRedeemResponse? =
            JsonUtil.fromJson<LinkCodeRedeemResponse>(
                proClient.linkCodeRedeem(LanternApp.getSession().deviceName(), code),
            )
        response?.let {
            LanternApp.getSession().setUserIdAndToken(it.userID, it.token)
            callback?.invoke(response)
        }
    }

    fun approveDevice(code: String, callback: Callback? = null) {
        val response: APIResponse? = JsonUtil.fromJson<APIResponse>(proClient.linkCodeApprove(code))
        response?.let { callback?.invoke(response) }
    }

    fun removeDevice(deviceId: String, callback: ((resp: APIResponse) -> Unit)? = null) {
        val response: APIResponse? = JsonUtil.fromJson<APIResponse>(proClient.deviceRemove(deviceId))
        response?.let { callback?.invoke(response) }
    }

    fun userLinkValidate(code: String, callback: ((resp: LinkCodeRedeemResponse) -> Unit)? = null) {
        val response: LinkCodeRedeemResponse? = JsonUtil.fromJson<LinkCodeRedeemResponse>(proClient.userLinkValidate(code))
        response?.let { callback?.invoke(response) }
    }

    fun requestRecoveryEmail(deviceName: String, callback: ((resp: LinkCodeRedeemResponse) -> Unit)? = null) {
        proClient.userLinkCodeRequest(deviceName)
    }

    fun paymentRedirect(
        planID: String,
        email: String,
        provider: String,
        callback: ((redirectURL: String) -> Unit)? = null,
    ) {
        val response: PaymentRedirectResponse? =
            JsonUtil.fromJson<PaymentRedirectResponse>(
                proClient.paymentRedirect(planID, email, provider),
            )
        response?.let { callback?.invoke(it.redirectURL) }
    }

    fun acknowledgePurchase(request: JsonObject) {
        val response: APIResponse? = JsonUtil.fromJson<APIResponse>(proClient.purchase(request.toString()))
        response?.let { Logger.debug(TAG, "Making server acknowledgement response: $response") }
    }

    private fun plansMap(activity: Context, fetched: List<ProPlan>): Map<String, ProPlan> {
        val plans = mutableMapOf<String, ProPlan>()
        for (plan in fetched) {
            plans.put(plan.id, PlansUtil.updatePrice(activity, plan))
        }
        return plans
    }

    fun updatePaymentMethods(activity: Context, callback: ((proPlans: Map<String, ProPlan>, paymentMethods: List<PaymentMethods>) -> Unit)? = null) {
        val result = JsonUtil.asJsonObject(proClient.paymentMethods())
        val methods:Map<String, List<PaymentMethods>>? = JsonUtil.fromJson<Map<String, List<PaymentMethods>>>(result?.get("providers").toString())
        if (methods == null) return
        val providers = methods.get("android")
        // Due to API limitations
        // We need loop all the provider and info since we can multiple provider with multiple methods
        providers?.let {
            providers.forEach { it ->
                it.providers.forEach { provider ->
                    val icons = result?.get("icons")?.asJsonObject
                    val logoJson = icons?.get(
                        provider.name.toString().lowercase()
                    )!!.asJsonArray
                    val logoUrlsList: List<String> =
                        logoJson?.map { it.asString } ?: emptyList()
                    provider.logoUrl = logoUrlsList
                }
            }
        }
        val fetched = JsonUtil.fromJson<List<ProPlan>>(result?.get("plans").toString())
        val plans = plansMap(activity, fetched)
        Logger.debug(TAG, "Successfully fetched payment methods with providers: $providers and plans $plans")
        if (providers != null) callback?.invoke(plans, providers)
    }

    fun updateCurrenciesList() {
        val response = proClient.currenciesList()
        val currencies: List<String>? = JsonUtil.fromJson<List<String>>(response)
        currencies?.let { session.setCurrencyList(it) }
    }
}
