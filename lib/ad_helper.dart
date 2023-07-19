import 'dart:io';

class AdHelper {
  static List<String> notAdsSupportCountry = ['CN'];

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // ***REMOVED***
      return const String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
