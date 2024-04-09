package org.getlantern.lantern.model

import com.android.billingclient.api.BillingClient

interface InAppBillingInterface {
    fun initConnection()
    fun endConnection()
    fun ensureConnected(receivingFunction: BillingClient.() -> Unit)
    fun handlePurchases()
}