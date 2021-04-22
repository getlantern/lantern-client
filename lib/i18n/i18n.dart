import 'package:i18n_extension/i18n_extension.dart';
import 'en_us.dart';
import 'es.dart';
import 'package:i18n_extension/io/import.dart';

extension Localization on String {

  static var _t = Translations.byLocale('en_us') +
      {
        'en_us': en_us,
        'es': es,
      };

  static String locale = 'en_us';

  static TranslationsByLocale translations = Translations.byLocale('en_us');

  static Future<void> loadTranslations() async {
    translations += await GettextImporter().fromAssetDirectory('assets/locales');
  }

  String get i18n => localize(this, translations, locale: locale);
}
