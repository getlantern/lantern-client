import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Developer', homeFirst: true);
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
      await driver.tapText('chats');

      await driver.tapFirstItemInList('chats_messages_list');

      print('tap on image attachment');
      await driver.tapType(
        'ImageAttachment',
        overwriteTimeout: defaultWaitTimeout,
      );

      await driver.waitForSeconds(2);

      await driver.goBack();
    },
  );
}
