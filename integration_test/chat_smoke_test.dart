import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory();
  });

  tearDownAll(() async {
    await driver.close();
  });

  group('smoke_test_chat', () {
    test(
      'Enroll and send message to myself',
      () async {
        await driver.tapText(
          'Developer',
          waitText: 'Developer Settings',
        );
        await driver.scrollTextUntilVisible('RESET FLAGS');
        await driver.tapText('RESET FLAGS');
        await driver.tapText(
          'Chats',
          waitText: 'Welcome to Lantern Chat!',
        );
        await driver.tapText(
          'GET STARTED',
          waitText: 'Chat Number',
        );
        await driver.tapText(
          'NEXT',
          waitText: 'Chats',
        );
        await driver.tapFAB(
          waitText: 'New Chat',
        );
        await driver.tapText(
          'Me',
          waitText:
              'Your chats and voice calls with Me are end-to-end encrypted',
        );
        await driver.tapType('TextFormField');
        await driver.enterText('Hello me', timeout: const Duration(seconds: 5));
        await driver.tapKey('send_message');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
