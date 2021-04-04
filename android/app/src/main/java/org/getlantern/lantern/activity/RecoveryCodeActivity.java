package org.getlantern.lantern.activity;

import android.content.Intent;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.activity_recovery_code)
public class RecoveryCodeActivity extends FragmentActivity {

    private static final String TAG = RecoveryCodeActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    
    @ViewById
    EditText codeInput;

    @ViewById
    Button resendEmail, submit;

    @ViewById
    TextView emailWithRecoveryCode;

    @AfterViews
    void afterViews() {
        String email = LanternApp.getSession().email();
        String emailText = String.format(getResources().getString(R.string.your_device_linking_pin_has_been_sent), email);
        int startEmailIndex = emailText.indexOf(email);
        Spannable emailSpan = new SpannableString(emailText);
        emailSpan.setSpan(new ForegroundColorSpan(ContextCompat.getColor(this, R.color.tertiary_green)), startEmailIndex, startEmailIndex + email.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        emailWithRecoveryCode.setText(emailSpan);

        codeInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().length() > 0) {
                    submit.setEnabled(true);
                } else {
                    submit.setEnabled(false);
                }
            }
        });
    }

    private void showLinkRequestSentAlert() {
        final String title = getResources().getString(R.string.account_recovery);
        final String msg = String.format(getResources().getString(R.string.email_recovery_code), LanternApp.getSession().email());
        Utils.showAlertDialog(this, title, msg, false);
    }

    @Click(R.id.submit)
    void verifyCode(View view) {
        final String code = codeInput.getText().toString();

        if (code.equals("") || !code.matches("[0-9]+")) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.enter_valid_code));
            return;
        }

        final RecoveryCodeActivity activity = this;
        final RequestBody formBody = new FormBody.Builder()
            .add("code", code)
            .build();
        Logger.debug(TAG, "Sending link request; code:" + code);
        lanternClient.post(LanternHttpClient.createProUrl("/user-link-validate"), formBody,
            new LanternHttpClient.ProCallback() {
                @Override
                public void onFailure(final Throwable throwable, final ProError error) {
                    Logger.error(TAG, "Unable to validate link code", throwable);
                    showError(error);
                }
                @Override
                public void onSuccess(final Response response, final JsonObject result) {
                    Logger.debug(TAG, "Response: " + result);
                    if (result.get("token") != null && result.get("userID") != null) {
                        // TODO: 04/04/2021 so the dialog when adding success
                        linkDevice(result);
                    }
                }
            });
    }

    private void showError(final ProError error) {
        if (error == null) {
            Logger.error(TAG, "Unable to validate recovery code and no error to show");
            return;
        }
        final String errorId = error.getId();
        if (errorId.equals("too-many-devices")) {
            Utils.showUIErrorDialog(this, getResources().getString(R.string.too_many_devices));
        } else if (error.getMessage() != null) {
            Utils.showUIErrorDialog(this, error.getMessage());
        }
    }

    private void linkDevice(final JsonObject result) {
        Logger.debug(TAG, "Successfully validated recovery code");
        // update token and user ID with those returned by the pro server
        LanternApp.getSession().setUserIdAndToken(result.get("userID").getAsInt(), result.get("token").getAsString());
        LanternApp.getSession().linkDevice();
        LanternApp.getSession().setIsProUser(true);
        Intent intent = new Intent(this, LanternProActivity.class);
        intent.putExtra("snackbarMsg", getResources().getString(R.string.device_now_linked));
        startActivity(intent);
        finish();
    }

    @Click(R.id.resendEmail)
    void resendEmail(View view) {
        Logger.debug(TAG, "Re-send email button clicked");
        lanternClient.sendLinkRequest(new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                if (error != null) {
                    Logger.error(TAG, "Unable to re-send email:" + error);
                }
            }

            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                showLinkRequestSentAlert();
            }
        });
    }

}
