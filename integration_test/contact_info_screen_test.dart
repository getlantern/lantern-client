import 'integration_test_common.dart';
import 'integration_test_constants.dart';

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
      '1/3 Access a contact info screen via long tap',
      () async {
        // do the whole reset -> enroll thing
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);

        // for some reason finding things via key and long pressing them does not want to work
        await driver.waitForSeconds(2);
        await driver.longPress(
          target: find.byType('ListItemFactory'),
        );

        // tap on Contact Info from contextual menu
        await driver.waitForSeconds(2);
        await driver.tapText(
          'View Contact Info',
          overwriteTimeout: defaultWaitTimeout,
        );

        // wait a bit
        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
    test(
      '2/3 Access a contact info screen via top right menu',
      () async {
        // go back
        await driver.goBack();

        // tap to enter conversation
        await driver.waitForSeconds(2);
        await driver.tapType(
          'ListItemFactory',
          overwriteTimeout: defaultWaitTimeout,
        );

        // tap on top right menu bar
        await driver.waitForSeconds(2);
        await driver.tapKey(
          'topbar_more_menu',
          overwriteTimeout: defaultWaitTimeout,
        );

        // tap on View Contact Info
        await driver.waitForSeconds(2);
        await driver.tapText(
          'View Contact Info',
          overwriteTimeout: defaultWaitTimeout,
        );

        // wait a bit
        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
    test(
      '3/3 Access a contact info screen by clicking on contact_info_top_bar key',
      () async {
        // go back
        await driver.goBack();

        // tap to enter conversation
        await driver.waitForSeconds(2);
        await driver.tapType(
          'ListItemFactory',
          overwriteTimeout: defaultWaitTimeout,
        );

        // tap on topbar
        await driver.waitForSeconds(2);
        await driver.tapType(
          'ContactInfoTopBar',
          overwriteTimeout: longWaitTimeout,
        );

        // wait a bit
        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
