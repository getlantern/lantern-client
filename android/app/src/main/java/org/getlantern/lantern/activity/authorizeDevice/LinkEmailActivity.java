package org.getlantern.lantern.activity.authorizeDevice;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import com.google.gson.JsonObject;
import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.NavigatorKt;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.RecoveryCodeActivity_;
import org.getlantern.lantern.activity.SubmitAccountActivity_;
import org.getlantern.lantern.databinding.ActivityLinkEmailBinding;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

public class LinkEmailActivity extends AppCompatActivity implements LanternHttpClient.ProCallback {
    private static final String TAG = LinkEmailActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

    private ActivityLinkEmailBinding binding;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityLinkEmailBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        binding.btn.setOnClickListener(this::startRecovery);
        binding.btn.setEnabled(false);
        binding.emailLayout.getEditText().addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().length() > 0) {
                    binding.btn.setEnabled(true);
                } else {
                    binding.btn.setEnabled(false);
                }
            }
        });
    }

    @Override
    public void onSuccess(final Response response, final JsonObject result) {
        Logger.debug(TAG, "Account recovery response: " + result);
        if (result.get("token") != null && result.get("userID") != null) {
            Logger.debug(TAG, "Successfully recovered account");
            // update token and user ID with those returned by the pro server
            LanternApp.getSession().setUserIdAndToken(result.get("userID").getAsLong(), result.get("token").getAsString());
            LanternApp.getSession().linkDevice();
            LanternApp.getSession().setIsProUser(true);
            ActivityExtKt.showAlertDialog(
                LinkEmailActivity.this,
                getString(R.string.device_added),
                getString(R.string.device_authorized_pro),
                ContextCompat.getDrawable(LinkEmailActivity.this, R.drawable.ic_filled_check),
                () -> NavigatorKt.openHome(this));
        } else {
            Intent intent = new Intent(this, SubmitAccountActivity_.class);
            startActivity(intent);
            finish();
        }
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
                    ActivityExtKt.showErrorDialog(LinkEmailActivity.this,
                        getResources().getString(R.string.cannot_find_email));
                }
            });
        } else {
            Logger.error(TAG, "Unknown error recovering account:" + error);
        }
    }

    void startRecovery(View view) {
        final String accountId = binding.accountInput.getText().toString();

        if (accountId == null || accountId.equals("")) {
            ActivityExtKt.showErrorDialog(this,
                getResources().getString(R.string.invalid_email));
            return;
        }

        Logger.debug(TAG, "Start Account recovery with account id " + accountId);

        if (Utils.isEmailValid(accountId)) {
            LanternApp.getSession().setEmail(accountId);
        }

        LanternApp.getSession().setAccountId(accountId);

        final RequestBody formBody = new FormBody.Builder()
            .add("email", accountId)
            .build();

        lanternClient.post(LanternHttpClient.createProUrl("/user-recover"), formBody,
            this);
    }
}
