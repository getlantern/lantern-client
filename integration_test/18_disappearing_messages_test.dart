import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'disappearing_messages';

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
      'Test disappearing messages settings',
      () async {
        await driver.tapFAB(
          waitText: 'New Chat',
        );
        await driver.tapText(
          'Me',
          waitText:
              'Your chats and voice calls with Me are end-to-end encrypted',
        );

        print('write and send message');
        await driver
            .typeAndSend('Initially all messages disappear after 24 hours.');
        await driver.typeAndSend('But we can change that.');

        print('tap on topBar menu icon');
        await driver.tapKey('conversation_topbar_more_menu');

        print('tap on Disappearing Messages');
        await driver.tapText(
          'Disappearing Messages',
        );

        print('tap on 5 seconds');
        await driver.tapText(
          '5 seconds',
        );

        print('tap on SET');
        await driver.tapText(
          'SET',
        );

        await driver
            .typeAndSend('Now this message should disappear very soon!');

        await driver.waitForSeconds(5);
        await driver.saveScreenshot('final');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
