package org.lantern.app.activity;

import android.content.Intent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

import org.lantern.app.LanternApp;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.LanternHttpClient;
import org.lantern.app.model.ProError;
import org.lantern.app.model.SessionManager;
import org.lantern.app.model.Utils;
import org.lantern.app.R;

import com.google.gson.JsonObject;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.activity_recovery_code)
public class RecoveryCodeActivity extends FragmentActivity {

    private static final String TAG = RecoveryCodeActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private static final SessionManager session = LanternApp.getSession();

    @ViewById
    EditText codeInput;

    @ViewById
    Button resendEmail, submit;

    @ViewById
    TextView emailWithRecoveryCode;

    @AfterViews
    void afterViews() {
        emailWithRecoveryCode.setText(String.format(getResources().getString(R.string.email_recovery_code), session.email()));
    }

    private void showLinkRequestSentAlert() {
        final String title = getResources().getString(R.string.account_recovery);
        final String msg = String.format(getResources().getString(R.string.email_recovery_code), session.email());
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
        session.setUserIdAndToken(result.get("userID").getAsInt(), result.get("token").getAsString());
        session.linkDevice();
        session.setIsProUser(true);
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
