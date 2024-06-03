import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_importer/src/io/import.dart';
import 'package:lantern/common/common.dart';

extension Localization on String {
  static String defaultLocale = 'en';
  static String locale = defaultLocale;

  static Translations translations =
      Translations.byLocale(defaultLocale);

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

  static String get localeShort => locale.split('_')[0];

  String doLocalize() => localize(this, translations, locale: locale);

  String get i18n => localize(this, translations, locale: locale.replaceFirst('_', '-').toLowerCase());
  // String get i18n => localize(this, translations, locale: 'hi');

  String fill(List<Object> params) => localizeFill(this, params);
}
