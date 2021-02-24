package org.getlantern.mobilesdk.model

import okhttp3.OkHttpClient
import org.getlantern.mobilesdk.util.HttpClient
import org.junit.Assert
import org.junit.Test
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

class LoConfTest {
    @Test
    fun testFetchLoconf() {
        val httpClient = OkHttpClient.Builder()
                .retryOnConnectionFailure(true)
                .connectTimeout(15, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .build()
        val client = HttpClient(httpClient)

        val success = AtomicBoolean()
        val _success = success as java.lang.Object
        val cb = LoConfCallback { it ->
            success.set(true)
            synchronized(success) { _success.notifyAll() }
        }

        LoConf.fetch(client, "https://raw.githubusercontent.com/getlantern/loconf/master/messages.json", cb)
        synchronized(success) {
            try {
                _success.wait(8000)
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
        }
        Assert.assertTrue(success.get())
    }
}