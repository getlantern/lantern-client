import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'react_to_message';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // Test requirements
  // * Chats view needs to only display a single conversation
  // * Hardcoded timestamp
  group(testName, () {
    test(
      'React to message',
      () async {
        await driver.screenshotChatsView();

        print('accessing conversation');
        await driver.tapType(
          'ListItemFactory',
        );

        // TODO: generalize
        print('long press text to reveal menu');
        await driver.longPress(target: 'yesterday');

        print('copy text');
        await driver.tapText('Copy Text');

        print('reply');
        await driver.tapText('Reply');

        print('typing text');
        await driver.typeAndSend(
          'Hi how are you?',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
