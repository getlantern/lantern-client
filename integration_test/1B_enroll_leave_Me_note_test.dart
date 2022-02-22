import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'enroll_leave_Me_note';

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
      'Enroll and send message to myself',
      () async {
        await driver.tapFAB();
        await driver.tapFirstItemInList('grouped_contact_list');
        await driver.typeAndSend(await driver.requestData('test_text'));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
