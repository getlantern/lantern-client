package org.getlantern.lantern.model

import android.content.Context
import androidx.test.platform.app.InstrumentationRegistry
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.AcknowledgePurchaseResponseListener
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.ConsumeResponseListener
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchaseHistoryRecord
import com.android.billingclient.api.PurchaseHistoryResponseListener
import com.android.billingclient.api.PurchasesResponseListener
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.SkuDetails
import com.android.billingclient.api.SkuDetailsParams
import com.android.billingclient.api.SkuDetailsResponseListener
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class InAppBillingTest {

    @MockK
    lateinit var builder: BillingClient.Builder

    @MockK
    lateinit var billingClient: BillingClient

    @MockK
    lateinit var availability: GoogleApiAvailability

    private lateinit var inAppBilling: InAppBilling

    @Before
    fun setUp() {
        val context = mockk<Context>(relaxed = true)
        MockKAnnotations.init(this, relaxUnitFun = true)
        every { builder.setListener(any()) } returns builder
        every { builder.build() } returns billingClient
        inAppBilling = InAppBilling(context, builder, availability)
    }

    private fun playServicesAvailable() =
        every { availability.isGooglePlayServicesAvailable(any()) } returns ConnectionResult.SUCCESS

    @Test
    fun `initConnection new connection succeeds`() {
        every { billingClient.isReady } returns false
        val listener = slot<BillingClientStateListener>()
        every { billingClient.startConnection(capture(listener)) } answers {
            listener.captured.onBillingSetupFinished(
                BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK)
                    .build()
            )
        }
        playServicesAvailable()
        inAppBilling.initConnection()
    }

    @Test
    fun `initConnection new connection fails`() {
        every { billingClient.isReady } returns false
        val listener = slot<BillingClientStateListener>()
        every { billingClient.startConnection(capture(listener)) } answers {
            listener.captured.onBillingSetupFinished(
                BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.ERROR)
                    .build()
            )
        }
        playServicesAvailable()

        inAppBilling.initConnection()
    }

    @Test
    fun `endConnection resolves`() {
        playServicesAvailable()

        inAppBilling.initConnection()
        inAppBilling.endConnection()

        verify { billingClient.endConnection() }
    }

    @Test
    fun `ensureConnection should attempt to reconnect, if not in ready state`() {
        playServicesAvailable()
        var callbackCalled = false
        every { billingClient.isReady } returns true
        val listener = slot<BillingClientStateListener>()
        every { billingClient.startConnection(capture(listener)) } answers {
            listener.captured.onBillingSetupFinished(
                BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK)
                    .build()
            )
        }
        inAppBilling.billingClient = billingClient
        inAppBilling.ensureConnected {
            callbackCalled = true
        }
        assertTrue("Callback should be called", callbackCalled)
    }

    @Test
    fun `handlePendingPurchases successfully handles pending purchases`() {
        playServicesAvailable()
        every { billingClient.isReady } returns true
        val listener = slot<PurchasesResponseListener>()
        every { billingClient.queryPurchasesAsync(any<String>(), capture(listener)) } answers {
            listener.captured.onQueryPurchasesResponse(
                BillingResult.newBuilder().build(),
                listOf(
                    mockk<Purchase> {
                        every { purchaseState } returns 2
                        every { purchaseToken } returns "token"
                    },
                )
            )
        }
        val consumeListener = slot<ConsumeResponseListener>()
        every { billingClient.consumeAsync(any(), capture(consumeListener)) } answers {
            consumeListener.captured.onConsumeResponse(
                BillingResult.newBuilder()
                    .setResponseCode(BillingClient.BillingResponseCode.ITEM_NOT_OWNED).build(),
                ""
            )
        }
        inAppBilling.billingClient = billingClient
        inAppBilling.initConnection()
        verify { inAppBilling.handlePendingPurchases() }
    }
}
