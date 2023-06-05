package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

enum class PaymentMethod(val method: String) {
    @SerializedName("credit-card")
    CreditCard("credit-card"),

    @SerializedName("unionpay")
    UnionPay("unionpay"),

    @SerializedName("alipay")
    Alipay("alipay"),

    @SerializedName("btc")
    BTC("btc"),

    @SerializedName("wechatpay")
    WeChatPay("wechatpay"),

    @SerializedName("freekassa")
    Freekassa("freekassa"),
}

data class PaymentMethods(
    @SerializedName("method") var method: PaymentMethod,
    @SerializedName("providers") var providers: List<ProviderInfo>,
)
