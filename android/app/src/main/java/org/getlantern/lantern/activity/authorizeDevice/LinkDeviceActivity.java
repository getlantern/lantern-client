package org.getlantern.lantern.activity.authorizeDevice;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Handler;
import android.widget.TextView;

import androidx.fragment.app.FragmentActivity;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.MainActivity;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.BaseFragmentActivity;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.lantern.util.LanternHttpClient;
import org.getlantern.mobilesdk.Logger;

import java.lang.ref.WeakReference;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.activity_link_device)
public class LinkDeviceActivity extends BaseFragmentActivity {

    private static final String TAG = LinkDeviceActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private static int maxRedeemCalls = 20;
    private static int initialDelay = 10000; // 10 seconds
    private static int retryDelay = 5000; // 5 seconds

    private final Handler linkDeviceHandler = new Handler();
    private int redeemCalls = 0;

    @ViewById
    TextView deviceLinkingCode;

    @AfterViews
    void afterViews() {
        setDeviceCode(LanternApp.getSession().deviceCode());
    }

    private void requestLinkCode() {
        final Resources res = getResources();
        final LinkDeviceActivity activity = this;
        final RequestBody formBody = new FormBody.Builder()
                .add("deviceName", LanternApp.getSession().deviceName())
                .build();
        lanternClient.post(LanternHttpClient.createProUrl("/link-code-request"), formBody,
                new LanternHttpClient.ProCallback() {
                    @Override
                    public void onFailure(final Throwable throwable, final ProError error) {
                        Logger.error(TAG, "Error retrieving link code: " + error);
                        ActivityExtKt.showErrorDialog(activity,
                                res.getString(R.string.error_device_code));
                    }

                    @Override
                    public void onSuccess(final Response response, final JsonObject result) {
                        Logger.debug(TAG, "Result: " + result);
                        if (result.get("code") != null) {
                            final String code = result.get("code").getAsString();
                            final Long expireAt = result.get("expireAt").getAsLong();
                            LanternApp.getSession().setDeviceCode(code, expireAt);
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    setDeviceCode(code);
                                }
                            });
                            redeemLinkCode(initialDelay);
                        }
                    }
                });
    }

    @Override
    protected void onResume() {
        super.onResume();
        Long codeExp = LanternApp.getSession().getDeviceExp();
        if (codeExp == null || ((codeExp.longValue() - System.currentTimeMillis()) < 60 * 1000)) {
            requestLinkCode();
        } else {
            redeemLinkCode(initialDelay);
        }
    }

    private void setDeviceCode(String code) {
        if (code != null && !code.equals(""))
            deviceLinkingCode.setText(code);
    }

    private void redeemLinkCode(Integer delay) {
        linkDeviceHandler.postDelayed(new RedeemLinkCode(this), delay);
        this.redeemCalls++;
    }

    private void retry() {
        if (redeemCalls >= maxRedeemCalls) {
            Logger.debug(TAG, "Reached max tries attempting to link device..");
            finish();
            return;
        }
        redeemLinkCode(retryDelay);
    }

    private static final class RedeemLinkCode implements Runnable {
        private final WeakReference<LinkDeviceActivity> activity;

        protected RedeemLinkCode(LinkDeviceActivity activity) {
            this.activity = new WeakReference(activity);
        }

        @Override
        public void run() {
            final LinkDeviceActivity a = activity.get();
            if (a != null) {
                final RequestBody formBody = new FormBody.Builder()
                        .add("code", LanternApp.getSession().deviceCode())
                        .add("deviceName", LanternApp.getSession().deviceName())
                        .build();

                lanternClient.post(LanternHttpClient.createProUrl("/link-code-redeem"),
                        formBody, new LanternHttpClient.ProCallback() {
                            @Override
                            public void onFailure(final Throwable throwable, final ProError error) {
                                Logger.error(TAG, "Error making link redeem request..", throwable);
                                a.retry();
                            }

                            @Override
                            public void onSuccess(final Response response, final JsonObject result) {
                                if (result.get("token") == null || result.get("userID") == null) {
                                    a.retry();
                                    return;
                                }
                                Logger.debug(TAG, "Successfully redeemed link code");
                                final Long userID = result.get("userID").getAsLong();
                                final String token = result.get("token").getAsString();
                                LanternApp.getSession().setUserIdAndToken(userID, token);
                                Logger.debug(TAG, "Linked device to user " + userID + " whose token is " + token);

                                LanternApp.getSession().linkDevice();
                                LanternApp.getSession().setIsProUser(true);

                                try {
                                    final Context context = a.getApplicationContext();
                                    final Intent intent = new Intent(a, MainActivity.class);
                                    intent.putExtra("snackbarMsg",
                                            context.getResources().getString(R.string.device_now_linked));
                                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                                    a.startActivity(intent);
                                } catch (Exception e) {
                                    Logger.error(TAG, "Unable to resume main activity", e);
                                }
                            }
                        });
            }
        }
    }
}
