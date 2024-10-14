import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'call';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Call a contact',
      () async {
        await driver.openTab('chats', homeFirst: true);
        await driver.screenshotCurrentView();

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        await driver.tapType(
          'CallAction',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'call',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
