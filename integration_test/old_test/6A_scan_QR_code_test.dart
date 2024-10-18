import '../integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'scan_QR_code';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Needs another phone to scan the QR code with
  group(testName, () {
    test(
      'Scan QR code',
      () async {
        await driver.openTab('chats', homeFirst: true);
        await driver.tapFAB();

        // click on Scan QR Code
        await driver.tapText('scan_qr_code');

        // screenshot and wait
        await driver.screenshotCurrentView();
        await driver.waitForSeconds(1);

        // screenshot and wait
        await driver.screenshotCurrentView();
        await driver.waitForSeconds(1);

        // screenshot and wait
        await driver.screenshotCurrentView();
        await driver.waitForSeconds(1);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
