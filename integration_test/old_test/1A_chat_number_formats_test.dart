import '../integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.resetFlagsAndEnrollAgain();
      await driver.openTab('Account');
      await driver.tapText('account_management');
      await driver.tapFirstItemInList('account_management_free_list');
    },
  );
}
