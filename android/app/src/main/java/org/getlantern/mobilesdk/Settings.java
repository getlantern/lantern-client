package org.getlantern.mobilesdk;

import android.content.Context;

import com.google.gson.annotations.SerializedName;

import org.getlantern.lantern.util.Json;
import org.getlantern.mobilesdk.features.ReplicaEnabledState;

import java.io.InputStream;

public class Settings implements internalsdk.Settings {

    private static final String TAG = Settings.class.getName();
    private static final String configFileName = "settings.json";

    @SerializedName("httpProxyHost")
    private String httpProxyHost;

    @SerializedName("httpProxyPort")
    private long httpProxyPort;

    @SerializedName("stickyConfig")
    private boolean stickyConfig;

    @SerializedName("startTimeoutMillis")
    private long startTimeoutMillis;

    // Declare as transient so that Gson ignores this
    // XXX <16-12-21, soltzen> See the 'Enabling Replica' section in the README for more info
    public transient ReplicaEnabledState replicaEnabledState = ReplicaEnabledState.GLOBAL_CONFIG;

    public static Settings init(final Context context) {
        try {
            InputStream in = context.getAssets().open(configFileName);
            byte[] data = new byte[in.available()];
            in.read(data);
            in.close();
            String configJsonString = new String(data);
            return Json.gson.fromJson(configJsonString, Settings.class);
        } catch (Exception e) {
            Logger.e(TAG, "Error trying to load settings.json", e);
        }

        return null;
    }

    public long timeoutMillis() {
        return startTimeoutMillis;
    }

    public boolean stickyConfig() {
        return stickyConfig;
    }

    public String getHttpProxyHost() {
        return httpProxyHost;
    }

    public long getHttpProxyPort() {
        return httpProxyPort;
    }

    public long getReplicaEnabledState() {
        return replicaEnabledState.getValue();
    }
}
