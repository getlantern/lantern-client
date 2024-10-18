import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Account');
      await driver.tapText(
        'Authorize Device for Pro',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.tapText(
        'Link via Email',
        capitalize: true,
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.typeAndSend('youremail@email.com');
      await driver.tapText(
        'Submit',
        capitalize: true,
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.screenshotCurrentView();
    },
  );
}
