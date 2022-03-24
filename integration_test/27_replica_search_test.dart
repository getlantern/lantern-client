import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('Discover', homeFirst: true);
      final messageContent = await driver.translate('test_replica_search');
      await driver.waitForSeconds(2);
      await driver.tapType(
        'SearchField',
        overwriteTimeout: longWaitTimeout,
      );
      await driver.captureScreenshotDuringFuture(
        futureToScreenshot: driver.enterText(
          messageContent,
          timeout: longWaitTimeout,
        ),
        screenshotTitle: 'sending_message',
      );
      await driver.tapKey('submit_text_field');

      print('viewing a Replica video');
      await driver.waitForSeconds(5);
      await driver.screenshotCurrentView();
      await driver.tapFirstItemInList('replica_tab_view');
      await driver.waitForSeconds(5);
      await driver.screenshotCurrentView();
    },
  );
}
