package org.getlantern.lantern.test

import android.util.Log
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject
import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL

class TestUtils {
    companion object {
        private val TAG = TestUtils::class.java.simpleName

        fun clickButtonIfPresent(device: UiDevice, text: String) {
            val btn = device.findObject(UiSelector().text(text))
            if (btn.exists()) {
                try {
                    btn.click()
                } catch (e: UiObjectNotFoundException) {
                    Log.e(TAG, "There is no button to interact with", e)
                }
            }
        }

        // Downloads a remoteUrl to a local destination.
        fun downloadToFile(remoteUrl: String, destination: File) {
            val url = URL(remoteUrl)
            val httpConn: HttpURLConnection = url.openConnection() as HttpURLConnection
            val responseCode = httpConn.responseCode
            if (responseCode != HttpURLConnection.HTTP_OK) return
            val inputStream = httpConn.inputStream
            try {
                val outputStream = FileOutputStream(destination)
                try {
                    var bytesRead = 0
                    val buffer = ByteArray(4096)
                    while (bytesRead != -1) {
                        bytesRead = inputStream.read(buffer)
                        outputStream.write(buffer, 0, bytesRead)
                    }
                } finally {
                    outputStream.close();
                }
            } finally {
                inputStream.close()
            }

        }
    }
}
