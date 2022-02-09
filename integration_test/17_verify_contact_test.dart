import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'verify_contact';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * First message needs to be an unverified contact
  group(testName, () {
    test(
      'Verify a contact via voice call',
      () async {
        await driver.tapText(
          await driver.requestData('Developer'),
          skipScreenshot: true,
        );

        print('adding dummy contacts');
        await driver.scrollTextUntilVisible('ADD');
        await driver.tapText(
          'ADD',
          skipScreenshot: true,
        );

        print('go back to Chats');
        await driver.tapText(await driver.requestData('chats'));

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        await driver.tapKey(
          'verification_badge',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          await driver.requestData('verify_via_call'),
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapKey(
          'call_verify_button',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          (await driver.requestData('mark_as_verified')).toUpperCase(),
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
