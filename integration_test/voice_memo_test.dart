import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'voice_memo';

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
      'Record a voice memo',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);
        await driver.tapFAB(
          waitText: 'New Chat',
          skipScreenshot: true,
        );
        await driver.tapText(
          'Me',
          waitText:
              'Your chats and voice calls with Me are end-to-end encrypted',
        );

        final recorderButtonFinder = find.byValueKey('recorder_button');

        print('tapping on start record button');
        await driver.longPress(target: recorderButtonFinder);

        print('tapping on stop record button');
        await driver.longPress(target: recorderButtonFinder);

        print('tapping on send');
        await driver.tapKey('send_message');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
