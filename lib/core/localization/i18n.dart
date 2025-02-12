import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_importer/src/io/import.dart';
import 'package:lantern/core/utils/common.dart';

extension Localization on String {
  static String defaultLocale = 'en-US';
  static String locale = defaultLocale;

  static Translations translations = Translations.byLocale(defaultLocale);

  static Future<Translations> Function(
    Future<Translations> Function(),
  ) loadTranslationsOnce = once<Future<Translations>>();

  static Future<Translations> ensureInitialized() async {
    return loadTranslationsOnce(() {
      return GettextImporter()
          .fromAssetDirectory('assets/locales')
          .then((value) {
        translations += value;
        return translations;
      });
    });
  }

  String normalizeLocale(String locale) {
    return locale.replaceAll('_', '-').toLowerCase();
  }

  static String get localeShort => locale.split('_')[0];

  String doLocalize() =>
      localize(this, translations, languageTag: normalizeLocale(locale));

  String get i18n =>
      localize(this, translations, languageTag: normalizeLocale(locale));

  String fill(List<Object> params) => localizeFill(this, params);
}
