package org.getlantern.lantern.model

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
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.SkuDetails
import com.android.billingclient.api.SkuDetailsParams
import com.android.billingclient.api.SkuDetailsResponseListener
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify

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
        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        MockKAnnotations.init(this, relaxUnitFun = true)
        every { builder.setListener(any()) } returns builder
        every { builder.build() } returns billingClient
        inAppBilling = InAppBilling(context, builder, availability)
    }

    @Test
    fun `initConnection start new connection succeeds`() {
        every { billingClient.isReady } returns false
        val listener = slot<BillingClientStateListener>()
        every { billingClient.startConnection(capture(listener)) } answers {
            listener.captured.onBillingSetupFinished(
                BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK)
                    .build()
            )
        }
        every { availability.isGooglePlayServicesAvailable(any()) } returns ConnectionResult.SUCCESS
        inAppBilling.initConnection()
    }

    @Test
    fun `initConnection start new connection fails`() {
        every { billingClient.isReady } returns false
        val listener = slot<BillingClientStateListener>()
        every { billingClient.startConnection(capture(listener)) } answers {
            listener.captured.onBillingSetupFinished(
                BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.ERROR)
                    .build()
            )
        }
        every { availability.isGooglePlayServicesAvailable(any()) } returns ConnectionResult.SUCCESS

        inAppBilling.initConnection()
        //verify { promise.safeReject(any(), any<String>()) }
        //verify(exactly = 0) { promise.resolve(any()) }
    }
}