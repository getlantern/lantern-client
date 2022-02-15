import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'send_first_message';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Send first message',
      () async {
        await driver.screenshotCurrentView();

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        print('typing text');
        await driver.typeAndSend(
          await driver.requestData('test_hello'),
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
