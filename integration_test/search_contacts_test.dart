import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'search_contacts';

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
      'Search in Contacts',
      () async {
        await driver.screenshotChatsView();

        await driver.tapFAB(
          waitText: 'New Chat',
        );

        print('tap search icon');
        await driver.tapType(
          'RoundButton',
          overwriteTimeout: defaultWaitTimeout,
        );

        print('enter search term');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.enterText(
            contactNewName.split(' ')[0],
            timeout: longWaitTimeout,
          ),
          screenshotTitle: testName,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
