import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'send_single_intro';

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
      'Send introduction to a single contact',
      () async {
        print('making sure we have enough contacts');
        await driver.tapText(
          'Developer',
          waitText: 'Developer Settings',
          skipScreenshot: true,
        );

        await driver.scrollTextUntilVisible('ADD');

        print('adding dummy contacts');
        await driver.tapText(
          'ADD',
          skipScreenshot: true,
        );
        await driver.tapText(
          'Chats',
          skipScreenshot: false,
        );

        print('navigating to New Chat');
        await driver.tapFAB();

        print('long pressing first contact in list');
        await driver.longPressFirstItemInList('grouped_contact_list');

        await driver.tapText('Introduce Contact');

        print('select first contact from Introduce list');
        await driver.captureScreenshotDuringFuture(
          futureToScreenshot: driver.tapFirstItemInList('grouped_contact_list'),
          screenshotTitle: 'sending_intros',
        );

        // go back to Chats
        await driver.goBack();

        // tap first item which will display the sent introduction
        await driver.tapFirstItemInList('chats_messages_list');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
