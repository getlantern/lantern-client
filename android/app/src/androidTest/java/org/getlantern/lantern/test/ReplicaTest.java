package org.getlantern.lantern.test;

import androidx.test.filters.LargeTest;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnit4;

import org.getlantern.lantern.LanternApp;
import org.getlantern.mobilesdk.Settings;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import internalsdk.Internalsdk;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

@RunWith(AndroidJUnit4.class)
@LargeTest
public class ReplicaTest extends BaseTest {
    // Tests if Replica is initialized properly. Doesn't really test any of the Replica functionality.
    @Test
    public void testReplicaIsInitialized() {
        try {
            Settings settings = Settings.init(InstrumentationRegistry.getInstrumentation().getTargetContext());
            settings.shouldRunReplica = true;
            Internalsdk.start(
                    Paths.get(
                            InstrumentationRegistry.getInstrumentation().getTargetContext().getFilesDir().getAbsolutePath(),
                            ".lantern").toString(),
                    "en_US", settings, LanternApp.getSession());
        } catch (Exception e) {
            Assert.fail("Unable to start EmbeddedLantern: " + e.getMessage());
        }

        // Assert that /replica routes yield a 200
        for (Map.Entry<String, String> entry : new HashMap<String, String>() {{
            put("replica/heartbeat", "http://localhost:3223/replica/heartbeat");
            put("replica/search", "http://localhost:3223/replica/search?s=hello&page=1&orderBy=relevance&type=web");
        }}.entrySet()) {
            OkHttpClient client = new OkHttpClient();
            try {
                Request req = new Request.Builder()
                        .url(entry.getValue())
                        .build();
                Response resp = client.newCall(req).execute();
                Assert.assertEquals(200, resp.code());
            } catch (IOException e) {
                Assert.fail("Unable to call " + entry.getKey() + ": " + e.getMessage());
            }
        }
    }
}
