package org.getlantern.lantern.model

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.UiThread
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.ConsumeResponseListener
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import org.getlantern.mobilesdk.Logger
import java.util.concurrent.ConcurrentHashMap

class InAppBilling(
    private val context: Context,
    private val builder: BillingClient.Builder = BillingClient.newBuilder(context).enablePendingPurchases(),
    private val googleApiAvailability: GoogleApiAvailability = GoogleApiAvailability.getInstance(),
) : PurchasesUpdatedListener, InAppBillingInterface {
    companion object {
        private val TAG = InAppBilling::class.java.simpleName
    }

    init {
        initConnection()
    }

    @get:Synchronized
    @set:Synchronized
    @Volatile
    private var billingClient: BillingClient? = null

    private val skus: ConcurrentHashMap<String, ProductDetails> = ConcurrentHashMap()
    private val handler = Handler(Looper.getMainLooper())

    val plans: ConcurrentHashMap<String, ProPlan> = ConcurrentHashMap()

    @Volatile
    private var purchasesUpdated: PurchasesUpdatedListener? = null

    override fun initConnection() {
        if (googleApiAvailability.isGooglePlayServicesAvailable(context)
            != ConnectionResult.SUCCESS
        ) {
            Logger.d(TAG, "Google Play services not available on this device")
            return
        }
        if (billingClient?.isReady == true) {
            Logger.d(TAG, "Billing client already initialized")
            return
        }
        builder.setListener(this).build().also {
            billingClient = it
            it.startConnection(
                object : BillingClientStateListener {
                    override fun onBillingSetupFinished(billingResult: BillingResult) {
                        // The BillingClient is ready. You can query purchases here.
                        val responseCode = billingResult.responseCode
                        Logger.d(TAG, "onBillingSetupFinished with response code: $responseCode")
                        if (billingResult.responseCodeOK()) {
                            updateProducts()
                            handlePurchases()
                            return
                        }
                        isRetriable(billingResult).then {
                            endConnection()
                            initConnection()
                        }
                    }

                    override fun onBillingServiceDisconnected() =
                        Logger.d(TAG, "onBillingServiceDisconnected")
                },
            )

        }

        Logger.d(TAG, "Starting connection")
    }

    override fun endConnection() {
        billingClient?.endConnection()
        billingClient = null
    }

    override fun ensureConnected(receivingFunction: BillingClient.() -> Unit) {
        billingClient?.takeIf { it.isReady }?.let {
            it.receivingFunction()
        }
    }


    private fun BillingResult.responseCodeOK() =
        responseCode == BillingClient.BillingResponseCode.OK

    @Synchronized
    fun startPurchase(
        activity: Activity,
        planID: String,
        cb: PurchasesUpdatedListener,
    ) {
        this.purchasesUpdated = cb
        val skuDetails = skus[planID.lowercase()]
        if (skuDetails == null) {
            Logger.e(TAG, "Unable to find sku details for plan: $planID")
            return
        }
        val productDetailsParamsList = listOf(
            BillingFlowParams.ProductDetailsParams.newBuilder()
                .setProductDetails(skuDetails)
                .build()
        )

        Logger.d(TAG, "Launching billing flow for plan $planID, sku ${skuDetails.productId}")
        launchBillingFlow(
            activity,
            BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build(),
        )
    }

    @UiThread
    private fun launchBillingFlow(
        activity: Activity,
        params: BillingFlowParams,
    ) {
        ensureConnected {
            launchBillingFlow(activity, params)
                .takeIf { billingResult -> !billingResult.responseCodeOK() }
                ?.let { result ->
                    Logger.e(
                        TAG,
                        "Unexpected response code trying to launch billing flow: ${result.responseCode}"
                    )
                }
        }
    }

    override fun onPurchasesUpdated(
        billingResult: BillingResult,
        purchases: List<Purchase>?,
    ) {
        Logger.d(TAG, "Purchases updated")
        purchasesUpdated?.let {
            it.onPurchasesUpdated(billingResult, purchases)
            purchasesUpdated = null
        }
    }

    private fun updateProducts() {
        Logger.d(TAG, "Updating SKUs")
        val productList =
            listOf(
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId("1y")
                    .setProductType(BillingClient.ProductType.INAPP)
                    .build(),
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId("2y")
                    .setProductType(BillingClient.ProductType.INAPP)
                    .build()
            )

        val params = QueryProductDetailsParams.newBuilder().setProductList(productList).build()

        ensureConnected {
            queryProductDetailsAsync(params) { billingResult, skuDetailsList ->
                if (!billingResult.responseCodeOK()) {
                    isRetriable(billingResult).then { updateProducts() }
                    return@queryProductDetailsAsync
                }
                Logger.d(TAG, "Got ${skuDetailsList?.size} skus")
                synchronized(this) {
                    plans.clear()
                    skus.clear()
                    skuDetailsList.forEach {
                        val currency =
                            it.oneTimePurchaseOfferDetails!!.priceCurrencyCode.lowercase()
                        val id = it.productId
                        val years = it.productId.substring(0, 1)
                        val price = it.oneTimePurchaseOfferDetails!!.priceAmountMicros / 10000
                        // Todo no originalPriceAmountMicros found in latest lib
                        val priceWithoutTax =
                            it.oneTimePurchaseOfferDetails!!.priceAmountMicros / 10000
                        plans[id] = ProPlan(
                            id,
                            hashMapOf(currency to price.toLong()),
                            hashMapOf(currency to priceWithoutTax.toLong()),
                            "2" == years,
                            hashMapOf("years" to years.toInt()),
                        )
                        skus[id] = it
                    }
                }
            }
        }

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
    override fun handlePurchases() {
        Logger.d(TAG, "Checking for pending purchases")
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.INAPP)
        ensureConnected {
            queryPurchasesAsync(
                params.build(),
            ) { billingResult: BillingResult, purchases: List<Purchase>? ->
                if (!billingResult.responseCodeOK()) {
                    isRetriable(billingResult).then { handlePurchases() }
                    return@queryPurchasesAsync
                }
                if (purchases == null) {
                    return@queryPurchasesAsync
                }
                Logger.d(TAG, "Got ${purchases.size} purchases")
                handleAcknowledgedPurchases(purchases)
            }
        }
    }

    private fun handleAcknowledgedPurchases(purchases: List<Purchase>) {
        for (purchase in purchases) {
            ensureConnected {
                /// if not acknowledged form server, acknowledge it
                if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                    if (!purchase.isAcknowledged) {
                        val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
                            .setPurchaseToken(purchase.purchaseToken)
                        acknowledgePurchase(acknowledgePurchaseParams.build()) { billingResult ->
                            if (!billingResult.responseCodeOK()) {
                                isRetriable(billingResult).then { handlePurchases() }
                                return@acknowledgePurchase
                            }
                            Logger.d(
                                TAG,
                                "Acknowledged purchase ${purchase.purchaseToken}"
                            )
                        }
                    }
                }

                val consumeParams =
                    ConsumeParams.newBuilder().setPurchaseToken(purchase.purchaseToken)
                        .build()
                val listener =
                    ConsumeResponseListener { billingResult: BillingResult, outToken: String? ->
                        if (!billingResult.responseCodeOK()) {
                            return@ConsumeResponseListener
                        }
                    }
                // Purchases are acknowledged on the server side. In order to allow further purchasing of the same plan,
                // we have to consume it first, so we do that here. Since we don't actually know what has and what hasn't
                // been consumed, we just do this every time we start up.
                Logger.d(
                    TAG,
                    "Consuming already acknowledged purchase ${purchase.purchaseToken}"
                )
                consumeAsync(consumeParams, listener)
            }
        }
    }

    private fun isRetriable(billingResult: BillingResult): Boolean {
        val responseCode = billingResult.responseCode
        val message = billingResult.debugMessage
        return when (responseCode) {
            BillingClient.BillingResponseCode.SERVICE_TIMEOUT,
            BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE,
            BillingClient.BillingResponseCode.USER_CANCELED,
            -> {
                Logger.e(
                    TAG,
                    "Transient error communicating with Google Play Billing, will retry: $responseCode | $message"
                )
                true
            }

            else -> {
                Logger.e(
                    TAG,
                    "Non-transient error communicating with Google Play Billing, will not retry: $responseCode | $message"
                )
                false
            }
        }
    }
}
