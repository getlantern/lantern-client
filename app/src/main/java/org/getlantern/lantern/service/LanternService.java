package org.getlantern.lantern.service;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import org.androidannotations.annotations.EService;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.model.CheckUpdate;
import org.getlantern.lantern.model.LanternStatus;
import org.getlantern.lantern.model.LanternStatus.Status;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.LanternNotRunningException;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;
import org.getlantern.mobilesdk.model.LoConf;
import org.greenrobot.eventbus.EventBus;

import java.util.Random;

@EService
public class LanternService extends Service implements Runnable {

  private static final int MAX_CREATE_USER_TRIES = 11;

  private static final String TAG = LanternService.class.getName();
  private Thread thread = null;

  private final Handler createUserHandler = new Handler(Looper.getMainLooper());

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
    synchronized (LanternApp.getSession()) {
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
    } finally {
      synchronized (LanternApp.getSession()) {
        doStop();
      }
    }
  }

  private void afterStart() {
    if (!BuildConfig.PLAY_VERSION) {
      // check if an update is available
      EventBus.getDefault().post(new CheckUpdate(false));
    }

    EventBus.getDefault().post(new LanternStatus(Status.ON));

    // fetch latest loconf
    LoConf.Companion.fetch(loconf -> EventBus.getDefault().post(loconf));
  }

  private void stop() {
    synchronized (LanternApp.getSession()) {
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
