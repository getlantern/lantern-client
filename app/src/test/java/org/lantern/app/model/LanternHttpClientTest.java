package org.lantern.app.model;

import org.junit.Assert;
import org.junit.Test;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import okhttp3.OkHttpClient;

public class LanternHttpClientTest {

    @Test
    public void testFetchLoconf() {
        final OkHttpClient httpClient = new OkHttpClient.Builder()
                .retryOnConnectionFailure(true)
                .connectTimeout(15, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .build();
        final LanternHttpClient client = new LanternHttpClient(null, httpClient);
        final AtomicBoolean success = new AtomicBoolean();
        LanternHttpClient.LoConfCallback cb = loconf -> {
            success.set(true);
            synchronized (success) {
                success.notifyAll();
            }
        };
        client.fetchLoConf(cb, "https://raw.githubusercontent.com/getlantern/loconf/master/messages.json");
        synchronized (success) {
            try {
                success.wait(8000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        Assert.assertTrue(success.get());
    }
}
