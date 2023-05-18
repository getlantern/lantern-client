package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

data class ProviderInfo(
	@SerializedName("name") val name: String,
	@SerializedName("data") val data: Map<String, Any>
)