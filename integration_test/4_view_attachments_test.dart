import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'view_attachments';

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
      'View an image',
      () async {
        await driver.tapText(
          await driver.requestData('Developer'),
          waitText: await driver.requestData('Developer Settings'),
          skipScreenshot: true,
        );
        print('adding dummy contacts');
        await driver.scrollTextUntilVisible('ADD');
        await driver.tapText(
          'ADD',
          skipScreenshot: true,
        );

        print('downloading dummy files');
        await driver.scrollTextUntilVisible('DOWNLOAD');
        await driver.tapText(
          'DOWNLOAD',
          skipScreenshot: true,
        );

        print('sharing dummy attachments to conversation ');
        await driver.scrollTextUntilVisible('SEND FILES');
        await driver.tapText(
          'SEND FILES',
          skipScreenshot: true,
        );

        print('go back to Chats');
        await driver.tapText(
          await driver.requestData('chats'),
        );

        await driver.tapFirstItemInList('chats_messages_list');

        print('tap on image attachment');
        await driver.tapType(
          'ImageAttachment',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.waitForSeconds(2);

        await driver.goBack();
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
    test(
      'View a video',
      () async {
        print('tap on video attachment');
        await driver.tapType(
          'VideoAttachment',
          overwriteTimeout: longWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
