package org.getlantern.lantern.activity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.view.View;

import androidx.fragment.app.FragmentActivity;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProPlan;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;

import java.util.Currency;

import okhttp3.HttpUrl;
import okhttp3.Response;

@EActivity(R.layout.test_payment)
public class TestPaymentActivity extends FragmentActivity implements LanternHttpClient.ProCallback {
    private static final String TAG = TestPaymentActivity.class.getName();

    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    
    private ProgressDialog dialog;

    @Extra
    String userEmail;

    @Click(R.id.payNow)
    void payNow(View view) {
        sendPaymentRequest();
    }

    @Override
    protected void onPause() {
        closeDialog();
        super.onPause();
    }

    @Override
    public void onFailure(final Throwable throwable, final ProError error) {
        closeDialog();
        Utils.showUIErrorDialog(TestPaymentActivity.this,
                getResources().getString(R.string.unable_init_test_payment));
    }

    private void closeDialog() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    @Override
    public void onSuccess(final Response response, final JsonObject result) {
        Logger.debug(TAG, "Successfully setup payment session");

        closeDialog();

        if (LanternApp.getSession().yinbiEnabled()) {
            LanternApp.getSession().setShowRedemptionTable(true);
        }
        final Class activity = LanternApp.getSession().welcomeActivity();
        startActivity(new Intent(this, activity));
    }

    private void sendPaymentRequest() {
        dialog = ProgressDialog.show(this,
                getResources().getString(R.string.submitting_purchase),
                getResources().getString(R.string.now_converting_to_pro),
                true, false);

        final HttpUrl url = LanternHttpClient.createProUrl("/test-payment");
        final JsonObject json = new JsonObject();
        final ProPlan plan = LanternApp.getSession().getSelectedPlan();
        final String locale = LanternApp.getSession().getLanguage();
        final Currency currency = LanternApp.getSession().getCurrency();
        json.addProperty("plan", plan.getId());
        json.addProperty("channel", "Android");
        json.addProperty("locale", locale);
        json.addProperty("currency", currency.toString());
        json.addProperty("idempotencyKey", Long.toString(System.currentTimeMillis()));
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

        lanternClient.post(url, LanternHttpClient.createJsonBody(json), this);
    }
}
