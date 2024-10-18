import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  await runTest((driver) async {
    await driver.openTab('chats', homeFirst: true);

    await driver.tapFAB();

    await driver.tapText(
      'add_via_chat_number',
      overwriteTimeout: longWaitTimeout,
    );

    await driver.waitForSeconds(2);

    print('entering secure chat number');
    await driver.captureScreenshotDuringFuture(
      futureToScreenshot: driver.enterText(
        textThisNumber,
        timeout: longWaitTimeout,
      ),
      screenshotTitle: 'entering_secure_number',
    );

    await driver.tapText(
      'start_chat',
      capitalize: true,
      overwriteTimeout: longWaitTimeout,
    );

    await driver.enterText(contactNewName);

    await driver.waitForSeconds(2);

    await driver.tapText('Done', capitalize: true);
  });
}
