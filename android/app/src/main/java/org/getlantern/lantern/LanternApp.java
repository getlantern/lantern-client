package org.getlantern.lantern;

import android.app.Activity;
import android.app.Application;
import android.app.Application.ActivityLifecycleCallbacks;
import android.content.Context;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatDelegate;
import androidx.multidex.MultiDex;

import org.getlantern.lantern.model.InAppBilling;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.LanternSessionManager;
import org.getlantern.lantern.model.MessagingHolder;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.lantern.model.WelcomeDialog;
import org.getlantern.lantern.model.WelcomeDialog_;
import org.getlantern.lantern.util.SentryUtil;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.ProdLogger;
import org.getlantern.mobilesdk.util.HttpClient;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.matomo.sdk.Matomo;
import org.matomo.sdk.Tracker;
import org.matomo.sdk.TrackerBuilder;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.ProxySelector;
import java.net.SocketAddress;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

public class LanternApp extends Application implements ActivityLifecycleCallbacks {

    private static final String TAG = LanternApp.class.getName();
    private static Context appContext;
    private static LanternHttpClient lanternHttpClient;
    private static LanternSessionManager session;
    private static InAppBilling inAppBilling;
    private static boolean isForeground;
//    private FirebaseRemoteConfig firebaseRemoteConfig;

//    private static final String FIREBASE_BACKEND_HEADER_PREFIX = "x_lantern_";
//    private static final String FIREBASE_PAYMENT_PROVIDER_KEY = "payment_provider";
//    private static final String FIREBASE_WELCOME_SCREEN_KEY = "welcome_screen";
//    private static final String FIREBASE_WELCOME_SCREEN_NONE = "do_not_show";
//    private static final String FIREBASE_RECENT_INSTALL_USER_PROPERTY = "recent_first_install";
//    private static final long FIREBASE_CACHE_EXPIRATION = 3600; // 1 hour

//    private static final Map<String, Object> firebaseDefaults = Collections.unmodifiableMap(new HashMap<String, Object>() {{
//        put(FIREBASE_WELCOME_SCREEN_KEY, FIREBASE_WELCOME_SCREEN_NONE);
//    }});

    private Activity currentActivity;
    public static final MessagingHolder messaging = new MessagingHolder();

    @Override
    public void onCreate() {
        long start = System.currentTimeMillis();
        super.onCreate();
        Logger.debug(TAG, "super.onCreate() finished at " + (System.currentTimeMillis() - start));

        SentryUtil.enableGoPanicEnrichment(this);

        ProdLogger.enable(getApplicationContext());
        Logger.debug(TAG, "ProdLogger.enable() finished at " + (System.currentTimeMillis() - start));

        registerActivityLifecycleCallbacks(this);
        Logger.debug(TAG, "registerActivityLifecycleCallbacks finished at " + (System.currentTimeMillis() - start));

        // Necessary to locate a back arrow resource we use from the
        // support library. See http://stackoverflow.com/questions/37615470/support-library-vectordrawable-resourcesnotfoundexception
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
        Logger.debug(TAG, "setCompatVectorFromResourcesEnabled finished at " + (System.currentTimeMillis() - start));

        if (!EventBus.getDefault().isRegistered(this)) {
            // we don't have to unregister an EventBus if its
            // in the Application class
            EventBus.getDefault().register(this);
            Logger.debug(TAG, "EventBus.register finished at " + (System.currentTimeMillis() - start));
        }

        appContext = getApplicationContext();
        messaging.init(this);
        Logger.debug(TAG, "messaging.init() finished at " + (System.currentTimeMillis() - start));
        session = new LanternSessionManager(this);
        configureProxySelector();
        Logger.debug(TAG, "new LanternSessionManager finished at " + (System.currentTimeMillis() - start));
        if (LanternApp.getSession().isPlayVersion()) {
            inAppBilling = new InAppBilling(this);
        }
        lanternHttpClient = new LanternHttpClient();
        Logger.debug(TAG, "new LanternHttpClient finished at " + (System.currentTimeMillis() - start));
//        initFirebase();
//        Logger.debug(TAG, "initFirebase() finished at " + (System.currentTimeMillis() - start));
//        updateFirebaseConfig();
//        Logger.debug(TAG, "updateFirebaseConfig() finished at " + (System.currentTimeMillis() - start));

        Logger.debug(TAG, "onCreate() finished at " + (System.currentTimeMillis() - start));
    }

//    private void initFirebase() {
//        final Context context = getApplicationContext();
//
//        // set / reset custom user properties
//        // this can affect remote configuration, a/b tests as well as collected analytics fields
//        FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.getInstance(context);
//        firebaseAnalytics.setUserProperty(FIREBASE_RECENT_INSTALL_USER_PROPERTY, String.valueOf(session.isRecentInstall()));
//
//        firebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
//        FirebaseRemoteConfigSettings.Builder builder = new FirebaseRemoteConfigSettings.Builder();
//        if (Utils.isDebuggable(context)) {
//            builder.setMinimumFetchIntervalInSeconds(3600L).build();
//        }
//        FirebaseRemoteConfigSettings configSettings = builder.build();
//        firebaseRemoteConfig.setConfigSettingsAsync(configSettings);
//        firebaseRemoteConfig.setDefaultsAsync(firebaseDefaults);
//    }

//    private Task<Void> updateFirebaseConfig() {
//        Context context = getApplicationContext();
//        long cacheExpiration = FIREBASE_CACHE_EXPIRATION;
//        if (Utils.isDebuggable(context)) {
//            cacheExpiration = 0;
//        }
//        Task<Void> task = firebaseRemoteConfig.fetch(cacheExpiration);
//        task.addOnCompleteListener(new OnCompleteListener<Void>() {
//            @Override
//            public void onComplete(@NonNull Task<Void> task) {
//                if (task.isSuccessful()) {
//                    Logger.debug(TAG, "Successfully fetched firebase configuration.");
//                    firebaseRemoteConfig.activate();
//                    onFirebaseConfigUpdated();
//                    Logger.debug(TAG, "Firebase IID_TOKEN: " + FirebaseInstallations.getInstance().getToken(false));
//                } else {
//                    Logger.debug(TAG, "Failed to fetch firebase configuration.");
//                }
//            }
//        });
//        return task;
//    }

//    private void onFirebaseConfigUpdated() {
//        // firebase config keys representing backend configuration
//        final Map<String, String> headers = new HashMap<String, String>();
//        for (String key : firebaseRemoteConfig.getKeysByPrefix(FIREBASE_BACKEND_HEADER_PREFIX)) {
//            final String value = firebaseRemoteConfig.getString(key);
//            if (value != null && !value.trim().isEmpty()) {
//                final String headerName = Utils.formatAsHeader(key);
//                Logger.debug(TAG, String.format("firebase set internal header %s = %s", headerName, value));
//                headers.put(headerName, value);
//            }
//        }
//        session.setInternalHeaders(headers);
//
//        final String paymentProvider = firebaseRemoteConfig.getString(FIREBASE_PAYMENT_PROVIDER_KEY);
//        if (!paymentProvider.equals("")) {
//            Logger.debug(TAG, "Setting remote config payment provider to " + paymentProvider);
//            session.setRemoteConfigPaymentProvider(paymentProvider);
//        }
//        if (session.showWelcomeScreen()) {
//            Logger.debug(TAG, "Show welcome screen.");
//            showWelcomeScreen();
//        } else {
//            Logger.debug(TAG, "Skipping welcome screen.");
//        }
//    }

    @Override
    public void onActivityResumed(Activity activity) {
        this.currentActivity = activity;
        if (activity instanceof MainActivity) {
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
        if (activity instanceof MainActivity) {
            Logger.debug(TAG, "Main activity stopped");
            isForeground = false;
        }
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

    private void showWelcomeScreen() {
        if (getCurrentActivity() == null) {
            return;
        }

        String experiment;
        if (session.isProUser() || session.isExpired()) {
            return; // experiment = WelcomeDialog.LAYOUT_RENEWAL;
        } else {
//            experiment = firebaseRemoteConfig.getString(FIREBASE_WELCOME_SCREEN_KEY);
//            Logger.debug(TAG, String.format("welcome_screen = `%s`", experiment));
        }

//        if (!WelcomeDialog.isSupportedLayout(experiment)) {
//            Logger.debug(TAG, String.format("No supported welcome screen configured (`%s`), skipping.", experiment));
//            return;
//        }

        WelcomeDialog welcome = WelcomeDialog_.builder().layout(WelcomeDialog.LAYOUT_DEFAULT).build();
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

    public static HttpClient getHttpClient() {
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
//        // because firebase may be blocked (or otherwise lacking network)
//        // at startup, request an update to the firebase config
//        // whenever the vpn is enabled.
//        if (useVpn.use()) {
//            updateFirebaseConfig();
//        }
    }

    public static LanternSessionManager getSession() {
        return session;
    }

    public static InAppBilling getInAppBilling() {
        return inAppBilling;
    }

    public static void getPlans(LanternHttpClient.PlansCallback cb) {
        lanternHttpClient.getPlans(cb, inAppBilling);
    }

    /**
     * Configures the default ProxySelector to send all traffic to the embedded Lantern proxy.
     */
    private void configureProxySelector() {
        final SocketAddress proxyAddress = addrFromString(session.getSettings().getHttpProxyHost() + ":" +
                session.getSettings().getHttpProxyPort());
        ProxySelector.setDefault(new ProxySelector() {
            @Override
            public List<Proxy> select(URI uri) {
                final List<Proxy> proxiesList = new ArrayList();
                proxiesList.add(new Proxy(Proxy.Type.HTTP, proxyAddress));
                return proxiesList;
            }

            @Override
            public void connectFailed(URI uri, SocketAddress sa, IOException ioe) {
            }
        });
    }

    /**
     * Converts a host:port string into an InetSocketAddress by first making a fake URL using that
     * address.
     *
     * @param addr
     * @return
     */
    private static InetSocketAddress addrFromString(String addr) {
        try {
            URI uri = new URI("my://" + addr);
            return new InetSocketAddress(uri.getHost(), uri.getPort());
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
