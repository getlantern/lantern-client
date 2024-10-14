import 'package:intl/intl.dart';
import 'package:lantern/i18n/localization_constants.dart';

import '../integration_test_common.dart';
import '../integration_test_constants.dart';

Future<void> main() async {
  final lang = toBeginningOfSentenceCase(displayLanguage(simulatedLocale))!;
  await runTest(
    (driver) async {
      await driver.openTab('Account');
      await driver.tapText(
        'settings',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.tapText(
        'language',
        overwriteTimeout: defaultWaitTimeout,
      );
      await driver.scrollTextUntilVisible(lang);
      await driver.tap(find.text(lang));
      await driver.waitForSeconds(2);
    },
  );
}
