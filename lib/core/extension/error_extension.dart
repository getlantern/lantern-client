import '../utils/common.dart';

extension ErrorX on Object {
  String get localizedDescription {
    if (this is Exception || this is Error) {
      // Check if the error is a PlatformException
      if (this is PlatformException) {
        // Extract the message from the PlatformException
        String description = (this as PlatformException).message ?? '';
        if (description.contains("proxy_error")) {
          return "proxy_error".i18n;
        }

        if (description.contains("user_not_found")) {
          return "user_not_found".i18n;
        }
        if (description.contains("invalid_code")) {
          return "invalid_code".i18n;
        }
        if (description.contains("recovery_not_found")) {
          return "recovery_not_found".i18n;
        }

        if (description.contains("wrong-link-code") || description.contains("wrong_device_linking_code")) {
          return "wrong_link_code".i18n;
        }
        if (description
            .contains("we_are_experiencing_technical_difficulties")) {
          return "we_are_experiencing_technical_difficulties".i18n;
        }

        if (description.contains("wrong-reseller-code")) {
          return "wrong_seller_code".i18n;
        }
        if (description.contains("user already exists") ||
            description
                .contains("user with this legacy user ID already exists")) {
          return "signup_error_user_exists".i18n;
        }

        if (description.contains("purchase_not_found") ||
            description.contains("user with provided email not found") ||
            description.contains("no valid purchases for user")) {
          return "purchase_not_found".i18n;
        }
        if (description.contains("err_while_sending_code")) {
          return "err_while_sending_code".i18n;
        }

        if (description.contains("error-wrong-code") ||
            description.contains("<error-email-not-verified>")) {
          return "invalid_code".i18n;
        }

        if (description.contains("error restoring purchase")) {
          return "purchase_restored_error".i18n;
        }

        if (description.contains("error restoring purchase")) {
          return "purchase_restored_error".i18n;
        }
        if (description.contains("wrong_seller_code")) {
          return "wrong_seller_code".i18n;
        }
        if (description.contains("error_referral")) {
          return "error_referral".i18n;
        }

        if (description.contains("error while sign up")) {
          return "signup_error".i18n;
        }

        if (description.contains("errorSubmittingToGooglePlay")) {
          return "errorSubmittingToGooglePlay".i18n;
        }

        return 'we_are_experiencing_technical_difficulties'.i18n;
      } else {
        return toString().i18n;
      }
    } else {
      return toString().i18n;
    }
  }
}
