package org.getlantern.mobilesdk.service;

import android.app.IntentService;
import android.content.Intent;

import org.getlantern.mobilesdk.LanternNotRunningException;
import org.getlantern.mobilesdk.LanternServiceManager;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;
import org.getlantern.mobilesdk.embedded.EmbeddedLantern;


/**
 * Service that allows running {@link EmbeddedLantern} in the background. Whenever someone attempts
 * to start the service, it starts Lantern and broadcasts the result so that
 * {@link LanternServiceManager} knows at what address to find the proxy (or how to report an error
 * if Lantern failed to start).
 */
public class LanternService extends IntentService {
    private static final String TAG = "LanternService";

    public LanternService() {
        super("LanternService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Logger.i(TAG, "Starting");
        String configDir = intent.getStringExtra(LanternServiceManager.CONFIG_DIR);
        String locale = intent.getStringExtra(LanternServiceManager.LOCALE);
        final Settings settings = intent.getExtras().getParcelable("config");
        try {
            StartResult result = new EmbeddedLantern().start(configDir, locale, settings, null);
            Intent resultIntent = new Intent(LanternServiceManager.LANTERN_STARTED_INTENT);
            resultIntent.putExtra(LanternServiceManager.HTTP_ADDR, result.getHttpAddr());
            resultIntent.putExtra(LanternServiceManager.SOCKS5_ADDR, result.getSocks5Addr());
            resultIntent.putExtra(LanternServiceManager.DNSGRAB_ADDR, result.getDnsGrabAddr());
            Logger.i(TAG, "Notifying of successful start");
            sendBroadcast(resultIntent);
        } catch (LanternNotRunningException lnre) {
            Intent resultIntent = new Intent(LanternServiceManager.LANTERN_NOT_STARTED_INTENT);
            resultIntent.putExtra(LanternServiceManager.ERROR, lnre.getMessage());
            Logger.i(TAG, "Notifying of failed start");
            sendBroadcast(resultIntent);
        }
    }
}
