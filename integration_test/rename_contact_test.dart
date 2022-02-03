import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'rename_contact';

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
      'Rename a contact',
      () async {
        await driver.screenshotCurrentView();

        await driver.tapFirstItemInList('chats_messages_list');

        print('tap on top right menu bar');
        await driver.tapKey(
          'conversation_topbar_more_menu',
          overwriteTimeout: defaultWaitTimeout,
        );

        print('tap on View Contact Info');
        await driver.tapText(
          'View Contact Info',
          overwriteTimeout: defaultWaitTimeout,
        );

        print('click on EDIT');
        await driver.tapText('EDIT');

        print('enter new contact name');
        await driver.enterText(
          contactNewName,
          timeout: longWaitTimeout,
        );

        await driver.waitForSeconds(2);

        print('tap SAVE');
        await driver.tapText(
          'SAVE',
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
