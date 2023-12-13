import 'package:lantern/common/common.dart';

extension ErrorX on Object {
  String get localizedDescription {
    if (this is Exception || this is Error) {
      // Check if the error is a PlatformException
      if (this is PlatformException) {
        // Extract the message from the PlatformException
        String description = (this as PlatformException).message ?? '';
        if (description.contains("user_not_found")) {
          return "user_not_found".i18n;
        }
        if (description.contains("error while sign up")) {
          return "signup_error".i18n;
        } else {
          return description.i18n;
        }
      } else {
        return toString().i18n;
      }
    } else {
      return toString().i18n;
    }
  }
}

extension Validations on String? {
  String get validateEmail {
    if (this == null) return "";

    return this!.trim();
  }
}
