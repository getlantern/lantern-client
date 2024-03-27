import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecret {
  static String androidAdsAppId = dotenv.get('Android_interstitialAd');
  static String iOSAdsAppId = dotenv.get('IOS_interstitialAd');
  static String tos = 'https://s3.amazonaws.com/lantern/Lantern-TOS.pdf';
  static String privacyPolicy = 'https://s3.amazonaws.com/lantern/LanternPrivacyPolicy.pdf';
  static String privacyPolicyV2 = 'https://lantern.io/privacy';
  static String tosV2 = 'https://lantern.io/terms';

}
