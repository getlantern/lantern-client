package org.getlantern.lantern.model

import com.google.gson.JsonObject

data class ProError(
	val id: String,
	val message: String,
	val details: JsonObject? = null
) {
	constructor(result: JsonObject) : this(
		result.get("errorId").asString,
		result.get("error").asString,
		result.get("details").asJsonObject,
	)
}