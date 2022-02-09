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

  group(testName, () {
    test(
      'Recovery_flow_test',
      () async {
        await driver.tapText(
          await driver.requestData('Developer'),
          skipScreenshot: true,
        );
        await driver.scrollTextUntilVisible('RESET FLAGS');
        await driver.tapText(
          'RESET FLAGS',
          skipScreenshot: true,
        );
        await driver.tapText(
          await driver.requestData('chats'),
          waitText: await driver.requestData('welcome_title'),
        );

        await driver.tapText(
            (await driver.requestData('recover')).toUpperCase(),
            overwriteTimeout: defaultWaitTimeout);

        print('entering recovery key');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.enterText(
            recoveryKey,
          ),
          screenshotTitle: testName,
        );

        await driver.tapText((await driver.requestData('Submit')).toUpperCase(),
            overwriteTimeout: defaultWaitTimeout);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
