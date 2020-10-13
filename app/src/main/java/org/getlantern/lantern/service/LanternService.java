package org.getlantern.lantern.service;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.androidannotations.annotations.EService;
import org.greenrobot.eventbus.EventBus;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.model.CheckUpdate;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.LanternStatus;
import org.getlantern.lantern.model.LanternStatus.Status;
import org.getlantern.lantern.model.LoConf;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProUser;
import org.getlantern.mobilesdk.model.SessionManager;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.LanternNotRunningException;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;

import java.util.Random;

import okhttp3.HttpUrl;
import okhttp3.Response;

@EService
public class LanternService extends Service implements Runnable {

  private static final int MAX_CREATE_USER_TRIES = 11;

  private static final String TAG = LanternService.class.getName();
  private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
  private static final SessionManager session = LanternApp.getSession();
  private Thread thread = null;

  private final Handler createUserHandler = new Handler(Looper.getMainLooper());
  private final CreateUser createUserRunnable = new CreateUser();

  private final Random random = new Random();
  // initial number of ms to wait until we try creating a new Pro user
  private final int baseWaitMs = 3000;

  @Override
  public void onCreate() {
    super.onCreate();
    Logger.debug(TAG, "Creating Lantern service");
  }

  @Override
  public IBinder onBind(Intent intent) {
    Logger.d(TAG, "onBind");
    synchronized (session) {
      if (thread == null) {
        Logger.d(TAG, "starting Lantern service thread");
        thread = new Thread(this, "LanternService");
        thread.start();
      } else {
        Logger.debug(TAG, String.format("Thread state: %s", thread.getState()));
      }
    }
    return new Binder();
  }

  @Override
  public void run() {
    // move the current thread of the service to the background
    android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);

    final String locale = session.getLanguage();
    final Settings settings = session.getSettings();
    try {
      Logger.debug(TAG, "Successfully loaded config: " + settings.toString());
      final StartResult result = Lantern.enable(this, locale, session.getSettings(), session);
      session.setStartResult(result);
      afterStart();

    } catch (LanternNotRunningException lnre) {
      Logger.e(TAG, "Unable to start LanternService", lnre);
      throw new RuntimeException("Could not start Lantern", lnre);
    } finally {
      synchronized (session) {
        doStop();
      }
    }
  }

  private void afterStart() {
    if (session.userId() == 0) {
      // create a user if no user id is stored
      createUser(0);
    }

    if (!BuildConfig.PLAY_VERSION) {
      // check if an update is available
      EventBus.getDefault().post(new CheckUpdate(false));
    }

    EventBus.getDefault().post(new LanternStatus(Status.ON));

    // fetch latest loconf
    lanternClient.fetchLoConf(new LanternHttpClient.LoConfCallback() {
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

  private class InvalidUserException extends RuntimeException {
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
      json.addProperty("locale", session.getLanguage());
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
        throw e;
      }
    }

    @Override
    public void onSuccess(final Response response, final JsonObject result) {
      final ProUser user = new Gson().fromJson(result, ProUser.class);
      if (user == null) {
        Logger.error(TAG, "Unable to parse user from JSON");
        return;
      }
      createUserHandler.removeCallbacks(createUserRunnable);
      Logger.debug(TAG, "Created new Lantern user: " + user.newUserDetails());
      session.setUserIdAndToken(user.getUserId(), user.getToken());
      final String referral = user.getReferral();
      if (!TextUtils.isEmpty(referral)) {
        session.setCode(referral);
      }
      EventBus.getDefault().post(new LanternStatus(Status.ON));
    }
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    try {
      Logger.debug(TAG, "Unregistering screen state receiver");
      createUserHandler.removeCallbacks(createUserRunnable);
    } catch (Exception e) {
      Logger.error(TAG, "Exception", e);
    } finally {
      stop();
    }
  }

  private void stop() {
    synchronized (session) {
      if (thread != null) {
        thread.interrupt();
      } else {
        doStop();
      }
    }
  }

  private void doStop() {
    thread = null;
    stopSelf();
  }

  @Override
  public void onTaskRemoved(Intent intent) {
    super.onTaskRemoved(intent);
    Logger.debug(TAG, "Lantern service: onTaskRemoved()");
    stop();
  }
}
