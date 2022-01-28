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

  group(testName, () {
    test(
      'React to message',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);

        print('accessing conversation');
        await driver.tapType(
          'ListItemFactory',
        );

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
