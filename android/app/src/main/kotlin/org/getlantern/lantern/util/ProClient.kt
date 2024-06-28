package org.getlantern.lantern.util

import internalsdk.Internalsdk
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.event.EventHandler
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.LanternStatus.Status
import org.getlantern.lantern.model.PaymentMethods
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.model.ProUser
import org.getlantern.mobilesdk.Logger

abstract class APIResponse(
    var error: String? = null,
    var errorId: String = "",
    var status: String = ""
)

data class PaymentMethodsResponse(
    val providers: Map<String, List<PaymentMethods>>? = null,
    val plans: Map<String, ProPlan>,
) : APIResponse()

object ProClient {
    private val proClient = Internalsdk.newProClient(LanternApp.getSession())
    private val session = LanternApp.getSession()
    private const val TAG = "ProClient"

    fun updateUserData() {
        val response = proClient.userData()
        val proUser: ProUser? = JsonUtil.fromJson<ProUser>(response)
        proUser?.let { session.storeUserData(it) }
    }

    fun createUser(callback: ((user: ProUser) -> Unit)? = null) {
        try {
          val response = proClient.userCreate()
          val user: ProUser? = JsonUtil.fromJson<ProUser>(response)
          user?.let {
            Logger.debug(TAG, "Created new Lantern user: ${it.newUserDetails()}")
            session.setUserIdAndToken(it.userId, it.token)
            if (callback != null) callback(it)
            EventHandler.postStatusEvent(LanternStatus(Status.ON))
            EventHandler.postAccountInitializationStatus(AccountInitializationStatus.Status.SUCCESS)
          }
        } catch (e:Exception) {
          Logger.error(TAG, "Error creating new user: $e", e)
        }
    }

    fun updatePaymentMethods(callback: ((proPlans: Map<String, ProPlan>, paymentMethods: List<PaymentMethods>) -> Unit)? = null) {
        val response: PaymentMethodsResponse? = JsonUtil.fromJson<PaymentMethodsResponse>(proClient.paymentMethods())
        response?.let {
            val paymentMethods = it.providers?.get("android")
            val proPlans = it.plans
            Logger.debug(TAG, "Successfully fetched payment methods with payment methods: $paymentMethods and plans $proPlans")
            if (callback != null && paymentMethods != null) callback(proPlans, paymentMethods)
        }
    }

    fun updateCurrenciesList() {
        val response = proClient.currenciesList()
        val currencies: List<String>? = JsonUtil.fromJson<List<String>>(response)
        currencies?.let { session.setCurrencyList(it) }
    }
}