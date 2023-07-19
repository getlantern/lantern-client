import 'dart:io';

class AdHelper {
  static List<String> notAdsSupportCountry = ['CN'];

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // ca-app-pub-2685698271254859/9922829329
      return const String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
