import 'integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account', homeFirst: true);
      await driver.tapText('desktop_version');
      await driver.tapText('Share link', capitalize: true);
    },
  );
}
