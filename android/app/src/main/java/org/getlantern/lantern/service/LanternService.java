package org.getlantern.lantern.service;

import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.EService;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.CheckUpdate;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.LanternStatus;
import org.getlantern.lantern.model.LanternStatus.Status;
import org.getlantern.lantern.model.AccountInitializationStatus;
import org.getlantern.lantern.util.Json;
import org.getlantern.mobilesdk.model.LoConf;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProUser;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.LanternNotRunningException;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;
import org.getlantern.mobilesdk.model.LoConfCallback;
import org.greenrobot.eventbus.EventBus;

import java.util.Random;
import java.util.concurrent.atomic.AtomicBoolean;

import okhttp3.HttpUrl;
import okhttp3.Response;

@EService
public class LanternService extends Service implements Runnable {

    public static String AUTO_BOOTED = "autoBooted";

    private static final int MAX_CREATE_USER_TRIES = 11;

    private static final String TAG = LanternService.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private Thread thread = null;

    private final Handler createUserHandler = new Handler(Looper.getMainLooper());
    private final CreateUser createUserRunnable = new CreateUser();

    private final Random random = new Random();
    // initial number of ms to wait until we try creating a new Pro user
    private final int baseWaitMs = 3000;

    private final ServiceHelper helper = new ServiceHelper(this, R.drawable.app_icon, R.drawable.status_on, R.string.ready_to_connect);

    private AtomicBoolean started = new AtomicBoolean();

    @Override
    public void onCreate() {
        Logger.debug(TAG, "Creating Lantern service");
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        boolean autoBooted = intent != null && intent.getBooleanExtra(AUTO_BOOTED, false);
        Logger.debug(TAG, "Called onStartCommand, autoBooted?: " + autoBooted);
        if (autoBooted) {
            boolean hasOnboarded = new Boolean(true)
                    .equals(LanternApp.messaging.messaging.getDb().get("onBoardingStatus"));
            if (!hasOnboarded) {
                Logger.debug(TAG, "Attempted to auto boot but user has not onboarded to messaging, stop service");
                stopSelf();
                return START_NOT_STICKY;
            }
        }

        if (started.compareAndSet(false, true)) {
            Logger.debug(TAG, "Starting Lantern service in foreground so that message processing continues even when UI is closed");
            helper.makeForeground();

            Logger.d(TAG, "Starting Lantern service thread");
            thread = new Thread(this, "LanternService");
            thread.start();
        }

        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void run() {
        // move the current thread of the service to the background
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);

        final String locale = LanternApp.getSession().getLanguage();
        final Settings settings = LanternApp.getSession().getSettings();
        try {
            Logger.debug(TAG, "Successfully loaded config: " + settings.toString());
            final StartResult result = Lantern.enable(this, locale, LanternApp.getSession().getSettings(), LanternApp.getSession());
            LanternApp.getSession().setStartResult(result);
            afterStart();

        } catch (LanternNotRunningException lnre) {
            Logger.e(TAG, "Unable to start LanternService", lnre);
            throw new RuntimeException("Could not start Lantern", lnre);
        }
    }

    private void afterStart() {
        if (LanternApp.getSession().userId() == 0) {
            // create a user if no user id is stored
            EventBus.getDefault().post(new AccountInitializationStatus(AccountInitializationStatus.Status.PROCESSING));
            createUser(0);
        }

        if (!BuildConfig.PLAY_VERSION && !BuildConfig.DEVELOPMENT_MODE) {
            // check if an update is available
            EventBus.getDefault().post(new CheckUpdate(false));
        }

        EventBus.getDefault().postSticky(new LanternStatus(Status.ON));

        // fetch latest loconf
        LoConf.Companion.fetch(new LoConfCallback() {
            @Override
            public void onSuccess(final LoConf loconf) {
                EventBus.getDefault().post(loconf);
            }
        });

    }

    private void createUser(final int attempt) {
        final int timeOut = baseWaitMs * Math.max(1, random.nextInt(1 << attempt));
        createUserHandler.postDelayed(createUserRunnable, timeOut);
    }

    private static class InvalidUserException extends RuntimeException {
        public InvalidUserException(String message) {
            super(message);
        }
    }

    private final class CreateUser implements Runnable, LanternHttpClient.ProCallback {

        private int attempts = 0;

        @Override
        public void run() {
            final HttpUrl url = LanternHttpClient.createProUrl("/user-create");
            final JsonObject json = new JsonObject();
            json.addProperty("locale", LanternApp.getSession().getLanguage());
            lanternClient.post(url, LanternHttpClient.createJsonBody(json), this);
        }

        @Override
        public void onFailure(final Throwable throwable, final ProError error) {
            Logger.error(TAG, "Unable to create new Lantern user", throwable);
            if (attempts < MAX_CREATE_USER_TRIES) {
                attempts++;
                createUser(attempts);
            } else {
                final String errorMsg = "Max. number of tries made to create Pro user";
                final InvalidUserException e = new InvalidUserException(errorMsg);
                Logger.error(TAG, errorMsg, e);
                EventBus.getDefault().postSticky(new AccountInitializationStatus(AccountInitializationStatus.Status.FAILURE));
            }
        }

        @Override
        public void onSuccess(final Response response, final JsonObject result) {
            final ProUser user = Json.gson.fromJson(result, ProUser.class);
            if (user == null) {
                Logger.error(TAG, "Unable to parse user from JSON");
                return;
            }
            createUserHandler.removeCallbacks(createUserRunnable);
            Logger.debug(TAG, "Created new Lantern user: " + user.newUserDetails());
            LanternApp.getSession().setUserIdAndToken(user.getUserId(), user.getToken());
            final String referral = user.getReferral();
            if (!TextUtils.isEmpty(referral)) {
                LanternApp.getSession().setCode(referral);
            }
            EventBus.getDefault().postSticky(new LanternStatus(Status.ON));
            EventBus.getDefault().postSticky(new AccountInitializationStatus(AccountInitializationStatus.Status.SUCCESS));
        }
    }

    @Override
    public void onDestroy() {
        Logger.debug(TAG, "Destroying LanternService");
        super.onDestroy();

        if (!started.get()) {
            Logger.debug(TAG, "Service never started, exit immediately");
            return;
        }

        helper.onDestroy();
        thread.interrupt();
        try {
            Logger.debug(TAG, "Unregistering screen state receiver");
            createUserHandler.removeCallbacks(createUserRunnable);
        } catch (Exception e) {
            Logger.error(TAG, "Exception", e);
        }

        // We want to keep the service running as much as possible to allow receiving messages, so
        // we start it back up automatically as explained at https://stackoverflow.com/a/52258125.
        Intent broadcastIntent = new Intent();
        broadcastIntent.setAction("restartservice");
        broadcastIntent.setClass(this, AutoStarter.class);
        this.sendBroadcast(broadcastIntent);
    }
}