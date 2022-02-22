import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'chat_number_formats';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // * Test requirements
  // * Run this test first
  group(testName, () {
    test(
      testName,
      () async {
        await driver.resetFlagsAndEnrollAgain();
        await driver.tapText(
          await driver.requestData('Account'),
        );

        await driver.tapText(
          await driver.requestData('account_management'),
        );

        await driver.tapFirstItemInList('account_management_free_list');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
