package org.getlantern.lantern.model

data class Stats(
  val city: String = "",
  val country: String = "",
  val countryCode: String = "",
  val httpsUpgrades: Long = 0,
  val adsBlocked: Long = 0,
  val hasSucceedingProxy:Boolean = false
) {

}