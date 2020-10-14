package org.getlantern.lantern;

import android.app.Activity;
import android.app.Application;
import android.app.Application.ActivityLifecycleCallbacks;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.multidex.MultiDex;

import com.github.piasy.biv.BigImageViewer;
import com.github.piasy.biv.loader.glide.GlideImageLoader;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.common.collect.ImmutableMap;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.squareup.leakcanary.LeakCanary;

import org.getlantern.lantern.activity.BaseActivity;
import org.getlantern.lantern.model.BeamSessionManager;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.ProdLogger;
import org.getlantern.mobilesdk.util.HttpClient;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.HashMap;
import java.util.Map;

public class LanternApp extends Application implements ActivityLifecycleCallbacks {

  private static final String TAG = LanternApp.class.getName();
  private static Context appContext;
  private static HttpClient httpClient;
  private static BeamSessionManager session;
  private static boolean isForeground;
  private FirebaseRemoteConfig firebaseRemoteConfig;

  private static final String FIREBASE_BACKEND_HEADER_PREFIX = "x_lantern_";
  private static final String FIREBASE_WELCOME_SCREEN_KEY = "welcome_screen";
  private static final String FIREBASE_WELCOME_SCREEN_NONE = "do_not_show";
  private static final String FIREBASE_RECENT_INSTALL_USER_PROPERTY = "recent_first_install";
  private static final long FIREBASE_CACHE_EXPIRATION = 3600; // 1 hour

  private static final Map<String, Object> firebaseDefaults = ImmutableMap.of(FIREBASE_WELCOME_SCREEN_KEY,
      FIREBASE_WELCOME_SCREEN_NONE);

  private Activity currentActivity;

  @Override
  public void onCreate() {
    super.onCreate();

    if (LeakCanary.isInAnalyzerProcess(this)) {
      // Current process is dedicated to LeakCanary for heap analysis.
      return;
    }

    ProdLogger.enable(getApplicationContext());

    BigImageViewer.initialize(GlideImageLoader.with(getApplicationContext()));
    registerActivityLifecycleCallbacks(this);

    // Necessary to locate a back arrow resource we use from the
    // support library. See http://stackoverflow.com/questions/37615470/support-library-vectordrawable-resourcesnotfoundexception
    AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);

    if (!EventBus.getDefault().isRegistered(this)) {
      // we don't have to unregister an EventBus if its
      // in the Application class
      EventBus.getDefault().register(this);
    }

    appContext = getApplicationContext();
    session = new BeamSessionManager(appContext);
    httpClient = new HttpClient(
            session.getSettings().getHttpProxyHost(),
            (int) session.getSettings().getHttpProxyPort());
    initFirebase();
    updateFirebaseConfig();

    LeakCanary.install(this);
  }

  private void initFirebase() {
    final Context context = getApplicationContext();

    // set / reset custom user properties
    // this can affect remote configuration, a/b tests as well as collected analytics fields
    FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.getInstance(context);
    firebaseAnalytics.setUserProperty(FIREBASE_RECENT_INSTALL_USER_PROPERTY, String.valueOf(session.isRecentInstall()));

    firebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
    FirebaseRemoteConfigSettings configSettings = new FirebaseRemoteConfigSettings.Builder()
        .setDeveloperModeEnabled(Utils.isDebuggable(context)).build();
    firebaseRemoteConfig.setConfigSettings(configSettings);
    firebaseRemoteConfig.setDefaults(firebaseDefaults);
  }

  private Task<Void> updateFirebaseConfig() {
    Context context = getApplicationContext();
    long cacheExpiration = FIREBASE_CACHE_EXPIRATION;
    if (Utils.isDebuggable(context)) {
      cacheExpiration = 0;
    }
    Task<Void> task = firebaseRemoteConfig.fetch(cacheExpiration);
    task.addOnCompleteListener(new OnCompleteListener<Void>() {
      @Override
      public void onComplete(@NonNull Task<Void> task) {
        if (task.isSuccessful()) {
          Logger.debug(TAG, "Successfully fetched firebase configuration.");
          firebaseRemoteConfig.activateFetched();
          onFirebaseConfigUpdated();
          Logger.debug(TAG, "Firebase IID_TOKEN: " + FirebaseInstanceId.getInstance().getToken());
        } else {
          Logger.debug(TAG, "Failed to fetch firebase configuration.");
        }
      }
    });
    return task;
  }

  private void onFirebaseConfigUpdated() {
    // firebase config keys representing backend configuration
    final Map<String, String> headers = new HashMap<String, String>();
    for (String key : firebaseRemoteConfig.getKeysByPrefix(FIREBASE_BACKEND_HEADER_PREFIX)) {
      final String value = firebaseRemoteConfig.getString(key);
      if (value != null && !value.trim().isEmpty()) {
        final String headerName = Utils.formatAsHeader(key);
        Logger.debug(TAG, String.format("firebase set internal header %s = %s", headerName, value));
        headers.put(headerName, value);
      }
    }
    session.setInternalHeaders(headers);
  }

  @Override
  public void onActivityResumed(Activity activity) {
    this.currentActivity = activity;
    if (activity instanceof BaseActivity) {
      Logger.debug(TAG, "Main activity started");
      isForeground = true;
    }
  }

  @Override
  public void onActivityPaused(Activity activity) {
    if (this.currentActivity == activity) {
      this.currentActivity = null;
    }
  }

  @Override
  public void onActivityStarted(Activity activity) {
  }

  @Override
  public void onActivityStopped(Activity activity) {
    if (activity instanceof BaseActivity) {
      Logger.debug(TAG, "Main activity stopped");
      isForeground = false;
    }
  }

  public static HttpClient getHttpClient() {
    return httpClient;
  }

  public static boolean isForeground() {
    return isForeground;
  }

  @Override
  public void onActivityDestroyed(Activity activity) {
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    Logger.debug(TAG, "New activity created " + activity.getClass().getSimpleName());
  }

  public Activity getCurrentActivity() {
    return this.currentActivity;
  }

  public static Context getAppContext() {
    return appContext;
  }

  @Override
  protected void attachBaseContext(Context base) {
    super.attachBaseContext(base);
    // this is necessary running earlier versions of Android
    // multidex support has to be added manually
    // in addition to being enabled in the app build.gradle
    // See http://stackoverflow.com/questions/36907916/java-lang-noclassdeffounderror-while-registering-eventbus-in-onstart-method-for
    MultiDex.install(LanternApp.this);
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onEventMainThread(VpnState useVpn) {
    // because firebase may be blocked (or otherwise lacking network)
    // at startup, request an update to the firebase config
    // whenever the vpn is enabled.
    if (useVpn.use()) {
      updateFirebaseConfig();
    }
  }

  public static BeamSessionManager getSession() {
    return session;
  }
}
