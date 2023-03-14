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
//import org.getlantern.lantern.model.MessagingHolder;
import org.getlantern.lantern.model.WelcomeDialog;
import org.getlantern.lantern.model.WelcomeDialog_;
import org.getlantern.lantern.util.SentryUtil;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.ProdLogger;
import org.getlantern.mobilesdk.util.HttpClient;
import org.greenrobot.eventbus.EventBus;

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
    private Activity currentActivity;
//    public static final MessagingHolder messaging = new MessagingHolder();

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

        appContext = getApplicationContext();
//        messaging.init(this);
//        Logger.debug(TAG, "messaging.init() finished at " + (System.currentTimeMillis() - start));
        session = new LanternSessionManager(this);
        configureProxySelector();
        Logger.debug(TAG, "new LanternSessionManager finished at " + (System.currentTimeMillis() - start));
        if (LanternApp.getSession().isPlayVersion()) {
            inAppBilling = new InAppBilling(this);
        }
        lanternHttpClient = new LanternHttpClient();
        Logger.debug(TAG, "new LanternHttpClient finished at " + (System.currentTimeMillis() - start));
        Logger.debug(TAG, "onCreate() finished at " + (System.currentTimeMillis() - start));
    }

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

    public static LanternSessionManager getSession() {
        return session;
    }

    public static InAppBilling getInAppBilling() {
        return inAppBilling;
    }

    public static void getPlans(LanternHttpClient.PlansCallback cb) {
        InAppBilling iab = inAppBilling;
        if (session.isRussianUser()) {
            // In Russia, we neve user inAppBilling even on play store installs
            iab = null;
        }
        lanternHttpClient.getPlans(cb, inAppBilling);
    }

    /**
     * Configures the default ProxySelector to send all traffic to the embedded Lantern proxy.
     */
    private void configureProxySelector() {
        ProxySelector.setDefault(new ProxySelector() {
            @Override
            public List<Proxy> select(URI uri) {
                final SocketAddress proxyAddress = addrFromString(session.getSettings().getHttpProxyHost() + ":" +
                        session.getSettings().getHttpProxyPort());
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
