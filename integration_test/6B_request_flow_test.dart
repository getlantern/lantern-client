import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'request_flow';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Needs to have _just_ received a message request from another user
  group(testName, () {
    test(
      'Accept via message request',
      () async {
        await driver.screenshotCurrentView();

        // TODO: cheating here
        print('open message request');
        await driver.tapText(
          await driver.requestData('just_now'),
        );

        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.tapText(
            (await driver.requestData('accept')).toUpperCase(),
            overwriteTimeout: longWaitTimeout,
          ),
          screenshotTitle: 'naming new contact',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
