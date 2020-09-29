package org.getlantern.lantern.activity;

import android.content.Intent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

import org.getlantern.lantern.LanternApp;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.SessionManager;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.R;

import com.google.gson.JsonObject;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.activity_account_recovery)
public class AccountRecoveryActivity extends FragmentActivity implements LanternHttpClient.ProCallback {

    private static final String TAG = AccountRecoveryActivity.class.getName();
    private static final SessionManager session = LanternApp.getSession();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

    @ViewById
    EditText accountInput;

    @ViewById
    Button linkThisDevice, startRecovery;

    @ViewById
    TextView dontRemember;

    @Click(R.id.linkThisDevice)
    void linkDevice(View view) {
        startActivity(new Intent(this, LinkDeviceActivity_.class));
    }

    @Click(R.id.dontRemember)
    void submitAccount(View view) {
        startActivity(new Intent(this, SubmitAccountActivity_.class));
    }

    @Override
    public void onSuccess(final Response response, final JsonObject result) {
        Logger.debug(TAG, "Account recovery response: " + result);
        final Intent intent;
        if (result.get("token") != null && result.get("userID") != null) {
            Logger.debug(TAG, "Successfully recovered account");
            // update token and user ID with those returned by the pro server
            session.setUserIdAndToken(result.get("userID").getAsInt(), result.get("token").getAsString());
            session.linkDevice();
            session.setIsProUser(true);
            intent = new Intent(this, LanternProActivity.class);
            intent.putExtra("snackbarMsg", getResources().getString(R.string.device_now_linked));
        } else {
            intent = new Intent(this, SubmitAccountActivity_.class);
        }

        startActivity(intent);
        finish();
    }

    @Override
    public void onFailure(final Throwable throwable, final ProError error) {
        if (error == null) {
            Logger.error(TAG, "Unable to recover account and no error to show");
            return;
        }

        final String errorId = error.getId();
        if (errorId.equals("wrong-device")) {
            Logger.debug(TAG, "Sending link request...");
            lanternClient.sendLinkRequest(null);
            startActivity(new Intent(this, RecoveryCodeActivity_.class));
        } else if (errorId.equals("wrong-email") || errorId.equals("cannot-recover-user")) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    dontRemember.setVisibility(View.VISIBLE);
                    Utils.showErrorDialog(AccountRecoveryActivity.this,
                            getResources().getString(R.string.cannot_find_email));
                }
            });
        } else {
            Logger.error(TAG, "Unknown error recovering account:" + error);
        }
    }

    @Click(R.id.startRecovery)
    void startRecovery(View view) {
        final String accountId = accountInput.getText().toString();

        if (accountId == null || accountId.equals("")) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.invalid_email));
            return;
        }

        Logger.debug(TAG, "Start Account recovery with account id " + accountId);

        if (Utils.isEmailValid(accountId)) {
            session.setEmail(accountId);
        }

        session.setAccountId(accountId);

        final RequestBody formBody = new FormBody.Builder()
            .add("email", accountId)
            .build();

        lanternClient.post(LanternHttpClient.createProUrl("/user-recover"), formBody,
                this);
    }
}
