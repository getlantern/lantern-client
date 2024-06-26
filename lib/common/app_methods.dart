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
}
