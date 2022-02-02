import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'block_contact';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 30));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Chats view needs to only display a single conversation
  group(testName, () {
    test(
      'Block a contact',
      () async {
        await driver.screenshotChatsView();

        await driver.tapType(
          'ListItemFactory',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapKey(
          'topbar_more_menu',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          'View Contact Info',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText('BLOCK');

        await driver.tapType('Checkbox');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
