@file:JvmName("_FinderRawMethods")
@file:JvmMultifileClass
package appium_flutter_driver.finder

fun descendant(of: FlutterElement, matching: FlutterElement, matchRoot: Boolean = false): FlutterElement {
  val m = mutableMapOf(
    "finderType" to "Descendant",
    "matchRoot" to matchRoot
  )
  of.getRawMap().forEach {
    m.put("of_${it.key}", it.value!! as String)
  }
  matching.getRawMap().forEach {
    m.put("matching_${it.key}", it.value!! as String)
  }
  return FlutterElement(m)
}
