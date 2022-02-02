import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'add_via_secure_number';

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
      'Send a message to another secure number',
      () async {
        await driver.screenshotChatsView();

        await driver.tapFAB(
          waitText: 'New Chat',
        );

        await driver.tapText(
          'Add via Chat Number',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.waitForSeconds(2);

        print('entering secure chat number');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.enterText(
            textThisNumber,
            timeout: longWaitTimeout,
          ),
          screenshotTitle: 'entering_secure_number',
        );

        await driver.tapText(
          'START CHAT',
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
