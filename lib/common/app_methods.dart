import 'package:url_launcher/url_launcher.dart';

class AppMethods{

  static openAppstore(){
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
}