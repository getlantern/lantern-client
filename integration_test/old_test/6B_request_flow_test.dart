import '../integration_test_common.dart';
import '../integration_test_constants.dart';

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
  // TODO (not immediate): we can set up a second test driver so that one message requests the other
  group(testName, () {
    test(
      'Accept via message request',
      () async {
        await driver.openTab('chats', homeFirst: true);
        await driver.screenshotCurrentView();

        print('open message request');
        await driver.tapText('just_now');

        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.tapText(
            'accept',
            capitalize: true,
            overwriteTimeout: longWaitTimeout,
          ),
          screenshotTitle: 'naming new contact',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
