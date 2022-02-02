import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'send_introductions';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Chats view needs to only display a single conversation
  group(testName, () {
    test(
      'Send introduction to a single contact',
      () async {
        await driver.tapText(
          'Developer',
          waitText: 'Developer Settings',
          skipScreenshot: true,
        );

        await driver.scrollTextUntilVisible('ADD');

        // add dummy contacts
        await driver.tapText(
          'ADD',
          skipScreenshot: true,
        );
        await driver.tapText(
          'Chats',
          skipScreenshot: false,
        );

        await driver.longPress(
          target: find.byType('ListItemFactory'),
        );

        await driver.tapText('Introduce Contact');

        // TODO: click on (hardcoded) number from list

        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
    test(
      'Send introduction to a single contact',
      () async {
        // go back

        // click on top right menu

        // click on Introduce contacts

        // select one hard coded number

        // select second hard coded number

        // captureScreenshotDuringFuture on SEND INVITATION click
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
