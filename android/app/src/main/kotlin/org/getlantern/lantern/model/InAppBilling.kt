package org.getlantern.lantern.model

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClient.SkuType
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.ConsumeResponseListener
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesResponseListener
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.SkuDetails
import com.android.billingclient.api.SkuDetailsParams
import com.android.billingclient.api.SkuDetailsResponseListener
import org.getlantern.mobilesdk.Logger
import java.util.concurrent.ConcurrentHashMap

open class InAppBilling(val context: Context) : PurchasesUpdatedListener, BillingClientStateListener, ConsumeResponseListener {
    companion object {
        private val TAG = InAppBilling::class.java.simpleName
    }

    private val billingClient: BillingClient = BillingClient.newBuilder(context).enablePendingPurchases().setListener(this).build()
    private val skus: ConcurrentHashMap<String, SkuDetails> = ConcurrentHashMap()
    private val handler = Handler(Looper.getMainLooper())
    private val plans: ConcurrentHashMap<String, ProPlan> = ConcurrentHashMap()

    @Volatile
    private var purchasesUpdated: PurchasesUpdatedListener? = null

    init {
        startConnection()
    }

    fun getPlans():ConcurrentHashMap<String, ProPlan> { return plans }

    private fun startConnection() {
        Logger.d(TAG, "Starting connection")
        billingClient.startConnection(this)
    }

    override fun onBillingServiceDisconnected() {
        Logger.d(TAG, "onBillingServiceDisconnected")
    }

    override fun onConsumeResponse(billingResult: BillingResult, s: String) {}

    private fun BillingResult.responseCodeOK(): Boolean {
        return getResponseCode() == BillingClient.BillingResponseCode.OK
    }

    @Synchronized
    fun startPurchase(activity: Activity, planID: String, cb: PurchasesUpdatedListener): Boolean {
        this.purchasesUpdated = cb
        val skuDetails = skus.get(planID)
        if (skuDetails == null) {
            Logger.e(TAG, "Unable to find sku details for plan: $planID")
            return false
        }
        Logger.d(TAG, "Launching billing flow for plan $planID, sku ${skuDetails.sku}")
        val flowParams = BillingFlowParams.newBuilder()
            .setSkuDetails(skuDetails)
            .build()
        val result = billingClient.launchBillingFlow(activity, flowParams)
        return if (result.responseCodeOK()) {
            true
        } else {
            Logger.e(TAG, "Unexpected response code trying to launch billing flow: ${result.getResponseCode()}")
            false
        }
    }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: List<Purchase>?) {
        Logger.d(TAG, "Purchases updated")
        purchasesUpdated?.let {
            it.onPurchasesUpdated(billingResult, purchases)
            purchasesUpdated = null
        }
    }

    override fun onBillingSetupFinished(billingResult: BillingResult) {
        val responseCode = billingResult.getResponseCode()
        Logger.d(TAG, "onBillingSetupFinished with response code: $responseCode")
        if (billingResult.responseCodeOK()) {
            updateSkus()
            checkForUnacknowledgedPurchases()
            return
        }
        isRetriable(billingResult).then {
            billingClient.endConnection()
            startConnection()
        }
    }

    private fun updateSkus() {
        Logger.d(TAG, "Updating SKUs")
        val skuList = listOf<String>("1y", "2y")
        val params = SkuDetailsParams.newBuilder()
        params.setSkusList(skuList).setType(SkuType.INAPP)
        billingClient.querySkuDetailsAsync(
            params.build(),
            object : SkuDetailsResponseListener {
                override fun onSkuDetailsResponse(billingResult: BillingResult, skuDetailsList: List<SkuDetails>?) {
                    if (!billingResult.responseCodeOK()) {
                        isRetriable(billingResult).then { updateSkus() }
                        return
                    }
                    Logger.d(TAG, "Got ${skuDetailsList?.size} skus")
                    synchronized(this) {
                        plans.clear()
                        skus.clear()
                        skuDetailsList?.forEach {
                            val currency = it.getPriceCurrencyCode().lowercase()
                            val id = "${it.getSku()}-$currency"
                            val years = it.getSku().substring(0, 1)
                            val price = it.getPriceAmountMicros() / 10000
                            val priceWithoutTax = it.getOriginalPriceAmountMicros() / 10000
                            plans.put(
                                id,
                                ProPlan(
                                    id,
                                    hashMapOf(currency to price.toLong()),
                                    hashMapOf(currency to priceWithoutTax.toLong()),
                                    "2" == years,
                                    hashMapOf("years" to years.toInt()),
                                ),
                            )
                            skus.put(id, it)
                        }
                    }
                }
            },
        )
    }

    private inline fun Boolean.then(crossinline block: () -> Unit) {
        if (this) {
            handler.postDelayed(
                Runnable {
                    block()
                },
                5000,
            )
        }
    }

    /**
     * This checks to see if the user has any purchases that we have not yet acknowledged.
     *
     * This can happen if
     *
     * 1. the app was unable to inform the pro server of a purchase right after it was made or
     * 2. the pro server has not yet gotten around to acknowledging the purchase
     *
     * In either case, we'll let the pro-server know about the purchase to make sure that it gets
     * correctly applied to the user's account.
     */
    private fun checkForUnacknowledgedPurchases() {
        Logger.d(TAG, "Checking for pending purchases")
        billingClient.queryPurchasesAsync(
            SkuType.INAPP,
            object : PurchasesResponseListener {
                override fun onQueryPurchasesResponse(billingResult: BillingResult, purchases: List<Purchase?>) {
                    if (!billingResult.responseCodeOK()) {
                        isRetriable(billingResult).then { checkForUnacknowledgedPurchases() }
                        return
                    }
                    Logger.d(TAG, "Got ${purchases.size} purchases")
                    handleAcknowledgedPurchases(purchases)
                }
            },
        )
    }

    private fun handleAcknowledgedPurchases(purchases: List<Purchase?>) {
        for (purchase in purchases) {
            if (purchase == null || !purchase.isAcknowledged()) continue
            // Purchases are acknowledged on the server side. In order to allow further purchasing of the same plan, we have to consume
            // it first, so we do that here. Since we don't actually know what has and what hasn't been consumed, we just do this
            // every time we start up.
            Logger.d(TAG, "Consuming already acknowledged purchase ${purchase.getPurchaseToken()}")
            billingClient.consumeAsync(ConsumeParams.newBuilder().setPurchaseToken(purchase.getPurchaseToken()).build(), this)
        }
    }

    private fun isRetriable(billingResult: BillingResult): Boolean {
        val responseCode = billingResult.getResponseCode()
        val message = billingResult.getDebugMessage()
        return when (responseCode) {
            BillingClient.BillingResponseCode.SERVICE_TIMEOUT,
            BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE,
            BillingClient.BillingResponseCode.USER_CANCELED,
            -> {
                Logger.e(TAG, "Transient error communicating with Google Play Billing, will retry: $responseCode | $message")
                true
            }
            else -> {
                Logger.e(TAG, "Non-transient error communicating with Google Play Billing, will not retry: $responseCode | $message")
                false
            }
        }
    }
}
