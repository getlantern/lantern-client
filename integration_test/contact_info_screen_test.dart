import 'package:lantern/common/add_nonbreaking_spaces.dart';

import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'contact_info_screen';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 30));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Access a contact info screen via long tap',
      () async {
        // do the whole reset -> enroll thing
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);
        await driver.tapFAB(
          waitText: 'New Chat',
          skipScreenshot: true,
        );

        // for some reason finding things via key and long pressing them does not want to work
        await driver.waitForSeconds(5);
        await driver.longPressFinder(
          finder: find.text('Add via Chat Number'),
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
