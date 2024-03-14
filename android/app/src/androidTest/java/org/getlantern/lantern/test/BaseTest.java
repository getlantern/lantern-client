package org.getlantern.lantern.test;

import android.content.Context;

import androidx.test.platform.app.InstrumentationRegistry;

import org.junit.After;
import org.junit.Before;

import java.io.File;
import java.util.Random;

public class BaseTest {
    protected File tempDir = null;

    protected Context getTargetContext() {
        return InstrumentationRegistry.getInstrumentation().getTargetContext();
    }

    @Before
    public void setupTempDir() {
        tempDir = new File(
                getTargetContext().getCacheDir(),
                Long.valueOf(new Random().nextLong()).toString()
        );
        tempDir.mkdirs();
    }

    @After
    public void deleteTempDir() {
        deleteDirectory(tempDir);
    }

    void deleteDirectory(File dir) {
        File[] allContents = dir.listFiles();
        if (allContents != null) {
            for (File file : allContents) {
                deleteDirectory(file);
            }
        }
        dir.delete();
    }
}
