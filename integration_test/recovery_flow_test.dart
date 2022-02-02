import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'recovery_flow_test';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 30));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // test requirements
  // * This test requires having a recovery key
  group(testName, () {
    test(
      'Recovery_flow_test',
      () async {
        await driver.tapText(
          'Developer',
          waitText: 'Developer Settings',
          skipScreenshot: true,
        );
        await driver.scrollTextUntilVisible('RESET FLAGS');
        await driver.tapText(
          'RESET FLAGS',
          skipScreenshot: true,
        );
        await driver.tapText(
          'Chats',
          waitText: 'Welcome to Lantern Chat!',
        );

        await driver.tapText('RECOVER', overwriteTimeout: defaultWaitTimeout);

        print('entering recovery key');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.enterText(
            recoveryKey,
          ),
          screenshotTitle: testName,
        );

        await driver.tapText('SUBMIT', overwriteTimeout: defaultWaitTimeout);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
