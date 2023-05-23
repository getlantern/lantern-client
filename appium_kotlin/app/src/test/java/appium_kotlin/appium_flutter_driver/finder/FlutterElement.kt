package appium_flutter_driver.finder


import org.openqa.selenium.remote.RemoteWebElement
import pro.truongsinh.appium_flutter.finder.serialize

public class FlutterElement : RemoteWebElement {
  private var _rawMap: Map<String, *>
  constructor(m: Map<String, *>) {
    _rawMap = m
    id = serialize(m)
  }
  fun getRawMap():  Map<String, *> { return _rawMap }
}