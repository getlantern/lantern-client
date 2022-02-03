import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'delete_for_everyone';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // * Test requirements
  // * This test identifies a message by the "just now" timestamp, so make sure there is not a very recently shared message in any conversation (to avoid having multiple "just now" matches)
  group(testName, () {
    test(
      'Delete for everyone',
      () async {
        await driver.screenshotCurrentView();

        await driver.tapFirstItemInList('chats_messages_list');

        await driver.typeAndSend(dummyText);
        print('long press message we just shared');
        await driver.longPress(target: find.text('just now'));

        await driver.tapText('Delete for everyone');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
