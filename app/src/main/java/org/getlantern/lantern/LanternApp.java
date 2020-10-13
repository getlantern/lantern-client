package org.getlantern.lantern;

import android.app.Activity;
import android.app.Application;
import android.app.Application.ActivityLifecycleCallbacks;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
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

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.getlantern.lantern.activity.BaseActivity;
import org.getlantern.lantern.model.InAppBilling;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProPlan;
import org.getlantern.mobilesdk.model.SessionManager;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.lantern.model.WelcomeDialog;
import org.getlantern.lantern.model.WelcomeDialog_;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.ProdLogger;

import java.util.HashMap;
import java.util.Map;

public class LanternApp extends Application implements ActivityLifecycleCallbacks {

  private static final String TAG = LanternApp.class.getName();
  private static Context appContext;
  private static LanternHttpClient lanternHttpClient;
  private static SessionManager session;
  private static InAppBilling inAppBilling;
  private static boolean isForeground;
  private static boolean supportsPro;
  private FirebaseRemoteConfig firebaseRemoteConfig;

  private static final String FIREBASE_BACKEND_HEADER_PREFIX = "x_lantern_";
  private static final String FIREBASE_PAYMENT_PROVIDER_KEY = "payment_provider";
  private static final String FIREBASE_WELCOME_SCREEN_KEY = "welcome_screen";
  private static final String FIREBASE_WELCOME_SCREEN_NONE = "do_not_show";
  private static final String FIREBASE_RECENT_INSTALL_USER_PROPERTY = "recent_first_install";
  private static final long FIREBASE_CACHE_EXPIRATION = 3600; // 1 hour

  private static final Map<String, Object> firebaseDefaults = ImmutableMap.of(FIREBASE_WELCOME_SCREEN_KEY,
      FIREBASE_WELCOME_SCREEN_NONE);

  private Activity currentActivity;
  private WelcomeDialog welcome;

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
    try {
      ApplicationInfo ai = getPackageManager().getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA);
      supportsPro = ai.metaData.getBoolean("supportsPro");
    } catch (Exception e) {
      Logger.error(TAG, "Unable to get supportsPro metadata", e);
    }
    Logger.debug(TAG, "Supports pro? %1$s", supportsPro);
    session = new SessionManager(appContext, supportsPro);
    if (Utils.isPlayVersion(this)) {
      inAppBilling = new InAppBilling(this);
    }
    lanternHttpClient = new LanternHttpClient(session, session.getSettings().getHttpProxyHost(),
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

    final String paymentProvider = firebaseRemoteConfig.getString(FIREBASE_PAYMENT_PROVIDER_KEY);
    if (!paymentProvider.equals("")) {
      Logger.debug(TAG, "Setting remote config payment provider to " + paymentProvider);
      session.setRemoteConfigPaymentProvider(paymentProvider);
    }
    if (session.showWelcomeScreen()) {
      Logger.debug(TAG, "Show welcome screen.");
      showWelcomeScreen();
    } else {
      Logger.debug(TAG, "Skipping welcome screen.");
    }
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

  public static boolean isForeground() {
    return isForeground;
  }

  public static boolean supportsPro() {
    return supportsPro;
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

  private void showWelcomeScreen() {
    if (getCurrentActivity() == null) {
      return;
    }

    String experiment;
    if (session.isProUser() || session.isExpired()) {
      return; // experiment = WelcomeDialog.LAYOUT_RENEWAL;
    } else {
      experiment = firebaseRemoteConfig.getString(FIREBASE_WELCOME_SCREEN_KEY);
      Logger.debug(TAG, String.format("welcome_screen = `%s`", experiment));
    }

    if (!WelcomeDialog.isSupportedLayout(experiment)) {
      Logger.debug(TAG, String.format("No supported welcome screen configured (`%s`), skipping.", experiment));
      return;
    }

    welcome = WelcomeDialog_.builder().layout(experiment).build();
    if (welcome == null) {
      Logger.error(TAG, "Could not create welcome screen dialog");
      return;
    }

    session.setWelcomeLastSeen();
    welcome.show(getCurrentActivity().getFragmentManager(), "dialog");
  }

  public static Context getAppContext() {
    return appContext;
  }

  public static LanternHttpClient getLanternHttpClient() {
    return lanternHttpClient;
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

  public static SessionManager getSession() {
    return session;
  }

  public static InAppBilling getInAppBilling() {
    return inAppBilling;
  }

  public static void getPlans(LanternHttpClient.PlansCallback cb) {
    if (Utils.isPlayVersion(appContext)) {
      Map<String, ProPlan> plans = inAppBilling.getPlans();
      cb.onSuccess(plans);
    } else {
      lanternHttpClient.getPlans(cb);
    }
  }
}
