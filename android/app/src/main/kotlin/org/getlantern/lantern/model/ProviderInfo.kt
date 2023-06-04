package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

enum class PaymentProvider(val provider: String) {
	Stripe("stripe"),
	Freekassa("freekassa"),
	GooglePlay("googleplay"),
	BTCPay("btcpay"),
	ResellerCode("resellercode")
}

data class ProviderInfo(
	@SerializedName("name") var name: PaymentProvider,
	@SerializedName("data") var data: Map<String, Any>
)