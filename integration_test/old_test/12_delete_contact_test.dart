import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'delete_contact';

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
      'Delete a contact',
      () async {
        await driver.openTab('chats', homeFirst: true);
        await driver.screenshotCurrentView();

        await driver.tapFirstItemInList('chats_messages_list');

        print('tap on top right menu bar');
        await driver.tapKey(
          'conversation_topbar_more_menu',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          'view_contact_info',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText('delete_contact', capitalize: true);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
