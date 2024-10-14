import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'disappearing_messages';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Test disappearing messages settings',
      () async {
        await driver.openTab('chats', homeFirst: true);

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        await driver.typeAndSend(
          'test_disappearing_messages_1',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapKey(
          'conversation_topbar_more_menu',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'disappearing_messages',
          overwriteTimeout: longWaitTimeout,
        );

        final five = await driver.requestData('5');
        final seconds =
            (await driver.requestData('longform_seconds')).split(' ')[1];
        await driver.tapText(
          '$five $seconds',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText('set', capitalize: true);

        await driver.typeAndSend('test_disappearing_messages_2');

        await driver.waitForSeconds(5);
        await driver.saveScreenshot('final');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
