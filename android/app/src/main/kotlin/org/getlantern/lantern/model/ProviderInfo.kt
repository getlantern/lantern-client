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
    PaymentWall("paymentwall"),

    @SerializedName("fropay")
	Fropay("fropay")
}

data class ProviderInfo(
    @SerializedName("name") var name: PaymentProvider,
    @SerializedName("data") var data: Map<String, Any>,
    var logoUrl: List<String>
)

fun String.toPaymentProvider(): PaymentProvider? {
    return when (this) {
        "stripe" -> PaymentProvider.Stripe
        "freekassa" -> PaymentProvider.Freekassa
        "googleplay" -> PaymentProvider.GooglePlay
        "btcpay" -> PaymentProvider.BTCPay
        "reseller-code" -> PaymentProvider.ResellerCode
        "paymentwall" -> PaymentProvider.PaymentWall
        "fropay" -> PaymentProvider.Fropay
        else -> null
    }
}

