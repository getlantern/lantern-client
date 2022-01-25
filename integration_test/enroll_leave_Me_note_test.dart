import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'enroll_leave_Me_note_test';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Enroll and send message to myself',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);
        await driver.tapFAB(
          waitText: 'New Chat',
        );
        await driver.tapText(
          'Me',
          waitText:
              'Your chats and voice calls with Me are end-to-end encrypted',
        );
        await driver.typeAndSend('I want to eat some 🍕😊');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
