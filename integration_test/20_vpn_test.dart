import 'integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('VPN', homeFirst: true);
      await driver.tapType('FlutterSwitch');
    },
  );
}
