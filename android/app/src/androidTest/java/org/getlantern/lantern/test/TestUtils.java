package org.getlantern.lantern.test;

import android.util.Log;

import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject;
import androidx.test.uiautomator.UiObjectNotFoundException;
import androidx.test.uiautomator.UiSelector;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class TestUtils {
    private static final String TAG = "TestUtils";

    public static void clickButtonIfPresent(UiDevice device, String text) {
        UiObject btn = device.findObject(new UiSelector().text(text));
        if (btn.exists()) {
            try {
                btn.click();
            } catch (UiObjectNotFoundException e) {
                Log.e(TAG, "There is no button to interact with", e);
            }
        }
    }

    /**
     * Downloads a remoteUrl to a local destination.
     *
     * @param remoteUrl
     * @param destination
     * @throws Exception
     */
    public static void downloadToFile(String remoteUrl, File destination) throws Exception {
        URL url = new URL(remoteUrl);
        HttpURLConnection httpConn = (HttpURLConnection) url.openConnection();
        int responseCode = httpConn.getResponseCode();

        // always check HTTP response code first
        if (responseCode == HttpURLConnection.HTTP_OK) {
            String fileName = "";

            // opens input stream from the HTTP connection
            InputStream inputStream = httpConn.getInputStream();
            try {
                // opens an output stream to save into file
                FileOutputStream outputStream = new FileOutputStream(destination);
                try {
                    int bytesRead = -1;
                    byte[] buffer = new byte[4096];
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                } finally {
                    outputStream.close();
                }
            } finally {
                inputStream.close();
            }
        }
    }
}
