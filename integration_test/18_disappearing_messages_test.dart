import 'integration_test_common.dart';
import 'integration_test_constants.dart';

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
        await driver.tapFirstItemInList('chats_messages_list');

        await driver.typeAndSend(
          'Initially all messages disappear after 24 hours.',
          overwriteTimeout: veryLongWaitTimeout,
        );

        await driver.tapKey(
          'conversation_topbar_more_menu',
          overwriteTimeout: veryLongWaitTimeout,
        );

        await driver.tapText(
          'Disappearing Messages',
          overwriteTimeout: veryLongWaitTimeout,
        );

        await driver.tapText(
          '5 seconds',
          overwriteTimeout: veryLongWaitTimeout,
        );

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
