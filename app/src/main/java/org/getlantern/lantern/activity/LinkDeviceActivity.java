package org.getlantern.lantern.activity;

import android.content.Intent;
import android.content.res.Resources;
import androidx.fragment.app.FragmentActivity;
import android.widget.TextView;

import org.getlantern.lantern.LanternApp;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.SessionManager;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.service.LinkDeviceService_;
import org.getlantern.lantern.R;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

import com.google.gson.JsonObject;
import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.activity_link_device)
public class LinkDeviceActivity extends FragmentActivity {

    private static final String TAG = LinkDeviceActivity.class.getName();
    private static final SessionManager session = LanternApp.getSession();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

    @ViewById
    TextView deviceLinkingCode;

    @AfterViews
    void afterViews() {
        setDeviceCode(session.deviceCode());
        startService(new Intent(this, LinkDeviceService_.class));
    }

    private void requestLinkCode() {
        final Resources res = getResources();
        final LinkDeviceActivity activity = this;
        final RequestBody formBody = new FormBody.Builder()
            .add("deviceName", session.deviceName())
            .build();
        lanternClient.post(LanternHttpClient.createProUrl("/link-code-request"), formBody,
                new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Error retrieving link code: " + error);
                Utils.showUIErrorDialog(activity,
                        res.getString(R.string.error_device_code));
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                Logger.debug(TAG, "Result: " + result);
                if (result.get("code") != null) {
                    final String code = result.get("code").getAsString();
                    final Long expireAt = result.get("expireAt").getAsLong();
                    session.setDeviceCode(code, expireAt);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            setDeviceCode(code);
                        }
                    });
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        Long codeExp = session.getDeviceExp();
        if (codeExp == null || ((codeExp.longValue() - System.currentTimeMillis()) < 60*1000)) {
            requestLinkCode();
        }
    }

    private void setDeviceCode(String code) {
        if (code != null && !code.equals(""))
            deviceLinkingCode.setText(code);
    }
}
