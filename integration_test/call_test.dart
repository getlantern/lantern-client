import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'call';

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
      'Call a contact',
      () async {
        await driver.screenshotChatsView();

        await driver.tapFirstMessage();

        await driver.tapType(
          'CallAction',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          'Call',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
