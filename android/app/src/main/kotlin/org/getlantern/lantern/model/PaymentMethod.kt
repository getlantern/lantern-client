package org.getlantern.lantern.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class PaymentMethod(val method: String) {
    @SerialName("credit-card")
    CreditCard("credit-card"),

    @SerialName("unionpay")
    UnionPay("unionpay"),

    @SerialName("alipay")
    Alipay("alipay"),

    @SerialName("btc")
    BTC("btc"),

    @SerialName("wechatpay")
    WeChatPay("wechatpay"),

    @SerialName("freekassa")
    Freekassa("freekassa"),

    @SerialName("paymentwall")
    PaymentWall("paymentwall"),

    @SerialName("fropay")
    FroPay("fropay")
}

@Serializable
data class PaymentMethods(
    @SerialName("method") var method: PaymentMethod,
    @SerialName("providers") var providers: List<ProviderInfo>,
)

@Serializable
data class Icons(
    @SerialName("paymentwall") val paymentwall: List<String>,
    @SerialName("stripe") val stripe: List<String>
)
