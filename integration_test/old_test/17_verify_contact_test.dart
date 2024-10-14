import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'verify_contact';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
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
        await driver.openTab('chats', homeFirst: true);

        await driver.addDummyContacts();

        await driver.tapFAB();

        await driver.tapFirstItemInList('grouped_contact_list');

        await driver.tapKey(
          'verification_badge',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'verify_via_call',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapKey(
          'call_verify_button',
          overwriteTimeout: longWaitTimeout,
        );

        await driver.tapText(
          'mark_as_verified',
          capitalize: true,
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
