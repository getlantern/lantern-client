import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'call';

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
      'Call a contact',
      () async {
        await driver.screenshotChatsView();

        print('tap to enter conversation');
        await driver.tapType(
          'ListItemFactory',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapType(
          'CallAction',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          'Call',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
