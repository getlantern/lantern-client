import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account');
      await driver.tapText(
        'Settings',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.tapKey(
        'proxy_all_icon',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.tapText(
        'OK',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.tapType(
        'FlutterSwitch',
        overwriteTimeout: defaultWaitTimeout,
      );
    },
  );
}
