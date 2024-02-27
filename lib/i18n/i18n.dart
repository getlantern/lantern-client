import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';
import 'package:lantern/common/common.dart';

extension Localization on String {
  static String defaultLocale = 'en';
  static String locale = defaultLocale;

  static TranslationsByLocale translations =
      Translations.byLocale(defaultLocale);

  static Future<TranslationsByLocale> Function(
    Future<TranslationsByLocale> Function(),
  ) loadTranslationsOnce = once<Future<TranslationsByLocale>>();

  static Future<TranslationsByLocale> ensureInitialized() async {
    return loadTranslationsOnce(() {
      return GettextImporter()
          .fromAssetDirectory('assets/locales')
          .then((value) {
        translations += value;
        return translations;
      });
    });
  }

  static String get localeShort => locale.split('_')[0];

  String doLocalize() => localize(this, translations, locale: locale.replaceAll('_', '-'));

  String get i18n =>
      localize(this, translations, locale: locale.replaceAll('_', '-'));

  String fill(List<Object> params) => localizeFill(this, params);
}
