@file:JvmName("_FinderRawMethods")
@file:JvmMultifileClass
package pro.truongsinh.appium_flutter.finder

import java.util.Base64
import kotlinx.serialization.*
import kotlinx.serialization.json.*


val json = Json
val base64encoder = Base64.getUrlEncoder().withoutPadding()
val base64decoder = Base64.getUrlDecoder()

fun serialize(o: Map<String, *>): String {
  val jsonStringified = json.encodeToString(jsonObjectFrom(o))
  val base64Encoded = base64encoder.encodeToString(jsonStringified.toByteArray())
  return base64Encoded
}


fun jsonObjectFrom(o: Map<String, *>): Map<String, JsonElement> {
  return o.map {
    val value = it.value
    val jsonO = when (value) {
      is String -> JsonPrimitive(value)
      is Number -> JsonPrimitive(value)
      is Boolean -> JsonPrimitive(value)
      is Map<*, *> -> JsonPrimitive(json.encodeToString(jsonObjectFrom(value as Map<String, *>)))
      is JsonElement -> value
      else -> JsonNull
    }
    Pair(it.key, jsonO)
  }.toMap()
}

fun deserialize(base64Encoded: String): Map<String, *> {
  val base64Decoded = String(base64decoder.decode(base64Encoded))
  val jsonObject = json.parseToJsonElement(base64Decoded) as JsonObject
  return jsonObject.toMap()
}