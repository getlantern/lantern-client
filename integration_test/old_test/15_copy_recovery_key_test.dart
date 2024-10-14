import '../integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'copy_recovery_key';

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
      'Copy Recovery Key',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);
        await driver.openTab('Account');
        await driver.tapText('account_management');
        await driver.tapText('backup_recovery_key');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.tapText(
            'copy_recovery_key',
            capitalize: true,
          ),
          screenshotTitle: testName,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
