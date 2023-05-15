import 'package:appium_driver/async_io.dart';
import 'package:appium_driver/src/common/flutter_finder.dart';

import 'package:test/test.dart';
import 'dart:developer';
import 'dart:io';

void main() {
  late AppiumWebDriver driver;

  setUpAll(() async {
      driver = await createDriver(
        uri: Uri.parse('http://127.0.0.1:4723/wd/hub/'),
        desired: {
          'platformName': 'android',
          'appium:automationName': 'uiautomator2',
          //'appium:app': 'https://github.com/getlantern/lantern-binaries/raw/main/lantern-installer-beta.apk?raw=true',
          'app': File('lantern-installer-arm32-debug.apk').absolute.path,
          //'appium:appPackage': 'org.getlantern.lantern',
          'appium:appActivity': 'MainActivity',
          //'appium:noReset': true,  // to ensure the device under test clean the app under test.
        });
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('turn VPN on', () async {
    var el = await driver.findElement(AppiumBy.accessibilityId('vpnSwitch'));
    el.click();
  });
}