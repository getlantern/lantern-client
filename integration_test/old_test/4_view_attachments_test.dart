import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('chats', homeFirst: true);

      await driver.addDummyContacts();

      await driver.sendDummyFiles();

      await driver.tapFirstItemInList('chats_messages_list');

      print('tapping on image attachment');
      await driver.tapType(
        'ImageAttachment',
        overwriteTimeout: longWaitTimeout,
      );

      await driver.goBack();

      await driver.tapType(
        'VideoAttachment',
        overwriteTimeout: longWaitTimeout,
      );
    },
  );
}
