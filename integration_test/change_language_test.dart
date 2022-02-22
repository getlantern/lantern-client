import 'package:intl/intl.dart';
import 'package:lantern/i18n/localization_constants.dart';

import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'change_language_test';
  final lang = toBeginningOfSentenceCase(displayLanguage(simulatedLocale))!;

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initLocaleFolders();
  });

  tearDownAll(() async {
    await driver.close();
  });

  // * You need to be on Settings Screen to run this test
  group(testName, () {
    test(
      'Set language to $lang',
      () async {
        // we are not using the common driver methods since we don't want to save screenshots
        final languageFinder = await driver.fistItemFinder('settings_list');
        await driver.tap(languageFinder);
        await driver.scrollTextUntilVisible(lang);
        await driver.tap(find.text(lang));
        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
