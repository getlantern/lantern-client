import 'integration_test_common.dart';

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
          'HACK: this test relies on only one message having the _just now_ timestamp, so lets wait a bit in case other conversations were active recently',
        );
        await driver.waitForSeconds(60);

        await driver.screenshotCurrentView();

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        await driver.typeAndSend(await driver.requestData('test_text'));

        print('long press message we just shared');
        await driver.longPress(
          target: find.text(await driver.requestData('just_now')),
        );

        await driver.tapText(await driver.requestData('copy_text'));

        await driver.tapText(await driver.requestData('reply'));

        await driver.typeAndSend(
          await driver.requestData('test_reply'),
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
