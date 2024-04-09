package org.getlantern.lantern.test;

import android.content.Context;
import android.util.Log;

import androidx.test.filters.LargeTest;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnit4;

import org.getlantern.lantern.LanternApp;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;
import org.getlantern.mobilesdk.embedded.EmbeddedLantern;
import org.getlantern.mobilesdk.model.SessionManager;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

@RunWith(AndroidJUnit4.class)
@LargeTest
public class ReplicaTest extends BaseTest {
    // Tests if Replica is initialized properly.
    @Test
    public void testReplicaIsInitialized() throws Exception {
        // Initialize internalsdk
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        Settings settings = Settings.init(InstrumentationRegistry.getInstrumentation().getTargetContext());
        settings.shouldRunReplica = true;
        SessionManager session = LanternApp.getSession();
        session.setReplicaAddr("");
        StartResult result = new EmbeddedLantern().start(
                Paths.get(context.getFilesDir().getAbsolutePath(), ".lantern").toString(),
                "en_US", settings, session);

        // Wait for replica to start
        Thread.sleep(5000);
        Log.d("PINEAPPLE", "testReplicaIsInitialized: " + session.getReplicaAddr());
        Assert.assertNotEquals("", session.getReplicaAddr());

        // Assert that /replica routes yield a 200
        for (Map.Entry<String, String> entry : new HashMap<String, String>() {{
            put("replica/heartbeat", "http://" + session.getReplicaAddr() + "/replica/heartbeat");
            put("replica/search", "http://" + session.getReplicaAddr() + "/replica/search?s=hello&page=1&orderBy=relevance&type=web");
        }}.entrySet()) {
            OkHttpClient client = new OkHttpClient();
            Request req = new Request.Builder()
                    .url(entry.getValue())
                    .build();
            Response resp = client.newCall(req).execute();
            Assert.assertEquals(200, resp.code());
        }
    }
}
