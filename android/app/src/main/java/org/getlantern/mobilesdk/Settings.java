package org.getlantern.mobilesdk;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;

import java.io.InputStream;

public class Settings implements android.Settings {

    private static final String TAG = Settings.class.getName();
    private static final String configFileName = "settings.json";

    @SerializedName("defaultDnsServer")
    private String defaultDnsServer;

    @SerializedName("httpProxyHost")
    private String httpProxyHost;

    @SerializedName("httpProxyPort")
    private long httpProxyPort;

    @SerializedName("enableAdBlocking")
    private boolean enableAdBlocking;

    @SerializedName("stickyConfig")
    private boolean stickyConfig;

    @SerializedName("startTimeoutMillis")
    private long startTimeoutMillis;

    public static Settings init(final Context context) {

        try {
            Gson gson = new Gson();
            InputStream in = context.getAssets().open(configFileName);
            byte[] data = new byte[in.available()];
            in.read(data);
            in.close();
            String configJsonString = new String(data);
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

    public boolean enableAdBlocking() {
        return enableAdBlocking;
    }

    public String defaultDnsServer() {
        return defaultDnsServer;
    }

    public String getHttpProxyHost() {
        return httpProxyHost;
    }

    public long getHttpProxyPort() {
        return httpProxyPort;
    }

    public String toString() {
        return String.format("dns server: %s " + "enable ad blocking %b", defaultDnsServer, enableAdBlocking);
    }
}
