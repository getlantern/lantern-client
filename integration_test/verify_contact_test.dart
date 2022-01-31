import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'verify_contact';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Chats view needs to only display a single conversation, with an unverified contact
  group(testName, () {
    test(
      'Verify a contact via voice call',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);

        print('tap to enter conversation');
        await driver.tapType(
          'ListItemFactory',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapKey(
          'verification_badge',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          'Verify via voice call',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapKey(
          'call_verify_button',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'MARK AS VERIFIED',
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
