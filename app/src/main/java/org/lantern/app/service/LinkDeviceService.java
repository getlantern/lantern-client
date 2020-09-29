package org.lantern.app.service;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.Handler;

import org.lantern.app.LanternApp;
import org.lantern.app.activity.LanternProActivity;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.LanternHttpClient;
import org.lantern.app.model.ProError;
import org.lantern.app.model.SessionManager;
import org.lantern.app.R;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.EService;

import java.lang.ref.WeakReference;

@EService
public class LinkDeviceService extends Service implements LanternHttpClient.ProCallback {

    private static final String TAG = LinkDeviceService.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private static final SessionManager session = LanternApp.getSession();

    private final Handler linkDeviceHandler = new Handler();
    private int redeemCalls = 0;
    private int maxRedeemCalls = 20;

    private static final class Redeemable implements Runnable {
        private final WeakReference<LinkDeviceService> service;

        protected Redeemable(LinkDeviceService service) {
            this.service = new WeakReference<LinkDeviceService>(service);
        }

        @Override
        public void run() {
            final LinkDeviceService s = service.get();
            if (s != null) {
                final RequestBody formBody = new FormBody.Builder()
                    .add("code", session.deviceCode())
                    .add("deviceName", session.deviceName())
                    .build();

                lanternClient.post(LanternHttpClient.createProUrl("/link-code-redeem"),
                        formBody, s);
            }
        }
    }

    private void redeemLinkCode() {
        final Double backoff = Math.pow(1.7, this.redeemCalls) / 10;
        final Integer timeOut = 12 * 1000 + backoff.intValue();
        linkDeviceHandler.postDelayed(new Redeemable(this), timeOut);
        this.redeemCalls++;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Logger.debug(TAG, "Link device service: onStartCommand()");
        this.redeemCalls = 0;
        redeemLinkCode();
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        Logger.error(TAG, "Link device service: onDestroy()");
    }

    @Override
    public void onFailure(final Throwable throwable, final ProError error) {
        Logger.error(TAG, "Error making link redeem request..", throwable);
    }

    @Override
    public void onSuccess(final Response response, final JsonObject result) {
        if (result.get("token") == null || result.get("userID") == null) {
            if (redeemCalls >= maxRedeemCalls) {
                Logger.debug(TAG, "Reached max tries attempting to link device..");
                stopSelf();
                return;
            }
            redeemLinkCode();
            return;
        }
        Logger.debug(TAG, "Successfully redeemed link code");
        final Integer userID = result.get("userID").getAsInt();
        final String token = result.get("token").getAsString();
        session.setUserIdAndToken(userID, token);
        Logger.debug(TAG, "Linked device to user " + userID + " whose token is " + token);

        session.linkDevice();
        session.setIsProUser(true);

        try {
            final Context context = getApplicationContext();
            final Intent intent = new Intent(this, LanternProActivity.class);
            intent.putExtra("snackbarMsg",
                    context.getResources().getString(R.string.device_now_linked));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        } catch (Exception e) {
            Logger.error(TAG, "Unable to resume main activity", e);
        } finally {
            stopSelf();
        }
    }
}
