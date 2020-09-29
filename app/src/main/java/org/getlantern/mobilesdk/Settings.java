package org.getlantern.mobilesdk;

import android.content.Context;
import android.content.res.AssetManager;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.InputStream;

public class Settings implements android.Settings {

    private static final String TAG = Settings.class.getName();
    private static final String configName = "settings.yaml";

    @JsonProperty("defaultDnsServer")
    private String defaultDnsServer;

    @JsonProperty("httpProxyHost")
    private String httpProxyHost;

    @JsonProperty("httpProxyPort")
    private long httpProxyPort;

    @JsonProperty("enableAdBlocking")
    private boolean enableAdBlocking;

    @JsonProperty("stickyConfig")
    private boolean stickyConfig;

    @JsonProperty("startTimeoutMillis")
    private long startTimeoutMillis;

    public static Settings init(final Context context) {
        final AssetManager am = context.getAssets();
        try (InputStream in = am.open(configName)) {
            final ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
            final Settings settings = (Settings)mapper.readValue(in, Settings.class);
            return settings;
        } catch (Exception e) {
            Logger.e(TAG, "Error trying to load settings.yaml", e);
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
        return String.format("dns server: %s " +
                "enable ad blocking %b", defaultDnsServer,
                enableAdBlocking);
    }
}
