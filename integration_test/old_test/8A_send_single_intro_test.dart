import '../integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'send_single_intro';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Send introduction to a single contact',
      () async {
        await driver.openTab('chats', homeFirst: true);

        await driver.addDummyContacts();

        print('navigating to New Chat');
        await driver.tapFAB();

        print('long pressing first contact in list');
        await driver.longPressFirstItemInList('grouped_contact_list');

        await driver.tapText('introduce_contact');

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
