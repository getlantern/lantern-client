import 'integration_test_common.dart';

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

  // Test requirements
  // TODO: fix hardcoded timestamp
  group(testName, () {
    test(
      'Delete for everyone',
      () async {
        await driver.screenshotCurrentView();

        await driver.tapFirstItemInList('chats_messages_list');

        print('long press text to reveal menu');
        await driver.longPress(target: '3:16 PM');

        await driver.tapText('Delete for everyone');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
