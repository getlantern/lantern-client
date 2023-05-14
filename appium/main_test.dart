import 'package:appium_driver/async_io.dart';
import 'package:appium_driver/src/common/flutter_finder.dart';

import 'package:test/test.dart';

void main() {
  late AppiumWebDriver driver;

  setUpAll(() async {
        uri: Uri.parse('http://127.0.0.1:4723/wd/hub/'),
        desired: {
          'platformName': 'android',
          'appium:automationName': 'uiautomator2',
          'appium:app': 'https://github.com/getlantern/lantern-binaries/raw/main/lantern-installer-beta.apk?raw=true',
          // This UDID should update for your environment.
          'appium:udid': '3259335743313498',
          'appium:appPackage': 'org.getlantern.lantern',
          'appium:fullReset': true,  // to ensure the device under test clean the app under test.
        });
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('click increment 10 times', () async {

  });
}