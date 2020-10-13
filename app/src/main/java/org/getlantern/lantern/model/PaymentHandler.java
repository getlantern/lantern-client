package org.getlantern.lantern.model;

import android.app.Activity;
import android.content.Context;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.service.BackgroundChecker_;
import org.getlantern.lantern.activity.WelcomeActivity_;
import org.getlantern.lantern.activity.yinbi.YinbiWelcomeActivity_;

import com.google.gson.JsonObject;
import okhttp3.FormBody;
import okhttp3.HttpUrl;
import okhttp3.Response;

import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.model.SessionManager;

/**
 * PaymentHandler is a class for sending purchase requests to the pro server.
 */
public class PaymentHandler {

    private static final String TAG = PaymentHandler.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private static final SessionManager session = LanternApp.getSession();
    private static final Integer MAX_TRIES_CHECK_PRO = 40;

    private final Activity activity;
    private final ProgressDialog dialog;
    private final String provider;
    private final String token;

    public PaymentHandler(@NonNull final Activity activity,
            @NonNull final String provider, String token) {
            this.activity = activity;
            this.provider = provider;
            this.token = token;
            this.dialog = new ProgressDialog(activity);
            this.dialog.setTitle(R.string.processing_payment);
    }

    public PaymentHandler(@NonNull final Activity activity,
                          @NonNull final String provider) {
        this(activity, provider, null);
    }

    public Activity getActivity() {
        return activity;
    }

    // Attach a background checker to the current activity
    public void checkProUser(final boolean asBroadcast) {
        if (activity == null) {
            Logger.error(TAG, "Unable to attach pro checker to activity");
            return;
        }

        if (Utils.isServiceRunning(activity, BackgroundChecker_.class)) {
            Logger.debug(TAG, "Background checker already running");
            return;
        }

        final Intent checkerIntent = new Intent(activity, BackgroundChecker_.class);
        checkerIntent.putExtra("renewal", session.isProUser());
        checkerIntent.putExtra("numProMonths", session.numProMonths());
        checkerIntent.putExtra("maxCalls", MAX_TRIES_CHECK_PRO);
        checkerIntent.putExtra("asBroadcast", asBroadcast);
        checkerIntent.putExtra("provider", provider);
        if (session.yinbiEnabled()) {
            checkerIntent.putExtra("nextActivity", "org.getlantern.lantern.activity.yinbi.YinbiWelcomeActivity_");
        } else {
            checkerIntent.putExtra("nextActivity", "org.getlantern.lantern.activity.WelcomeActivity_");
        }
        activity.startService(checkerIntent);
    }

    public void convertToPro() {
        final Intent intent;
        if (session.yinbiEnabled()) {
            session.setShowRedemptionTable(true);
            intent = new Intent(activity, YinbiWelcomeActivity_.class);
        } else {
            intent = new Intent(activity, WelcomeActivity_.class);
        }
        session.linkDevice();
        session.setIsProUser(true);

        intent.putExtra("provider", provider);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(intent);
        activity.finish();
    }

    public void showDialog() {
        getActivity().runOnUiThread(new Runnable() {
            public void run() {
                if (dialog != null) {
                    dialog.show();
                }
            }
        });
    }

    public void dismissDialog() {
        getActivity().runOnUiThread(new Runnable() {
            public void run() {
                if (dialog != null) {
                    dialog.dismiss();
                }
            }
        });
    }

    public void sendPurchaseRequest() {
        final HttpUrl url = LanternHttpClient.createProUrl("/purchase");
        final JsonObject json = new JsonObject();
        final ProPlan plan = session.getSelectedPlan();
        Logger.debug(TAG, "Sending purchase request with provider: " + provider);
        FormBody.Builder formBody = new FormBody.Builder()
            .add("resellerCode", session.resellerCode())
            .add("stripeEmail", session.email())
            .add("stripePublicKey", session.stripePubKey())
            .add("stripeToken", session.stripeToken())
            .add("idempotencyKey", Long.toString(System.currentTimeMillis()))
            .add("provider", provider)
            .add("email", session.email())
            .add("currency", session.currency().toLowerCase())
            .add("deviceName", session.deviceName());

        if (!TextUtils.isEmpty(token)) {
            formBody.add("token", token);
        }

        if (plan != null) {
            // there is no selected plan when purchasing via resellers
            formBody = formBody.add("plan", plan.getId());
        }

        Logger.debug(TAG, "Sending purchase request...");
        showDialog();
        lanternClient.post(url, formBody.build(), new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                final String errorMakingPurchase = getActivity().getString(
                        R.string.error_making_purchase);
                Logger.error(TAG, "Error with purchase request:" + error);
                dismissDialog();
                Utils.showUIErrorDialog(getActivity(),
                        errorMakingPurchase);
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                dismissDialog();
                convertToPro();
            }
        });
    }

    public static void sendPurchaseEvent(final Context context, final String provider) {
        sendPurchaseEvent(context, provider, null);
    }

    public static void sendPurchaseEvent(final Context context,
            final String provider, final String error) {
        final ProPlan plan = session.getSelectedPlan();
        if (plan == null) {
            Logger.error(TAG, "No plan specified. Not logging purchase event");
            return;
        }

        final Bundle params = new Bundle();
        // the currency and value fields are firebase specific.
        // they are always logged using the USD price because firebase
        // does not support all currencies in use (ie no Iranian Rial)
        params.putString("currency", "USD");
        Long usdPrice = plan.getUSDEquivalentPrice();
        if (usdPrice != null) {
            params.putFloat("value", (float) (usdPrice / 100.0));
        }
        else {
            Logger.error(TAG, "Missing USD equivalent price for plan " + plan.getId());
            params.putFloat("value", (float) 0.0);
        }

        // original_currency/value indicate the true amount paid by the user
        params.putFloat("original_value", (float) (session.getSelectedPlanCost() / 100.0));
        params.putString("original_currency", session.getSelectedPlanCurrency());
        params.putString("plan", plan.getId());
        params.putString("provider", provider);
        params.putString("country", session.getCountryCode());

        if (error == null) {
            // The 'ecommerce_purchase' event type is a specific event type
            // understood by firebase.
            Lantern.sendEvent(context, "ecommerce_purchase", params);
        } else {
            params.putString("error", error);
            Lantern.sendEvent(context, "purchase_error", params);
        }
    }

}
