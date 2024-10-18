import '../integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'react_to_message';

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
      'React to message',
      () async {
        print(
          'This test relies on only one message having the _just now_ timestamp, so lets wait a bit in case other conversations were active recently',
        );
        await driver.waitForSeconds(60);

        await driver.openTab('chats', homeFirst: true);

        await driver.screenshotCurrentView();

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        await driver.typeAndSend('test_text');

        print('long press message we just shared');
        await driver.longPressText('just_now');

        await driver.tapText('copy_text');

        await driver.tapText('reply');

        await driver.typeAndSend('test_reply');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
