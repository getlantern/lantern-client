import 'package:fluttertoast/fluttertoast.dart';
import 'package:lantern/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

class AppMethods {
  static openAppstore() {
    //Launch App  store
    const appId = 'id1457872372';
    final url = Uri.parse(
      "https://apps.apple.com/app/id$appId",
    );
    launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  static showToast(String message) {
    //Show Toast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: indicatorGreen,
      textColor: white,
      fontSize: 16.0,
    );
  }

  String generatePassword() {
    const allChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789!@#\$%^&*()-=+{};:,<.>/?';
    final random = Random.secure();

    return List.generate(8, (i) => allChars[random.nextInt(allChars.length)])
        .join();
  }
// String generatePassword() {
//   String _lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
//   String _uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//   String _numbers = '0123456789';
//   String _specialCharacters = '!@#\$%^&*()-+';
//
//   // Combine all characters into one string
//   String _allCharacters =
//       _lowercaseLetters + _uppercaseLetters + _numbers + _specialCharacters;
//
//   Random _random = Random.secure();
//
//   // Generate a password by picking a random character from the combined string
//   return List.generate(8,
//           (index) => _allCharacters[_random.nextInt(_allCharacters.length)])
//       .join();
// }
}
