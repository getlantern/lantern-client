package org.getlantern.mobilesdk;

import android.content.Context;

import com.google.gson.annotations.SerializedName;

import com.google.gson.Gson;

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
    // TODO <13-10-21, soltzen> We'll set this to true always in the future,
    // when Replica is ready on mobile. For now, just keep it public and easy
    // to work with
    // TODO <08-08-22, kalli> Implement above comment?
    public transient boolean shouldRunReplica = true;

    public static Settings init(final Context context) {
        try {
            InputStream in = context.getAssets().open(configFileName);
            byte[] data = new byte[in.available()];
            in.read(data);
            in.close();
            String configJsonString = new String(data);
            final Gson gson = new Gson();
            return gson.fromJson(configJsonString, Settings.class);
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

    public boolean shouldRunReplica() {
        return shouldRunReplica;
    }
}
