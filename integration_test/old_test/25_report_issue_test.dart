import '../integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account');
      await driver.tapText('Settings');
      await driver.tapText('report_issue');
      // TODO: select issue from dropdown
      // TODO: enter text
      // TODO: test submit
    },
  );
}
