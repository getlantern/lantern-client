import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecret {
  static String androidAdsAppId = dotenv.get('Android_interstitialAd');
  static String iOSAdsAppId = dotenv.get('IOS_interstitialAd');
}
