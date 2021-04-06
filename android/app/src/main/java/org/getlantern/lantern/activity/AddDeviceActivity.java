package org.getlantern.lantern.activity;


import android.content.Intent;
import android.content.res.Resources;
import android.view.View;

import androidx.fragment.app.FragmentActivity;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.FragmentById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.fragment.UserForm;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.activity_auth_device)
public class AddDeviceActivity extends FragmentActivity {

    private static final String TAG = AddDeviceActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

    @FragmentById(R.id.user_form_fragment)
    UserForm fragment;

    public void sendResult(View view) {
        final Resources res = getResources();

        if (fragment == null) {
            Logger.error(TAG, "Missing fragment in SigninActivity");
            return;
        }

        final String code = fragment.getUserInput();
        if (code == null || code.equals("")) {
            return;
        }

        final RequestBody formBody = new FormBody.Builder()
            .add("code", code)
            .build();
        final AddDeviceActivity activity = this;
        lanternClient.post(LanternHttpClient.createProUrl("/link-code-approve"), formBody,
                    new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Error retrieving link code: " + error);
                ActivityExtKt.showErrorDialog(activity,
                        res.getString(R.string.invalid_verification_code));
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                Intent intent = new Intent(activity, Launcher.class);
                intent.putExtra("snackbarMsg",
                        getResources().getString(R.string.device_linked_success));
                activity.startActivity(intent);
            }
        });


    }
}
