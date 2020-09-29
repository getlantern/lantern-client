package org.lantern.app.activity;

import androidx.fragment.app.FragmentActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;

import org.lantern.app.LanternApp;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.PaymentHandler;
import org.lantern.app.model.SessionManager;
import org.lantern.app.model.Utils;
import org.lantern.app.R;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

@EActivity(R.layout.reseller_register_pro)
public class RegisterProActivity extends FragmentActivity {

    private static final String TAG = RegisterProActivity.class.getName();
    private static final int RESELLER_CODE_LEN = 29;
    private static final String PROVIDER = "reseller-code";

    private final SessionManager session = LanternApp.getSession();

    private PaymentHandler paymentHandler;

    @ViewById
    EditText emailInput, confirmEmailInput, resellerCodeInput;

    @AfterViews
    void afterViews() {
        paymentHandler = new PaymentHandler(this, PROVIDER);
        addTextWatcherResellerInput();
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
        final String confirmEmail = confirmEmailInput.getText().toString().trim();
        final String resellerCode = resellerCodeInput.getText().toString().trim();

        // email validation
        if (!Utils.isEmailValid(email)) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.invalid_email));
            return;
        }

        if (!email.equalsIgnoreCase(confirmEmail)) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.emails_do_not_match));
            return;
        }

        // reseller code validation
        if (resellerCode.length() != RESELLER_CODE_LEN) {
            // reseller code unexpected length
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.invalid_reseller_code));
            return;
        }

        Logger.debug(TAG, "User entered a valid reseller code " + resellerCode + " -- submitting purchase request");

        session.setEmail(email);
        session.setResellerCode(resellerCode);
        session.setProvider("reseller-code");
        paymentHandler.sendPurchaseRequest();
    }
}
