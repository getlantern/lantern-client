import 'integration_test_common.dart';
import 'integration_test_constants.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'change_language_test';
  final lang = toBeginningOfSentenceCase(displayLanguage(currentLocale))!;

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Set language to $lang',
      () async {
        await driver.tapText(
          await driver.requestData('Account'),
          waitText: await driver.requestData('Account'),
          overwriteTimeout: defaultWaitTimeout,
          skipScreenshot: true,
        );
        await driver.tapText(
          await driver.requestData('settings'),
          waitText: await driver.requestData('settings'),
          overwriteTimeout: defaultWaitTimeout,
          skipScreenshot: true,
        );
        await driver.tapText(
          await driver.requestData('language'),
          waitText: await driver.requestData('language'),
          overwriteTimeout: defaultWaitTimeout,
          skipScreenshot: true,
        );
        await driver.scrollTextUntilVisible(lang);
        await driver.tapText(
          lang,
          overwriteTimeout: defaultWaitTimeout,
          skipScreenshot: true,
        );
        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
