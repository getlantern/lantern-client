import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'search_contacts_messages';

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
      'Search in Messages and Contacts',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);

        print('tap search icon');
        await driver.tapKey(
          'search_icon',
          overwriteTimeout: defaultWaitTimeout,
        );

        print('enter search term');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.enterText(
            'Lorem ipsum',
            timeout: longWaitTimeout,
          ),
          screenshotTitle: testName,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
