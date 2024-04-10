package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

enum class PaymentProvider(val provider: String) {
    @SerializedName("stripe")
    Stripe("stripe"),

    @SerializedName("freekassa")
    Freekassa("freekassa"),

    @SerializedName("googleplay")
    GooglePlay("googleplay"),

    @SerializedName("btcpay")
    BTCPay("btcpay"),

    @SerializedName("reseller-code")
    ResellerCode("reseller-code"),

    @SerializedName("paymentwall")
    PaymentWall("paymentwall")
}

data class ProviderInfo(
    @SerializedName("name") var name: PaymentProvider,
    @SerializedName("data") var data: Map<String, Any>,
    var logoUrl: List<String>
)

