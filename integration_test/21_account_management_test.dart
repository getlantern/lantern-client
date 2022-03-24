import 'integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account', homeFirst: true);
      await driver.tapText('account_management');
    },
  );
}
