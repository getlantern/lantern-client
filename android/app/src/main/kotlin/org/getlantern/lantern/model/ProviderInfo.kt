package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

enum class PaymentProvider(val provider: String) {
	Stripe("stripe"),
	Freekassa("freekassa")
}

data class ProviderInfo(
	@SerializedName("name") val name: PaymentProvider,
	@SerializedName("data") val data: Map<String, Any>
)