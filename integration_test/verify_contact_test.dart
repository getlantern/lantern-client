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
  // * First message needs to be an unverified contact
  group(testName, () {
    test(
      'Verify a contact via voice call',
      () async {
        await driver.screenshotCurrentView();

        await driver.tapFirstItemInList('chats_messages_list');

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
