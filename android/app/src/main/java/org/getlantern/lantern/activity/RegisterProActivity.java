package org.getlantern.lantern.activity;

import android.content.Intent;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;

import android.widget.TextView;
import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.model.MaterialUtil;
import org.getlantern.lantern.model.PaymentHandler;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

@EActivity(R.layout.activity_check_out_reseller)
public class RegisterProActivity extends BaseFragmentActivity {

    private static final String TAG = RegisterProActivity.class.getName();
    private static final int RESELLER_CODE_LEN = 29;
    private static final String PROVIDER = "reseller-code";

    private PaymentHandler paymentHandler;

    @ViewById
    EditText emailInput, resellerCodeInput;

    @ViewById
    TextView termsOfServiceText;

    private final ClickSpan.OnClickListener clickSpan = () -> {
            final Intent intent = new Intent(RegisterProActivity.this,
                WebViewActivity_.class);
            intent.putExtra("url", CheckoutActivity.TERMS_OF_SERVICE_URL);
            startActivity(intent);
        };

    @AfterViews
    void afterViews() {
        paymentHandler = new PaymentHandler(this, PROVIDER);
        addTextWatcherResellerInput();
        MaterialUtil.clickify(termsOfServiceText, getString(R.string.terms_of_service), clickSpan);
    }

    // The reseller code is of the following format:
    // XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    // this adds a textwatcher to the reseller code input
    // to automatically insert hyphens as the user types each section
    private void addTextWatcherResellerInput() {
        resellerCodeInput.addTextChangedListener(new TextWatcher() {

            int len = 0;

            @Override
            public void afterTextChanged(Editable s) {
                String str = resellerCodeInput.getText().toString();
                int sLen = str.length();
                boolean insertHyphen = sLen == 5 ||
                    sLen == 11 || sLen == 17 || sLen == 23;
                if (insertHyphen && len < sLen) {
                    resellerCodeInput.append("-");
                }
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                String str = resellerCodeInput.getText().toString();
                len = str.length();
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }
        });
    }

    @Click(R.id.continueBtn)
    public void continueClicked(View view) {
        final String email = emailInput.getText().toString().trim();
        final String resellerCode = resellerCodeInput.getText().toString().trim();

        // email validation
        if (!Utils.isEmailValid(email)) {
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.invalid_email));
            return;
        }

        // reseller code validation
        if (resellerCode.length() != RESELLER_CODE_LEN) {
            // reseller code unexpected length
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.invalid_reseller_code));
            return;
        }

        Logger.debug(TAG, "User entered a valid reseller code " + resellerCode + " -- submitting purchase request");

        LanternApp.getSession().setEmail(email);
        LanternApp.getSession().setResellerCode(resellerCode);
        LanternApp.getSession().setProvider("reseller-code");
        paymentHandler.sendPurchaseRequest();
    }
}
