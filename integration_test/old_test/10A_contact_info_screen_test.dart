import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'contact_info_screen_1';

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
        await driver.openTab('chats', homeFirst: true);
        await driver.screenshotCurrentView();

        await driver.longPressFirstItemInList(
          'chats_messages_list',
        );

        await driver.tapText(
          'view_contact_info',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.waitForSeconds(5);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
