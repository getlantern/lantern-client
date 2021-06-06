import 'package:flutter/material.dart';

class Validators {
  static const String _regexUsername = r"^(?=.*[\w])(?=.{1,}[^\d]).{4,28}$";
   static const String _regexPassword = r"^(?=.*\d)(?=.*[\w])(?=.{1,}[^\d]).{6,20}$";

  static bool validateUsername(String value) {
    return RegExp(_regexUsername).hasMatch(value);
  }

  static FormFieldValidator<String> usernameValidator() {
    return (String value) {
      if (validateUsername(value)) {
        return null;
      }
      return "Username must be between 4 and 28 characters";
    };
  }

  static FormFieldValidator<String> passwordValidator() {
    return (String value) {
      if (RegExp(_regexPassword).hasMatch(value)) {
        return null;
      }
      return "Password must contain at least 1 letter, 1 number and be between 6 and 20 characters";
    };
  }

  static FormFieldValidator<String> confirmPasswordValidator(TextEditingController passwordController) {
    return (String value) {
      if (value != passwordController.text) return "Passwords must match";
      return null;
    };
  }

}