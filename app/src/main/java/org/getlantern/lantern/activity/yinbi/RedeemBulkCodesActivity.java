package org.getlantern.lantern.activity.yinbi;

import android.app.Activity;
import android.app.ProgressDialog;
import android.text.Html;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.SessionManager;
import org.getlantern.lantern.model.PaymentHandler;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.FormBody;
import okhttp3.HttpUrl;
import okhttp3.Response;

@EActivity(R.layout.redeem_bulk_codes)
public class RedeemBulkCodesActivity extends FragmentActivity implements LanternHttpClient.ProCallback {
    private static final String TAG = RedeemBulkCodesActivity.class.getName();
    private static final String TERMS_OF_SERVICE_URL = "https://s3.amazonaws.com/lantern/Lantern-TOS.pdf";
    private static final String PROVIDER = "reseller-code";

    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private final SessionManager session = LanternApp.getSession();

    private PaymentHandler paymentHandler;
    private ProgressDialog dialog;

    private final ClickSpan.OnClickListener clickSpan =
        Utils.createClickSpan(RedeemBulkCodesActivity.this, TERMS_OF_SERVICE_URL);

    @Extra
    String userEmail;

    @ViewById
    EditText bulkCodes;

    @ViewById
    TextView termsOfServiceText;

    @ViewById
    TextView errorMessage;

    @AfterViews
    void afterViews() {
        paymentHandler = new PaymentHandler(this, PROVIDER);

        bulkCodes.setHorizontallyScrolling(false);
        bulkCodes.setOnFocusChangeListener(new View.OnFocusChangeListener() {
        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (!hasFocus) {
                hideSoftKeyboard(v);
            }
        }
        });

        final int color = ContextCompat.getColor(this, R.color.pink);
        Utils.clickify(termsOfServiceText, getString(R.string.terms_of_service), color, clickSpan);
    }

    public void hideSoftKeyboard(View view) {
        InputMethodManager inputMethodManager =(InputMethodManager)getSystemService(Activity.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    private void closeDialog() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    @Override
    public void onFailure(final Throwable throwable, final ProError error) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showErrorRedeemingCodes(error);
            }
        });
    }

    /**
     * getInvalidCodes parses a JSON error message returned from the pro
     * server and returns a map of invalid codes
     */
    private Map<String,Boolean> getInvalidCodes(final ProError error) {
        final JsonElement invalidCodesJson = error.getDetails().get("invalidCodes");
        if (invalidCodesJson == null) {
            Logger.error(TAG, "Error message doesn't contain invalid codes");
            return null;
        }
        final Type listType = new TypeToken<List<String>>() {}.getType();
        final List<String> invalidCodeList = new Gson().fromJson(invalidCodesJson, listType);

        final Map<String, Boolean> invalidCodesMap = new HashMap<String, Boolean>();
        for (String invalidCode : invalidCodeList) {
            invalidCodesMap.put(invalidCode, true);
        }
        return invalidCodesMap;
    }

    /**
     * showErrorRedeemingCodes updates the UI to display an error message
     * about Lantern pro codes that couldn't be redeemed and highlights those codes that were invalid
     */

    private void showErrorRedeemingCodes(final ProError error) {
        closeDialog();
        if (error == null || error.getDetails() == null) {
            return;
        }
        if (error.getMessage() != null) {
            Logger.error(TAG, "Unable to submit pro activation codes " + error.getMessage());
        }
        final Map<String, Boolean> invalidCodes =
            getInvalidCodes(error);
        if (invalidCodes == null) {
            return;
        }
        final String codesStr = bulkCodes.getText().toString();
        final StringBuilder result = new StringBuilder();
        for (String code : codesStr.split("\\s+")) {
            if (invalidCodes.containsKey(code)) {
                // use font tag to mark invalid codes red
                result.append(String.format(
                            "<font color='#ff0000'>%s</font><br>",
                            code));
            } else {
                result.append(String.format("%s<br>",
                            code));
            }
        }
        // replace any instances of codes that were found to be
        // invalid by changing their color to red
        bulkCodes.setText(Html.fromHtml(result.toString()));
        errorMessage.setVisibility(View.VISIBLE);
    }

    @Override
    public void onSuccess(final Response response, final JsonObject result) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                closeDialog();
                Logger.debug(TAG, "Successful bulk codes request");
                session.setShowRedemptionTable(true);
                paymentHandler.convertToPro();
            }
        });
    }

    private void submitBulkCodes(final String[] codes) {
        final HttpUrl url = LanternHttpClient.createProUrl("/redeem-reseller-codes");
        final FormBody.Builder formBody = new FormBody.Builder()
            .add("idempotencyKey", Long.toString(System.currentTimeMillis()))
            .add("provider", "reseller-code")
            .add("email", userEmail)
            .add("currency", session.currency().toLowerCase())
            .add("deviceName", session.deviceName());
        formBody.add("resellerCodes", TextUtils.join(",", codes));

        dialog = new ProgressDialog(this);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
        lanternClient.post(url, formBody.build(), this);
    }

    @Click(R.id.submitButton)
    public void redeemBulkCodes(View view) {
        final String codes = bulkCodes.getText().toString();
        if (codes.equals("")) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.invalid_bulk_codes));
            return;
        }
        if (userEmail == null || userEmail.equals("")) {
            return;
        }
        submitBulkCodes(codes.split("\\s+"));
    }
}
