import '../integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('chats', homeFirst: true);
      await driver.tapFAB();
      await driver.tapFirstItemInList('grouped_contact_list');
      await driver.typeAndSend('test_text');
    },
  );
}
