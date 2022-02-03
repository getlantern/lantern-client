import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'enroll_leave_Me_note';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // * Test requirements
  // * Data needs to be wiped first (since we are enrolling for first time)
  group(testName, () {
    test(
      'Enroll and send message to myself',
      () async {
        await driver.resetFlagsAndEnrollAgain();
        await driver.tapFAB(
          waitText: 'New Chat',
        );
        await driver.tapText(
          'Me',
          waitText:
              'Your chats and voice calls with Me are end-to-end encrypted',
        );
        await driver.typeAndSend(dummyText);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
