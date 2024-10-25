import 'package:intl/intl.dart';
import 'package:lantern/core/localization/localization_constants.dart';

import '../../utils/test_utils.dart';

const enUs = 'en_US';
const faIr = 'fa_IR';
final englishLang= toBeginningOfSentenceCase(displayLanguage(enUs));
final persianLang= toBeginningOfSentenceCase(displayLanguage(faIr));

void main() {
  patrolWidget("language end to end test", ($)async {
     await $('Account'.i18n).tap();
    await $.pumpAndSettle();
    await $(AppKeys.setting).tap();
    await $.pumpAndSettle();
    await $(AppKeys.language).tap();
    await $.pumpAndSettle();

    expect($(ListView).visible, true);

    await $(englishLang).tap();
    await $.pumpAndSettle();
    expect(Localization.locale.toLowerCase(), enUs.toLowerCase());

    await $(AppKeys.language).tap();
    await $.pumpAndSettle();

    await $(persianLang).tap();
    await $.pumpAndSettle();
    expect(Localization.locale.toLowerCase(), faIr.toLowerCase());
  },);
}