import 'package:i18n_extension/i18n_extension.dart';
import 'en_us.dart';
import 'es.dart';

extension Localization on String {
  static var _t = Translations.byLocale("en_us") +
      {
        "en_us": en_us,
        "es": es,
      };

  String get i18n => localize(this, _t);
}
