import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Discover');
      await driver.tapFAB();
    },
  );
}
