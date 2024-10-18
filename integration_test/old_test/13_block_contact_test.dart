import '../integration_test_common.dart';
import '../integration_test_constants.dart';

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

  group(testName, () {
    test(
      'Block a contact',
      () async {
        await driver.openTab('chats', homeFirst: true);
        await driver.screenshotCurrentView();

        await driver.tapFirstItemInList('chats_messages_list');

        await driver.tapKey(
          'conversation_topbar_more_menu',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'view_contact_info',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'block',
          capitalize: true,
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapType(
          'Checkbox',
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
