package org.getlantern.mobilesdk;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.HandlerThread;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import android.Session;

/**
 * A {@link Lantern} that uses a service to actually run Lantern. It is important that this class
 * not refer to the LanternService class directly in order to avoid loading the native library.
 */
public class LanternServiceManager extends Lantern {
    private static final String TAG = "LanternServiceManager";

    public static final String CONFIG_DIR = "configDir";
    public static final String TIMEOUT_MILLIS = "timeoutMillis";
    public static final String LOCALE = "locale";
    public static final String STICKY_CONFIG = "stickyConfig";
    public static final String LANTERN_STARTED_INTENT = "org.getlantern.mobilesdk.LANTERN_STARTED_INTENT";
    public static final String LANTERN_NOT_STARTED_INTENT = "org.getlantern.mobilesdk.LANTERN_NOT_STARTED_INTENT";
    public static final String HTTP_ADDR = "HTTP_ADDR";
    public static final String SOCKS5_ADDR = "SOCKS5_ADDR";
    public static final String DNSGRAB_ADDR = "DNSGRAB_ADDR";
    public static final String ERROR = "error";

    // HandlerThread used to handle broadcasts from service
    private static final HandlerThread HANDLER_THREAD;

    static {
        HANDLER_THREAD = new HandlerThread("LanternService-BroadcastHandler");
        HANDLER_THREAD.start();
    }

    @Override
    protected StartResult start(
            final Context context, final String locale,
            final Settings settings, final Session session) throws LanternNotRunningException {

        Logger.i(TAG, "Requesting Start");

        // Wait for broadcast from service
        final CountDownLatch latch = new CountDownLatch(1);
        final AtomicReference<StartResult> result = new AtomicReference<>();
        final AtomicReference<String> error = new AtomicReference<>();
        IntentFilter filter = new IntentFilter();
        filter.addAction(LANTERN_STARTED_INTENT);
        filter.addAction(LANTERN_NOT_STARTED_INTENT);
        // Note - we register the receiver on a separate thread to avoid deadlocking on the main
        // thread (should this method be called from the main thread).
        context.registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (LANTERN_STARTED_INTENT.equals(intent.getAction())) {
                    Logger.i(TAG, "Notified of successful start");
                    result.set(new StartResult(
                            intent.getStringExtra(HTTP_ADDR),
                            intent.getStringExtra(SOCKS5_ADDR),
                            intent.getStringExtra(DNSGRAB_ADDR)
                    ));
                } else {
                    Logger.i(TAG, "Notified of failed start");
                    error.set(intent.getStringExtra(ERROR));
                }
                latch.countDown();
                context.unregisterReceiver(this);
            }
        }, filter, null, new Handler(HANDLER_THREAD.getLooper()));

        Intent intent = serviceIntent(context);
        intent.putExtra(CONFIG_DIR, Lantern.configDirFor(context, "-service"));
        intent.putExtra(TIMEOUT_MILLIS, settings.timeoutMillis());
        intent.putExtra(LOCALE, locale);
        intent.putExtra(STICKY_CONFIG, settings.stickyConfig());
        context.startService(intent);
        try {
            latch.await(settings.timeoutMillis(), TimeUnit.MILLISECONDS);
        } catch (InterruptedException ie) {
            Logger.i(TAG, "Start timed out");
            throw new LanternNotRunningException("EmbeddedLantern not started within " +
                    settings.timeoutMillis() + " ms", ie);
        }
        if (result.get() == null) {
            Logger.i(TAG, "Start failed: " + error.get());
            throw new LanternNotRunningException(error.get());
        }
        Logger.i(TAG, "Start succeeded");
        return result.get();
    }

    private static Intent serviceIntent(Context context) {
        Intent intent = new Intent();
        intent.setComponent(new ComponentName(context, "org.getlantern.mobilesdk.service.LanternService"));
        return intent;
    }
}
