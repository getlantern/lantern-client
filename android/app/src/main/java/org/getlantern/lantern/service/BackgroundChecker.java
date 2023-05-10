package org.getlantern.lantern.service;

import android.app.Service;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import org.androidannotations.annotations.EService;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProUser;
import org.getlantern.lantern.util.LanternHttpClient;
import org.getlantern.mobilesdk.Logger;

import java.lang.ref.WeakReference;

import okhttp3.Response;

@EService
public class BackgroundChecker extends Service implements LanternHttpClient.ProUserCallback {

    private static final String TAG = BackgroundChecker.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private final Handler handler = new Handler();

    private String nextActivity;
    private String provider;

    private boolean asBroadcast;
    // isRenewal returns whether or not the user
    // was Pro when the background checker started
    private boolean isRenewal;
    // numCurrentMonths is how long the user has been
    // Pro when the background checker started
    private int numCurrentProMonths;

    // how many times we've made calls to /user-data
    private int callsMade = 0;
    // the max number of tries we try calling /user-data
    // before giving up
    private int maxCalls = 40;

    private static final class Checker implements Runnable {
        private final WeakReference<BackgroundChecker> service;

        protected Checker(final BackgroundChecker service) {
            this.service = new WeakReference<BackgroundChecker>(service);
        }

        @Override
        public void run() {
            final BackgroundChecker bc = service.get();
            if (bc != null) {
                lanternClient.userData(bc);
            }
        }
    }

    private void sendRequest() {
        if (callsMade >= maxCalls) {
            Logger.debug(TAG, "Reached max tries running background checker..");
            stopSelf();
            return;
        }
        final Double backoff = Math.pow(1.7, this.callsMade) / 10;
        final Integer timeOut = 12 * 1000 + backoff.intValue();
        handler.postDelayed(new Checker(this), timeOut);
        this.callsMade++;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && intent.getExtras() != null) {
            final Bundle extras = intent.getExtras();
            this.asBroadcast = extras.getBoolean("asBroadcast");
            this.isRenewal = extras.getBoolean("renewal");
            this.numCurrentProMonths = extras.getInt("numProMonths");
            this.provider = extras.getString("provider");
            this.maxCalls = extras.getInt("maxCalls");
            this.nextActivity = extras.getString("nextActivity");

            Logger.debug(TAG, "User data background checker: max calls " +
                    this.maxCalls + " " + this.nextActivity);
            sendRequest();
        }
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onSuccess(final Response response, final ProUser user) {
        if (user != null && !user.isProUser()) {
            sendRequest();
            return;
        } else if (user.isProUser() && isRenewal) {
            // check number of months has increased if the user is
            // already Pro
            if (user.monthsLeft() != null &&
                numCurrentProMonths == user.monthsLeft()) {
                sendRequest();
                return;
            }
        }

        try {
            if (asBroadcast) {
                Logger.debug(TAG, "Broadcasting user became Pro");
                final Intent intent = new Intent("userBecamePro");
                LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
            } else {
                final Class<?> next = Class.forName(nextActivity);
                final Intent intent = new Intent(this, next);
                intent.putExtra("provider", provider);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        } catch (Exception e) {
            Logger.error(TAG, "Unable to launch welcome activity", e);
        } finally {
            stopSelf();
        }
    }

    @Override
    public void onFailure(final Throwable throwable, final ProError error) {
        if (error != null) {
            Logger.error(TAG, "Error making user data request:" + error);
        }
    }
}
