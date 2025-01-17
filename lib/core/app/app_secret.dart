import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecret {
  static String androidInterstitialAd = dotenv.get('Android_interstitialAd');
  static String iOSInterstitialAd = dotenv.get('IOS_interstitialAd');

  static String androidAppOpenAd = dotenv.get('ANDROID_APP_OPEN_AD');
  static String iOSAppOpenAd = dotenv.get('IOS_APP_OPEN_AD');
  static String tos = 'https://s3.amazonaws.com/lantern/Lantern-TOS.pdf';
  static String privacyPolicy = 'https://s3.amazonaws.com/lantern/LanternPrivacyPolicy.pdf';
  static String privacyPolicyV2 = 'https://lantern.io/privacy';
  static String tosV2 = 'https://lantern.io/terms';
  static String videoInterstitialZoneId = dotenv.get('VideoInterstitialZoneId');
  static String interstitialZoneId =dotenv.get('InterstitialZoneId');


  static  String dnsConfig() {
    if (Platform.isAndroid) {
      return "https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353";
    }
    if (Platform.isIOS) {
      return "https://c14296fdf5a6be272e1ecbdb7cb23f76@o75725.ingest.sentry.io/4506081382694912";
    }
    return "https://7397d9db6836eb599f41f2c496dee648@o75725.ingest.us.sentry.io/4507734480912384";
  }

}
