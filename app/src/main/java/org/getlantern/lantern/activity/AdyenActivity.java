package org.getlantern.lantern.activity;

import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.adyen.core.PaymentRequest;
import com.adyen.core.interfaces.PaymentDataCallback;
import com.adyen.core.interfaces.PaymentRequestListener;
import com.adyen.core.models.Payment;
import com.adyen.core.models.PaymentRequestResult;
import com.google.gson.JsonObject;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.PaymentHandler;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProPlan;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;

import java.util.Currency;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicReference;

import okhttp3.HttpUrl;
import okhttp3.Response;

@EActivity(R.layout.adyen_layout)
public class AdyenActivity extends FragmentActivity implements PaymentRequestListener {

    private static final String TAG = AdyenActivity.class.getSimpleName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    public static final String PROVIDER = "Adyen";

    private final AtomicReference<String> setupRef = new AtomicReference<>();

    @Extra
    String userEmail;

    private Context context;
    private PaymentHandler paymentHandler;
    private PaymentRequest paymentRequest;

    @AfterViews
    void afterViews() {
        this.context = this;
        this.paymentHandler = new PaymentHandler(this, PROVIDER);
        this.paymentRequest = new PaymentRequest(this, this);
        paymentRequest.start();
    }

    @Override
    public void onConfigurationChanged(Configuration config) {
        super.onConfigurationChanged(config);

        // This is needed in case the user changes the locale manually
        // from the languages screen
        getBaseContext().getResources().updateConfiguration(config,
                getBaseContext().getResources().getDisplayMetrics());
    }

    private void setupPaymentSession(@NonNull PaymentRequest paymentRequest,
            @NonNull PaymentDataCallback paymentDataCallback, @NonNull String token) {
        final HttpUrl url = LanternHttpClient.createProUrl("/adyen-setup");
        final JsonObject json = new JsonObject();
        final ProPlan plan = LanternApp.getSession().getSelectedPlan();
        final String locale = LanternApp.getSession().getLanguage();
        final Currency currency = Currency.getInstance(new Locale(locale));
        json.addProperty("token", token);
        json.addProperty("plan", plan.getId());
        json.addProperty("channel", "Android");
        json.addProperty("locale", locale);
        json.addProperty("currency", currency.toString());
        json.addProperty("deviceName", LanternApp.getSession().deviceName());
        json.addProperty("email", userEmail);
        json.addProperty("platform", "android");
        json.addProperty("appVersion", Utils.appVersion(this));

        final String country;
        if (!BuildConfig.COUNTRY.equals("")) {
            country = BuildConfig.COUNTRY;
        } else {
            country = LanternApp.getSession().getCountryCode();
        }
        Logger.debug(TAG, "User country code: " + country + " currency: " + currency + " locale " + locale);
        json.addProperty("countryCode", country);

        lanternClient.post(url, LanternHttpClient.createJsonBody(json),
            new LanternHttpClient.ProCallback() {
                @Override
                public void onFailure(final Throwable throwable, final ProError error) {
                    Logger.error(TAG, "Error initiating a payment session with Adyen", throwable);
                    Logger.debug(TAG, "Canceling Adyen payment request");
                    paymentRequest.cancel();
                    if (AdyenActivity.this.isDestroyed()) {
                        return;
                    }
                    Utils.showUIErrorDialog(AdyenActivity.this,
                            getResources().getString(R.string.unable_init_adyen_session));
                }
                @Override
                public void onSuccess(final Response response, final JsonObject result) {
                    Logger.debug(TAG, "Successfully setup payment session");
                    try {
                        final String reference = result.get("reference").getAsString();
                        final String body = result.get("body").getAsString();
                        setupRef.set(reference);
                        Logger.debug(TAG, "Received response for setup call. Reference:" + reference);
                        paymentDataCallback.completionWithPaymentData(body.getBytes());
                    } catch (Exception e) {
                        Logger.error(TAG, "Unable to complete request with payment data", e);
                    }
                }
        });
    }

    private void verifyPayment(final Payment payment) {
        final HttpUrl url = LanternHttpClient.createProUrl("/adyen-verify");
        final JsonObject json = new JsonObject();
        json.addProperty("reference", setupRef.get());
        json.addProperty("payload", payment.getPayload());
        lanternClient.post(url, LanternHttpClient.createJsonBody(json),
                new LanternHttpClient.ProCallback() {
                    @Override
                    public void onFailure(final Throwable throwable, final ProError error) {
                        Logger.error(TAG, "Error initiating a payment session with Adyen", throwable);
                        Logger.debug(TAG, "Canceling Adyen payment request");
                        if (AdyenActivity.this.isDestroyed()) {
                            return;
                        }
                        Utils.showUIErrorDialog(AdyenActivity.this,
                                getResources().getString(R.string.unable_init_adyen_session));
                    }
                    @Override
                    public void onSuccess(final Response response, final JsonObject result) {
                        Logger.debug(TAG, "Successfully setup payment session");
                        try {
                            final Intent intent = new Intent(context, AdyenSuccessActivity_.class);
                            startActivity(intent);
                            finish();
                        } catch (Exception e) {
                            Logger.error(TAG, "Unable to complete request with payment data", e);
                        }
                    }
                });

    }

    @Override
    public void onPaymentDataRequested(@NonNull PaymentRequest paymentRequest, @NonNull String token,
        @NonNull final PaymentDataCallback paymentDataCallback) {
        Logger.debug(TAG, "Payment data requested");
        // send user data and token provided by the SDK to the pro server
        // to create a payment session with Adyen
        setupPaymentSession(paymentRequest, paymentDataCallback, token);
    }

    @Override
    public void onPaymentResult(@NonNull PaymentRequest paymentRequest,
        @NonNull PaymentRequestResult paymentRequestResult) {
        final Intent intent;
        final boolean paymentProcessed = paymentRequestResult.isProcessed() &&
            (paymentRequestResult.getPayment().getPaymentStatus() == Payment.PaymentStatus.AUTHORISED ||
             paymentRequestResult.getPayment().getPaymentStatus() == Payment.PaymentStatus.RECEIVED);
        if (paymentProcessed) {
            try {
                verifyPayment(paymentRequestResult.getPayment());
            } catch (Exception e) {
                Logger.error(TAG, "Unable to verify payment", e);
            }
        } else {
            final String error = "Adyen payment failed:" + paymentRequestResult.getError();
            Logger.error(TAG, error);
            PaymentHandler.sendPurchaseEvent(this, PROVIDER, error);
            finish();
        }
    }
}
