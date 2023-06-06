package org.getlantern.lantern.model;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClient.SkuType;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesResponseListener;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;

import org.getlantern.mobilesdk.Logger;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class InAppBilling implements PurchasesUpdatedListener, BillingClientStateListener, ConsumeResponseListener {
    private static final String TAG = InAppBilling.class.getName();

    private final BillingClient billingClient;
    private final Map<String, ProPlan> plans = Collections.synchronizedMap(new HashMap<String, ProPlan>());
    private final Map<String, SkuDetails> skus = Collections.synchronizedMap(new HashMap<String, SkuDetails>());
    private volatile PurchasesUpdatedListener onPurchasesUpdated = null;
    private final Handler handler = new Handler(Looper.getMainLooper());

    public InAppBilling(Context context) {
        Logger.debug(TAG, "Creating InAppBilling");
        billingClient =
                BillingClient.newBuilder(context).enablePendingPurchases().setListener(this).build();
        startConnection();
    }

    synchronized public Map<String, ProPlan> getPlans() {
        return plans;
    }

    synchronized public boolean startPurchase(Activity activity, String planId, PurchasesUpdatedListener cb) {
        this.onPurchasesUpdated = cb;
        SkuDetails skuDetails = skus.get(planId);
        if (skuDetails == null) {
            Logger.error(TAG, "Unable to find sku details for plan: " + planId);
            return false;
        }
        Logger.debug(TAG, "Launching billing flow for plan: " + planId + ", sku: " + skuDetails.getSku());
        BillingFlowParams flowParams = BillingFlowParams.newBuilder()
                .setSkuDetails(skuDetails)
                .build();
        BillingResult result = billingClient.launchBillingFlow(activity, flowParams);
        if (result.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Logger.error(TAG, "Unexpected response code trying to launch billing flow: " + result.getResponseCode());
            return false;
        }
        return true;
    }

    @Override
    public void onBillingSetupFinished(BillingResult billingResult) {
        Logger.debug(TAG, "onBillingSetupFinished with response code: " + billingResult.getResponseCode());
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            if (isRetriable(billingResult)) {
                handler.postDelayed(() -> {
                    billingClient.endConnection();
                    startConnection();
                },5000);
            }
            return;
        }

        updateSkus();
        checkForUnacknowledgedPurchases();
    }

    @Override
    public void onBillingServiceDisconnected() {
        Logger.debug(TAG, "onBillingServiceDisconnected");
    }

    /**
     * This pulls down the pricing for our 1y and 2y plans from the Play Store. This will reflect
     * whatever Play Store region the user is currently in. Unlike our usual purchases, this has
     * nothing to do with the user's language settings inside of the Lantern app.
     */
    private void updateSkus() {
        Logger.debug(TAG, "Updating SKUs");
        List<String> skuList = new ArrayList<>();
        skuList.add("1y");
        skuList.add("2y");
        SkuDetailsParams.Builder params = SkuDetailsParams.newBuilder();
        params.setSkusList(skuList).setType(SkuType.INAPP);
        billingClient.querySkuDetailsAsync(
                params.build(),
                new SkuDetailsResponseListener() {
                    @Override
                    public void onSkuDetailsResponse(
                            BillingResult billingResult, List<SkuDetails> skuDetailsList) {
                        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                            if (isRetriable(billingResult)) {
                                handler.postDelayed(() -> updateSkus(), 5000);
                            }
                            return;
                        }
                        Logger.debug(TAG, "Got skus: " + skuDetailsList.size());

                        synchronized (this) {
                            plans.clear();
                            skus.clear();
                            for (SkuDetails skuDetails : skuDetailsList) {
                                String currency = skuDetails.getPriceCurrencyCode().toLowerCase();
                                String id = String.format("%s-%s", skuDetails.getSku(), currency);
                                String years = skuDetails.getSku().substring(0, 1);

                                Map<String, Integer> duration = new HashMap<String, Integer>();
                                duration.put("years", Integer.parseInt(years));

                                Map<String, Long> price = new HashMap<String, Long>();
                                price.put(currency, skuDetails.getPriceAmountMicros() / 10000);

                                Map<String, Long> priceWithoutTax = new HashMap<String, Long>();
                                priceWithoutTax.put(currency, skuDetails.getOriginalPriceAmountMicros() / 10000);

                                ProPlan plan = new ProPlan(
                                        id,
                                        price,
                                        priceWithoutTax,
                                        "2".equals(years),
                                        duration);

                                plans.put(id, plan);
                                skus.put(id, skuDetails);
                            }
                        }
                    }
                });
    }

    /**
     * This checks to see if the user has any purchases that we have not yet acknowledged.
     *
     * This can happen if
     *
     * 1. the app was unable to inform the pro server of a purchase right after
     *    it was made or
     * 2. the pro server has not yet gotten around to acknowledging the purchase
     *
     * In either case, we'll let the pro-server know about the purchase to make sure that it gets
     * correctly applied to the user's account.
     */
    private void checkForUnacknowledgedPurchases() {
        Logger.debug(TAG, "Checking for pending purchases");
        billingClient.queryPurchasesAsync(SkuType.INAPP, new PurchasesResponseListener() {
            public void onQueryPurchasesResponse(BillingResult billingResult, List<Purchase> purchases) {
                if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
                    if (isRetriable(billingResult)) {
                        handler.postDelayed(() -> checkForUnacknowledgedPurchases(), 5000);
                    }
                    return;
                }

                Logger.debug(TAG, "Got purchases: " + purchases.size());
                handleAcknowledgedPurchases(purchases);
            }
        });
    }

    public void onPurchasesUpdated(BillingResult billingResult, List<Purchase> purchases) {
        Logger.debug(TAG, "Purchases updated");

        if (this.onPurchasesUpdated != null) {
            this.onPurchasesUpdated.onPurchasesUpdated(billingResult, purchases);
            this.onPurchasesUpdated = null;
        }
    }

    @Override
    public void onConsumeResponse(BillingResult billingResult, String s) {
        // Ignore
    }

    private void handleAcknowledgedPurchases(List<Purchase> purchases) {
        for (Purchase purchase : purchases) {
            if (purchase.isAcknowledged()) {
                // Purchases are acknowledged on the server side. In order to allow further purchasing of the same plan, we have to consume it first,
                // so we do that here. Since we don't actually know what has and what hasn't been consumed, we just do this every time we start up.
                Logger.debug(TAG, "Consuming already acknowledged purchase " + purchase.getPurchaseToken());
                billingClient.consumeAsync(ConsumeParams.newBuilder().setPurchaseToken(purchase.getPurchaseToken()).build(), this);
            }
        }
    }

    private void startConnection() {
        Logger.debug(TAG, "Starting connection");
        billingClient.startConnection(this);
    }

    private boolean isRetriable(BillingResult billingResult) {
        int responseCode = billingResult.getResponseCode();
        String message = billingResult.getDebugMessage();
        switch (responseCode) {
            case BillingClient.BillingResponseCode.SERVICE_TIMEOUT:
            case BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE:
            case BillingClient.BillingResponseCode.USER_CANCELED:
                Logger.error(
                        TAG,
                        "Transient error communicating with Google Play Billing, will retry: " + responseCode + " | " + message);
                return true;
        }

        Logger.error(
                TAG,
                "Non-transient error communicating with Google Play Billing, will not retry: "
                        + responseCode + " | " + message);
        return false;
    }
}
