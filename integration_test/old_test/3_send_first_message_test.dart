import '../integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('chats', homeFirst: true);

      await driver.tapFAB();

      await driver.tapFirstItemInList('grouped_contact_list');

      print('typing text');
      await driver.typeAndSend('test_hello');
    },
  );
}
