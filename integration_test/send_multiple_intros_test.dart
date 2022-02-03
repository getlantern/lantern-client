import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'send_multiple_intros';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // TODO: finish
  group(testName, () {
    test(
      'Send introductions to multiple contacts',
      () async {
        print('making sure we have enough contacts');
        await driver.tapText(
          'Developer',
          waitText: 'Developer Settings',
          skipScreenshot: true,
        );

        await driver.scrollTextUntilVisible('ADD');

        print('adding dummy contacts');
        await driver.tapText(
          'ADD',
          skipScreenshot: true,
        );
        await driver.tapText(
          'Chats',
          skipScreenshot: false,
        );

        await driver.tapKey(
          'chats_topbar_more_menu',
        );

        // click on Introduce contacts
        await driver.tapText(
          'Introduce Contacts',
        );

        print('tap secret select all intros key');
        await driver.tapKey(
          'select_all_intros',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText('SEND INTRODUCTIONS');

        // we are now back in Chats, go to first message to see our sent invitation
        await driver.tapFirstItemInList('chats_messages_list');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
