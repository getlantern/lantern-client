import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecret {
  static String androidAdsAppId = dotenv.get('Android_interstitialAd');
  static String iOSAdsAppId = dotenv.get('IOS_interstitialAd');
  static String testingSpotCheckTargetToken = dotenv.get('TESTING_SPOTCHECK_TARGET_TOKEN');
  static String iranSpotCheckTargetToken = dotenv.get('IRAN_SPOTCHECK_TARGET_TOKEN');
  static String russiaSpotCheckTargetToken = dotenv.get('RUSSIA_SPOTCHECK_TARGET_TOKEN');
  static String ukraineSpotCheckTargetToken = dotenv.get('UKRAINE_SPOTCHECK_TARGET_TOKEN');
  static String belarusSpotCheckTargetToken = dotenv.get('BELARUS_SPOTCHECK_TARGET_TOKEN');
  static String chinaSpotCheckTargetToken = dotenv.get('CHINA_SPOTCHECK_TARGET_TOKEN');
  static String UAEspotCheckTargetToken = dotenv.get('UAE_SPOTCHECK_TARGET_TOKEN');
  static String myanmarSpotCheckTargetToken = dotenv.get('MYANMAR_SPOTCHECK_TARGET_TOKEN');



  static String tos = 'https://s3.amazonaws.com/lantern/Lantern-TOS.pdf';
  static String privacyPolicy = 'https://s3.amazonaws.com/lantern/LanternPrivacyPolicy.pdf';
  static String privacyPolicyV2 = 'https://lantern.io/privacy';
  static String tosV2 = 'https://lantern.io/terms';


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
