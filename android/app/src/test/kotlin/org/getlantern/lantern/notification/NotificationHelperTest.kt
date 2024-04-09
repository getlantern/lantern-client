package org.getlantern.lantern.notification

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test

class NotificationHelperTest {

    @MockK
    lateinit var notificationHelper: NotificationHelper

    var receiverSlot = slot<NotificationReceiver>()

    val appContext: Context = mockk(relaxed = true) {
        every {
            getSystemService(Context.NOTIFICATION_SERVICE)
        } returns mockk<NotificationManager>()
    }

    @Before
    fun setUp() {
        MockKAnnotations.init(this, relaxUnitFun = true)
        val receiverIntent = mockk<Intent>()
        every { appContext.registerReceiver(capture(receiverSlot), any()) } returns receiverIntent
        notificationHelper = NotificationHelper(appContext, receiverSlot.captured)
    }

    @After
    fun tearDown() {
        verify(exactly = 1) { appContext.unregisterReceiver(receiverSlot.captured) }
    }

    @Test
    fun `Disconnect broadcast resolves to pending intent`() {
        val receiverIntent = mockk<Intent>()
        every { appContext.registerReceiver(capture(receiverSlot), any()) } returns receiverIntent

        notificationHelper = NotificationHelper(appContext, receiverSlot.captured)
        val intent = Intent("org.getlantern.lantern.intent.VPN_DISCONNECTED")
        val pendingIntent =
            PendingIntent.getBroadcast(
                appContext, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

        every { notificationHelper.disconnectBroadcast() } returns pendingIntent
    }

    @Test
    fun `VPN connected notification`() {
        notificationHelper.vpnConnectedNotification()
    }
}
