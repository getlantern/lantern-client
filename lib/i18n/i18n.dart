
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';
import 'package:lantern/package_store.dart';

import 'en_us.dart';
import 'es.dart';

extension Localization on String {

  static var _t = Translations.byLocale('en_us') +
      {
        'en_us': en_us,
        'es': es,
      };

  static String locale = 'en_US';

  static TranslationsByLocale translations = Translations.byLocale('en');

  static Future<void> loadTranslations() async {
    translations += await GettextImporter().fromAssetDirectory('assets/locales');
  }

  String get i18n => localize(this, translations, locale: locale);

  String displayLanguage(BuildContext context, String languageCode) {
    if (languageCode == 'ar_EG') {
      return 'العربية';
    }
    if (languageCode == 'fa_IR') {
      return 'فارسی-';
    }
    if (languageCode == 'zh_CN') {
      return '中文 (简体)';
    }
    if (languageCode == 'zh_HK') {
      return '中文 (繁體)';
    }
    if (languageCode.contains('_')) {
      List<String> splits = languageCode.split('_');
      if (splits.length > 0) {
        String? displayName = LocaleNames.of(context)?.nameOf(splits.first);
        if (displayName != null) {
          return displayName;
        }
      }
    }
    return 'English';
  }
}
