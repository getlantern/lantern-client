package org.getlantern.lantern.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class PaymentProvider(val provider: String) {
    @SerialName("stripe")
    Stripe("stripe"),

    @SerialName("freekassa")
    Freekassa("freekassa"),

    @SerialName("googleplay")
    GooglePlay("googleplay"),

    @SerialName("btcpay")
    BTCPay("btcpay"),

    @SerialName("reseller-code")
    ResellerCode("reseller-code"),

    @SerialName("paymentwall")
    PaymentWall("paymentwall"),

    @SerialName("fropay")
	Fropay("fropay")
}

@Serializable
data class ProviderInfo(
    var name: PaymentProvider,
    @SerialName("data") var data: Map<String, String> = mapOf<String, String>(),
    var logoUrl: List<String> = listOf<String>()
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

