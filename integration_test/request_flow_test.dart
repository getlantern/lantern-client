import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'request_flow';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Chats view needs to only display a single message request
  group(testName, () {
    test(
      'Accept via message request',
      () async {
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.waitForSeconds(2),
          screenshotTitle: 'Chats',
        );

        print('open message request');
        await driver.tapType(
          'ListItemFactory',
        );

        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.tapText(
          'ACCEPT',
          overwriteTimeout: longWaitTimeout,
        ),
          screenshotTitle: 'naming new contact',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
