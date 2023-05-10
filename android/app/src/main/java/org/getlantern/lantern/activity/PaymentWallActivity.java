package org.getlantern.lantern.activity;

import android.content.Intent;
import android.content.res.Resources;

import androidx.fragment.app.FragmentActivity;

import com.google.gson.JsonObject;
import com.paymentwall.alipayadapter.PsAlipay;
import com.paymentwall.pwunifiedsdk.core.PaymentSelectionActivity;
import com.paymentwall.pwunifiedsdk.core.UnifiedRequest;
import com.paymentwall.pwunifiedsdk.object.ExternalPs;
import com.paymentwall.pwunifiedsdk.util.Key;
import com.paymentwall.pwunifiedsdk.util.ResponseCode;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.PaymentHandler;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProPlan;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.lantern.util.LanternHttpClient;
import org.getlantern.mobilesdk.Logger;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import okhttp3.Response;

@EActivity(R.layout.paymentwall_layout)
public class PaymentWallActivity extends BaseFragmentActivity {

    private static final String TAG = PaymentWallActivity.class.getName();
    private static final String PROVIDER = "PW";
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private PaymentHandler paymentHandler;

    @Extra
    String userEmail;

    @AfterViews
    void afterViews() {
        paymentHandler = new PaymentHandler(this, PROVIDER);
        open();
    }

    public void open() {
        final Resources res = getResources();
        final ProPlan plan = LanternApp.getSession().getSelectedPlan();
        if (plan == null) {
            Logger.error(TAG, "No plan selected");
            return;
        }

        // Use a fake email address for privacy reasons
        final String transactionID = UUID.randomUUID().toString();

        final String currency = LanternApp.getSession().currency();
        Logger.debug(TAG, "Selected plan ID " + plan.getId() + " " + currency);
        final Map<String, String> params = new HashMap<String, String>();
        params.put("plan", plan.getId());
        params.put("email", userEmail);
        params.put("locale", LanternApp.getSession().getLanguage());
        params.put("userCurrency", currency.toLowerCase());
        params.put("deviceName", LanternApp.getSession().deviceName());
        params.put("countryCode", LanternApp.getSession().getCountryCode());
        params.put("transactionID", transactionID);

        lanternClient.get(LanternHttpClient.createProUrl("/paymentwall-mobile-signature", params),
            new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                ActivityExtKt.showErrorDialog(PaymentWallActivity.this,
                        res.getString(R.string.error_payment_gateway));
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                try {
                    final String signature = response.body().string();
                    onSignatureResult(transactionID, signature);
                } catch (Exception e) {
                    final String error = "Unable to initiate purchase";
                    Logger.error(TAG, error, e);
                    ActivityExtKt.showErrorDialog(PaymentWallActivity.this, error);
                    return;
                }
            }
        });
    }

    public static UnifiedRequest createUnifiedPWRequest(final Resources res, final String transactionID, final String sig) {
        final ProPlan proPlan = LanternApp.getSession().getSelectedPlan();
        final Double chargeAmount = new BigDecimal(LanternApp.getSession().getSelectedPlanCost()).divide(
                new BigDecimal("100")).doubleValue();
        final UnifiedRequest request =  new  UnifiedRequest();
        final String projectKey = res.getString(LanternApp.getSession().useStaging() ? R.string.pw_staging_project_key : R.string.pw_project_key);

        request.setPwProjectKey(projectKey);
        request.setAmount(chargeAmount);
        request.setCurrency(LanternApp.getSession().getSelectedPlanCurrency().toUpperCase());
        request.setItemName(proPlan.getDescription());
        request.setItemId(proPlan.getId());
        request.setUserId(transactionID);
        request.setSignVersion( 3 );
        request.setTimeout( 30000 );

        Logger.debug(TAG, "Sending unified request to PW: " + request);

        final PsAlipay alipay =  new  PsAlipay();
        alipay.setAppId("external");
        alipay.setPaymentType("1");
        alipay.setPwSign(sig);
        alipay.setItbPay("30m");
        // extra params for international account alipay.setItbPay( "30m" ) ;
        alipay.setForexBiz("FP");
        alipay.setAppenv( "system=android^version=3.0.1.2" );

        final ExternalPs alipayPs =  new ExternalPs("alipay", "Alipay",
                R.drawable.alipay_logo, alipay) ;
        request.add(alipayPs);

        return request;
    }

    private void onSignatureResult(final String transactionID, final String sig) {
        if (sig == null || sig.equals("")) {
            Logger.error(TAG, "Unable to generate PW signature");
            return;
        }
        final UnifiedRequest request = createUnifiedPWRequest(getResources(), transactionID, sig);
        final Intent intent = new Intent(this,
                PaymentSelectionActivity.class);
        intent.putExtra(Key.REQUEST_MESSAGE, request);

        // before we open the SDK, check periodically
        // in the background to see if the becomes Pro
        // to know when to successfully redirect to the
        // Welome screen
        paymentHandler.checkProUser(false);

        startActivityForResult(intent, PaymentSelectionActivity.REQUEST_CODE);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        Logger.debug(TAG, "Activity result:" + requestCode);

        String error = null;
        switch (resultCode) {
            case ResponseCode.ERROR:
                error = "Error trying to load PW SDK";
                // There is an error with the payment
                break;
            case ResponseCode.CANCEL:
                // User cancels the payment
                break;
            case ResponseCode.SUCCESSFUL:
                // The payment is successful
                Logger.debug(TAG, "User successfully paid for Pro");
                break;
            case ResponseCode.FAILED:
                error = "Sending payment request to PW failed";
                break;
            case ResponseCode.MERCHANT_PROCESSING:
                // This case is only for Brick. If nativeDialog set to false,
                // means that merchant displays successful payment dialog by himself
                // so the sdk will return brick token and this resultCode to merchant app
                break;
            default:
                break;
        }

        if (error != null) {
            Logger.error(TAG, error);
            PaymentHandler.sendPurchaseEvent(this, PROVIDER, error);
        }
    }
}
