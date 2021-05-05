package org.getlantern.lantern.activity.addDevice;

import android.app.ProgressDialog;
import android.content.res.Resources;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;
import com.google.gson.JsonObject;
import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.NavigatorKt;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

@EActivity(R.layout.activity_auth_device)
public class AddDeviceActivity extends FragmentActivity {
    private static final String TAG = AddDeviceActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

    @ViewById
    EditText codeInput;

    private ProgressDialog dialog;

    @AfterViews
    void afterViews() {
        codeInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().length() >= 6) {
                    submit();
                }
            }
        });
    }

    void submit() {
        final Resources res = getResources();

        final String code = codeInput.getText().toString();
        if (code == null || code.equals("")) {
            return;
        }

        dialog = ProgressDialog.show(this,
                "",
                "",
                true, false);
        final RequestBody formBody = new FormBody.Builder()
            .add("code", code)
            .build();
        final AddDeviceActivity activity = this;
        lanternClient.post(LanternHttpClient.createProUrl("/link-code-approve"), formBody,
            new LanternHttpClient.ProCallback() {
                @Override
                public void onFailure(final Throwable throwable, final ProError error) {
                    Logger.error(TAG, "Error retrieving link code: " + error);
                    runOnUiThread(() -> {
                        codeInput.setText("");
                        dialog.cancel();
                    });

                    ActivityExtKt.showErrorDialog(activity,
                        res.getString(R.string.invalid_verification_code));
                }
                @Override
                public void onSuccess(final Response response, final JsonObject result) {
                    ActivityExtKt.showAlertDialog(
                        AddDeviceActivity.this,
                        getString(R.string.device_added),
                        getString(R.string.device_authorized_pro),
                        ContextCompat.getDrawable(AddDeviceActivity.this, R.drawable.ic_filled_check),
                        () -> NavigatorKt.openHome(AddDeviceActivity.this));
                }
            });

    }
}
