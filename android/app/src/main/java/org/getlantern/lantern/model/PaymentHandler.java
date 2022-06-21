package org.getlantern.lantern.model;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.JsonObject;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.WelcomeActivity_;
import org.getlantern.lantern.service.BackgroundChecker_;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.lantern.util.Analytics;
import org.getlantern.lantern.util.PlansUtil;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.Logger;

import okhttp3.FormBody;
import okhttp3.HttpUrl;
import okhttp3.Response;

/**
 * PaymentHandler is a class for sending purchase requests to the pro server.
 */
public class PaymentHandler {

    private static final String TAG = PaymentHandler.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
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
        checkerIntent.putExtra("renewal", LanternApp.getSession().isProUser());
        checkerIntent.putExtra("numProMonths", LanternApp.getSession().numProMonths());
        checkerIntent.putExtra("maxCalls", MAX_TRIES_CHECK_PRO);
        checkerIntent.putExtra("asBroadcast", asBroadcast);
        checkerIntent.putExtra("provider", provider);
        checkerIntent.putExtra("nextActivity", "org.getlantern.lantern.activity.WelcomeActivity_");
        activity.startService(checkerIntent);
    }

    // Upgrades (Free -> Pro/Platinum) or renews (Pro -> Pro/Platinum)
    public void convertToPro() {
        final ProPlan selectedPlan = LanternApp.getSession().getSelectedPlan();
        final String incomingLevel = selectedPlan.getLevel();

        // Link device to account
        LanternApp.getSession().linkDevice();

        PlansUtil.getRenewalOrUpgrade(incomingLevel);

        // Update isProUser
        // Both Pro and Platinum user levels are considered Pro
        LanternApp.getSession().setIsProUser(true);

        // Update user level
        LanternApp.getSession().setUserLevel(incomingLevel);
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

    // the dialog rendering functions have been commented out since we are handling that Flutter side now
    public void sendPurchaseRequest() {
        final HttpUrl url = LanternHttpClient.createProUrl("/purchase");
        final JsonObject json = new JsonObject();
        final ProPlan plan = LanternApp.getSession().getSelectedPlan();
        Logger.debug(TAG, "Sending purchase request with provider: " + provider);
        FormBody.Builder formBody = new FormBody.Builder()
            .add("resellerCode", LanternApp.getSession().resellerCode())
            .add("stripeEmail", LanternApp.getSession().email())
            .add("stripePublicKey", LanternApp.getSession().stripePubKey())
            .add("stripeToken", LanternApp.getSession().stripeToken())
            .add("idempotencyKey", Long.toString(System.currentTimeMillis()))
            .add("provider", provider)
            .add("email", LanternApp.getSession().email())
            .add("currency", LanternApp.getSession().currency().toLowerCase())
            .add("deviceName", LanternApp.getSession().deviceName());

        if (!TextUtils.isEmpty(token)) {
            formBody.add("token", token);
        }

        // TODO: is this correct?
        if (plan != null) {
            // there is no selected plan when purchasing via resellers
            formBody = formBody.add("plan", plan.getId());
        }

        Logger.debug(TAG, "Sending purchase request...");
//        showDialog();
        lanternClient.post(url, formBody.build(), new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                final String errorMakingPurchase = getActivity().getString(
                        R.string.error_making_purchase);
                Logger.error(TAG, "Error with purchase request:" + error);
//                dismissDialog();
                ActivityExtKt.showErrorDialog(getActivity(), errorMakingPurchase);
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
//                dismissDialog();
                convertToPro();
                sendPurchaseEvent(LanternApp.getAppContext(), provider);
            }
        });
    }

    public static void sendPurchaseEvent(final Context context, final String provider) {
        sendPurchaseEvent(context, provider, null);
    }

    public static void sendPurchaseEvent(final Context context,
            final String provider, final String error) {
        final ProPlan plan = LanternApp.getSession().getSelectedPlan();
        if (plan == null) {
            Logger.error(TAG, "No plan specified. Not logging purchase event");
            return;
        }

        if (error != null) {
            Logger.error(TAG, "Encountered error, not logging purchase event", error);
            return;
        }
        Analytics.purchase(
                context,
                provider,
                plan);
    }

}
