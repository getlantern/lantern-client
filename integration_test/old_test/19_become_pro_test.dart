import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account');
      await driver.tapText(
        'Upgrade to Lantern Pro',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.waitForSeconds(2);
    },
  );
}
