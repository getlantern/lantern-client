package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

enum class PaymentMethod(val method: String) {
	CreditCard("credit-card"),
	UnionPay("unionpay"),
	Alipay("alipay"),
	BTC("btc"),
	WeChatPay("wechatpay"),
	Freekassa("freekassa")
}

data class PaymentProviders(
  @SerializedName("method") val method: PaymentMethod, 
  @SerializedName("providers") val providers: List<ProviderInfo>
)

data class PaymentMethodResponse(
  @SerializedName("providers") val providers: Map<String, List<PaymentProviders>>
)