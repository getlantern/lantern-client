import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account');
      await driver.tapText('Authorize Device for Pro', 
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.tapText(
        'Link with PIN',
        capitalize: true,
        overwriteTimeout: defaultWaitTimeout,
      );
    },
  );
}
