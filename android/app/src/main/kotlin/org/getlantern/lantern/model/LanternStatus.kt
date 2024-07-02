package org.getlantern.lantern.model

import com.google.gson.annotations.SerializedName

enum class LanternStatus(val status: String) {
  @SerializedName("on")
  On("on"),

  @SerializedName("off")
  Off("off")
}