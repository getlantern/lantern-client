import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lantern/core/utils/common.dart';


extension Validations on String? {
  String get validateEmail {
    if (this == null) return "";

    return this!.trim();
  }
}

extension PasswordValidations on String {
  bool isPasswordValid() {
    trim(); // Remove spaces at the start and end
    bool has6Characters = length >= 8;
    bool hasUppercase = contains(RegExp(r'[A-Z]'));
    bool hasLowercase = contains(RegExp(r'[a-z]'));
    bool hasNumber = contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacter = contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return has6Characters &&
        hasUppercase &&
        hasLowercase &&
        hasNumber &&
        hasSpecialCharacter;
  }
}

extension PlanExtensions on ProductDetails {
  String get perMonthCost {
    if (id.toLowerCase() == "1m") {
      return price;
    } else if (id.toLowerCase() == "1y") {
      final cost = (rawPrice / 12).toStringAsFixed(2);
      return currencySymbol + cost;
    } else if (id.toLowerCase() == "2y") {
      final cost = (rawPrice / 24).toStringAsFixed(2);
      return currencySymbol + cost;
    }
    return "";
  }
}
